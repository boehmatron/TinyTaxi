//
//  PassengerNode.swift
//  TinyTaxi
//
//  Created by Johannes Boehm on 03.02.16.
//  Copyright © 2016 Johannes Boehm. All rights reserved.
//

//import Foundation
import SpriteKit

class PassengerNode: SKSpriteNode {
    
    let passengerStart: Int
    let passengerDestination: Int
    
    var animatePassengerLeftAction = SKAction()
    var animatePassengerRightAction = SKAction()
    var animatePassengerStopAction = SKAction()
    
    private var textureAtlas = SKTextureAtlas()
    private var playerAnimation = [SKTexture]()
    private var animatePlayerAction = SKAction()
    
    
    init(start:Int, destination: Int, texture: String) {
        let texture = SKTexture(imageNamed: texture)
        self.passengerStart = start
        self.passengerDestination = destination
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        self.zPosition = 100
        
        // Animation Passenger
        // moving left
        var animationPassengerLeftAssets = [SKTexture]()
        for i in 2...10 {
            let name = "sprite_L_\(i)"
            animationPassengerLeftAssets.append(SKTexture(imageNamed: name))
        }
        self.animatePassengerLeftAction = SKAction.repeatForever(SKAction.animate(with: animationPassengerLeftAssets, timePerFrame: 0.1))
        //moving right
        var animationPassengerRightAssets = [SKTexture]()
        for i in 2...10 {
            let name = "sprite_R_\(i)"
            animationPassengerRightAssets.append(SKTexture(imageNamed: name))
        }
        self.animatePassengerRightAction = SKAction.repeatForever(SKAction.animate(with: animationPassengerRightAssets, timePerFrame: 0.1))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Change Texture
    
    func updateTexture(_ newTexture: SKTexture) {
        self.texture = newTexture
    }
    
    func startWalkingLeft(){
        self.run(animatePassengerLeftAction, withKey: "passengerIsMoving")
    }
    
    func startWalkingRight(){
        self.run(animatePassengerRightAction, withKey: "passengerIsMoving")
    }
    
    func stopWalking(){
        self.texture = SKTexture(imageNamed: "sprite_IDL")
    }
    
    
}


//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let location = (touches.first! ).locationInNode(scene!)
//        position = scene!.convertPoint(location, toNode: parent!)
//        
//        print("touchesBegan: \(location)")
//    }
//    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let location = (touches.first! ).locationInNode(scene!)
//        position = scene!.convertPoint(location, toNode: parent!)
//        
//        print("touchesMoved: \(location)")
//        
//    }
//    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let location = (touches.first! ).locationInNode(scene!)
//        position = scene!.convertPoint(location, toNode: parent!)
//        
//        print("touchesEnded: \(location)")
//    }
