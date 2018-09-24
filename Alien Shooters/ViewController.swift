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


}

