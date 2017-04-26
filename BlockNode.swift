//
//  BlockNode.swift
//  TinyTaxi
//
//  Created by Johannes Boehm on 04.01.16.
//  Copyright © 2016 Johannes Boehm. All rights reserved.
//

import SpriteKit

class BlockNode: SKSpriteNode, CustomNodeEvents {
    
    func didMoveToScene() {
        print("block added")
        //userInteractionEnabled = true
        
        let blockSize = CGSize(width: self.size.width, height: self.size.height)
        physicsBody = SKPhysicsBody(rectangleOf: blockSize)
        physicsBody!.isDynamic = false
        
        //physicsBody!.categoryBitMask = PhysicsCategory.Block
        physicsBody!.collisionBitMask = PhysicsCategory.None
        physicsBody!.contactTestBitMask = PhysicsCategory.Taxi

        
    }
    
//    func interact(taxiNode: TaxiNode) {
//        
//        print("appliedForce")
//        taxiNode.physicsBody!.applyImpulse(CGVector(dx: 30, dy: 400))
//        
//    }
//    
//    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesEnded(touches, withEvent: event)
//        print("destroy block")
//        
//    }
    
}
