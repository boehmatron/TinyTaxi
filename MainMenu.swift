//
//  MainMenu.swift
//  MainMenuTransitionTest
//
//  Created by Böhm Johannes, SME-OXD-MOI on 22.07.16.
//  Copyright (c) 2016 Böhm Johannes. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    var btn_startGame = SKSpriteNode()
        
    override func didMove(to view: SKView) {
    
        /* Setup your scene here */
        //SwiftyAds.shared.showBanner(from: view.window?.rootViewController)
        //SwiftyAds.shared.showBanner(at: .top, from: view.window?.rootViewController)
        
        btn_startGame = (childNode(withName: "btn_startGame") as? SKSpriteNode)!

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            
            let location = touch.location(in: self)
            
            print("detected touch")
            
            if btn_startGame.contains(location){
                
                //SwiftyAds.shared.showInterstitial(from: view?.window?.rootViewController)
                SwiftyAds.shared.showBanner(at: .top, from: view?.window?.rootViewController)
                let gameScene = GameScene.level(1)
                
//                self.scene?.view?.presentScene(gameScene!, transition: SKTransition.moveIn(with: SKTransitionDirection.up, duration: 1))
                
//                self.scene?.view?.presentScene(gameScene!, transition: SKTransition.reveal(with: SKTransitionDirection.down, duration: 1))
                
                self.scene?.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 2))
                
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
