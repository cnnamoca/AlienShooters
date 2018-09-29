//
//  ViewController+ARSCNViewDelegate.swift
//  Alien Shooters
//
//  Created by Carlo Namoca on 2018-09-25.
//  Copyright © 2018 Carlo Namoca. All rights reserved.
//

import Foundation
import ARKit

extension ViewController: ARSCNViewDelegate, ARSessionDelegate {
    //TODO: - Handle errors when user switches apps + Make sure origin
    //always gets updated as user moves
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        // We need to extract the location and orientation
        // everytime the renderer gets called
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let currentPositionOfCamera = orientation + location
        
        currentPosition = currentPositionOfCamera        
    }
}
