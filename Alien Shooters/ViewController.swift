//
//  ViewController.swift
//  Alien Shooters
//
//  Created by Carlo Namoca on 2018-09-24.
//  Copyright © 2018 Carlo Namoca. All rights reserved.
//

import UIKit
import ARKit
import Each

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()
    
    var timer = Each(1).seconds
    var countdown = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //TODO: - Make this prettier
    @objc
    func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        if !hitTest.isEmpty {
            if countdown > 0 {
                let results = hitTest.first!
                let node = results.node
                if node.animationKeys.isEmpty {
                    SCNTransaction.begin()
                    self.animateNode(node: node)
                    SCNTransaction.completionBlock = {
                        node.removeFromParentNode()
                        self.addEnemy()
//                        self.restoreTimer()
                    }
                    SCNTransaction.commit()
                }
            }
        }
    }
    
    func addEnemy() {
        let enemyScene = SCNScene(named: "art.scnassets/alien.scn")
        let alienNode = enemyScene?.rootNode.childNode(withName: "alien", recursively: false)
        alienNode?.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1),
                                         randomNumbers(firstNum: -0.5, secondNum: 0.5),
                                         randomNumbers(firstNum: -1, secondNum: 1))
        self.sceneView.scene.rootNode.addChildNode(alienNode!)
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
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timerLabel.text = String(self.countdown)
            
            if self.countdown == 0 {
                self.timerLabel.text = "You Lose!"
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
    // TODO: - Figure out new Swift random function
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    
    


}

