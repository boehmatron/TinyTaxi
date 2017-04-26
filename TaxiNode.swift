//
//  TaxiNode.swift
//  TinyTaxi
//
//  Created by Johannes Boehm on 04.01.16.
//  Copyright © 2016 Johannes Boehm. All rights reserved.
//

import SpriteKit

class TaxiNode: SKSpriteNode, CustomTaxiNodeEvents {
    
    func didMoveToScene() {
        
        print("taxi added")
        
        let taxiSize = CGSize(width: self.size.width, height: self.size.height)
//        physicsBody = SKPhysicsBody(rectangleOf: taxiSize)
        physicsBody!.isDynamic = false
        physicsBody!.friction = 0.6
        
//        physicsBody!.categoryBitMask = PhysicsCategory.Taxi
//        physicsBody!.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Edge
//        physicsBody!.contactTestBitMask = PhysicsCategory.Platform
        
        
    }
    
    let throttle_y = 35.0/20
    let throttle_x = 5.0/20
    let throttle_duration = 0.2
    let angle = 0.1
    

    
    
    func throttleRight() {
        
        self.physicsBody!.applyImpulse(CGVector(dx: throttle_x, dy: throttle_y))
        
        let rotateRight = SKAction.rotate(toAngle: -0.3, duration: throttle_duration)
        //self.run(rotateRight)
        
    }
    
    func throttleLeft() {
        
        self.physicsBody!.applyImpulse(CGVector(dx: -(throttle_x), dy: throttle_y))
        
        let rotateLeft = SKAction.rotate(toAngle: 0.3, duration: throttle_duration)
        //self.run(rotateLeft)
        
    }
    
}
