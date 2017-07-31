//
//  Introduction.swift
//  TinyTaxi
//
//  Created by Johannes Boehm on 05/03/17.
//  Copyright © 2017 Johannes Boehm. All rights reserved.
//

import SpriteKit

class End: SKScene {
    
    var btn_continue = SKSpriteNode()
    

    
    override func didMove(to view: SKView) {
        
        /* Setup your scene here */
                    //SwiftyAds.shared.showInterstitial(withInterval: 1, from: view.window?.rootViewController)
        
        //SwiftyAds.shared.showInterstitial(from: view.window?.rootViewController)
       // SwiftyAds.shared.showBanner(at: .top, from: view.window?.rootViewController)
        
        btn_continue = (childNode(withName: "btn_continue") as? SKSpriteNode)!

        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            
            let location = touch.location(in: self)
            
            print("detected touch")
            
            if btn_continue.contains(location){
                
                global.currentLevel = 0
                
                let scene = MainMenu(fileNamed: "MainMenu")
                scene!.scaleMode = .aspectFit
                view!.presentScene(scene!, transition: SKTransition.fade(withDuration: 2))
            
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
