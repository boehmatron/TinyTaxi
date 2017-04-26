//
//  PlatformNode.swift
//  TinyTaxi
//
//  Created by Johannes Boehm on 10.01.16.
//  Copyright © 2016 Johannes Boehm. All rights reserved.
//

import SpriteKit

class PlatformNode: SKSpriteNode, CustomNodeEvents {
    
    func didMoveToScene() {
        

        
        let platformSize = CGSize(width: self.size.width, height: self.size.height)
        physicsBody = SKPhysicsBody(rectangleOf: platformSize)
        physicsBody!.isDynamic = false
        physicsBody!.friction = 0.6
        
//        physicsBody!.categoryBitMask = PhysicsCategory.Platform
        physicsBody!.collisionBitMask = PhysicsCategory.None
        physicsBody!.contactTestBitMask = PhysicsCategory.Taxi
        
        //print(self.name)
        
        
        
        
    }
}
