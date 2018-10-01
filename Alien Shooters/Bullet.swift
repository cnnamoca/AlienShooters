//
//  Bullet.swift
//  AlienShooters
//
//  Created by Carlo Namoca on 2018-10-01.
//  Copyright © 2018 Carlo Namoca. All rights reserved.
//

import UIKit
import SceneKit

// Spheres that are shot at the "ships"
class Bullet: SCNNode {
    override init () {
        super.init()
        let sphere = SCNSphere(radius: 0.025)
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionCategory.bullets.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.ship.rawValue
        
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        self.geometry?.materials  = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
