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
    let configuration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
    
    // Gives you a random decimal in between firstNum and secondNum
    // TODO: - Figure out new Swift random function
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func addEnemy() {
        let enemyScene = SCNScene(named: "art.scnassets/alien.scn")
        let alienNode = enemyScene?.rootNode.childNode(withName: "alien", recursively: false)
        alienNode?.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1),
                                         randomNumbers(firstNum: -0.5, secondNum: 0.5) ,
                                         randomNumbers(firstNum: -1, secondNum: 1))
        self.sceneView.scene.rootNode.addChildNode(alienNode!)
    }
    
    


}

