//
//  ViewController.swift
//  Alien Shooters
//
//  Created by Carlo Namoca on 2018-09-24.
//  Copyright © 2018 Carlo Namoca. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import Each

class ViewController: UIViewController, SCNPhysicsContactDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var playButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var restartButtonTrailingConstraint: NSLayoutConstraint!
    
    let configuration = ARWorldTrackingConfiguration()
    
    var timer = Each(1).seconds
    var countdown = 10
    var currentPosition: SCNVector3?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        timerLabel.isHidden = true
    }
    
    
    @objc
    func handleTap(sender: UITapGestureRecognizer) {
//        let sceneViewTappedOn = sender.view as! SCNView
//        let touchCoordinates = sender.location(in: sceneViewTappedOn)
//        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
//
//        //TODO: - Make sure only alien nodes are touched
//        if hitTest.first?.node == enemyNode {
//            if countdown > 0 {
//                let results = hitTest.first!
//                let node = results.node
//                if node.animationKeys.isEmpty {
//                    SCNTransaction.begin()
//                    self.animateNode(node: node)
//                    SCNTransaction.completionBlock = {
//                        node.removeFromParentNode()
//                        self.addEnemy()
//                        self.restoreTimer()
//                    }
//                    SCNTransaction.commit()
//                }
//            }
//        }
        
        let bulletsNode = Bullet()
        
        let (direction, position) = self.getUserVector()
        bulletsNode.position = position // SceneKit/AR coordinates are in meters
        
        let bulletDirection = direction
        bulletsNode.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletsNode)
    }
    
    //MARK: - IBActions
    @IBAction func play(_ sender: Any) {
        playButton.isEnabled = false
        timerLabel.isHidden = false
        setTimer()
        addEnemy()
        
        // Move buttons to the side when this button is pressed
        playButtonTrailingConstraint.constant -= playButton.frame.size.width * 2
        restartButtonTrailingConstraint.constant -= restartButton.frame.size.width * 2
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func restart(_ sender: Any) {
        restoreTimer()
        playButton.isEnabled = true
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        
    }
    
    var enemyNode = SCNNode()
    func addEnemy() {
        let enemyScene = SCNScene(named: "art.scnassets/FlyingSaucer.scn")
        let alienNode = enemyScene?.rootNode.childNode(withName: "FlyingSaucer", recursively: false)
        enemyNode = alienNode!
        alienNode?.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1),
                                         randomNumbers(firstNum: -0.5, secondNum: 0.5),
                                         randomNumbers(firstNum: -1, secondNum: 1))
        
        
        let shape = SCNPhysicsShape(geometry: alienNode!.geometry!, options: nil)
        alienNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        alienNode?.physicsBody?.isAffectedByGravity = false
        alienNode?.physicsBody?.categoryBitMask = CollisionCategory.ship.rawValue
        alienNode?.physicsBody?.contactTestBitMask = CollisionCategory.bullets.rawValue

        sceneView.scene.rootNode.addChildNode(alienNode!)
        
        // TODO: - Make sure enemies are looking at player at all times
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        alienNode!.constraints = [billboardConstraint]
        
        //TODO: - Make enemies move more
        
    }
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2,
                                  node.presentation.position.y - 0.2,
                                  node.presentation.position.z - 0.2)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position")
        
        let shrink = CABasicAnimation(keyPath: "scale")
        shrink.fromValue = SCNVector3(node.scale.x, node.scale.y, node.scale.z)
        shrink.toValue = SCNVector3(0, 0, 0)
        shrink.duration = 0.7
        node.addAnimation(shrink, forKey: "scale")
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //print("did begin contact", contact.nodeA.physicsBody!.categoryBitMask, contact.nodeB.physicsBody!.categoryBitMask)
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.ship.rawValue || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.ship.rawValue { // this conditional is not required--we've used the bit masks to ensure only one type of collision takes place--will be necessary as soon as more collisions are created/enabled
            
            print("Hit ship!")
            contact.nodeB.removeFromParentNode()
            
            DispatchQueue.main.async {
                if self.countdown > 0 {
                    let node = contact.nodeA
                    if node.animationKeys.isEmpty {
                        SCNTransaction.begin()
                        self.animateNode(node: node)
                        SCNTransaction.completionBlock = {
                            node.removeFromParentNode()
                            self.addEnemy()
                            self.restoreTimer()
                        }
                        SCNTransaction.commit()
                    }
                }
            }
            
            
        }
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
        
    func setTimer() {
        timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timerLabel.text = String(self.countdown)

            if self.countdown == 0 {
                self.timerLabel.text = "You Lose!"
                //TODO: - Check if this works
                self.playButtonTrailingConstraint.constant += self.playButton.frame.size.width * 2
                self.restartButtonTrailingConstraint.constant += self.restartButton.frame.size.width * 2
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
                return .stop
            }

            return .continue
        }
    }
    
    func restoreTimer() {
        countdown = 10
        self.timerLabel.text = String(countdown)
    }

    // Gives you a random decimal in between firstNum and secondNum
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }

}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bullets  = CollisionCategory(rawValue: 1 << 0) // 00...01
    static let ship = CollisionCategory(rawValue: 1 << 1) // 00..10
}

// Modify the "+" operator
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
