//
//  GameViewController.swift
//  TinyTaxi
//
//  Created by Johannes Boehm on 04.01.16.
//  Copyright (c) 2016 Johannes Boehm. All rights reserved.
//

import UIKit
import SpriteKit

struct MyVariables {
    static var yourVariable = "test"
}

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftyAds.shared.setup(
            bannerID:       "ca-app-pub-9120386805444269/9870714231",
            interstitialID: "ca-app-pub-9120386805444269/2347447438",
            rewardedVideoID:  ""
        )
        SwiftyAds.shared.showBanner(from: self)
        
        let scene = GameScene(fileNamed: "Level4")
        //let scene = MainMenu(fileNamed: "MainMenu") //This can be any  scene you want the game to load first
        
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        skView.showsPhysics = false
//        scene!.scaleMode = .aspectFill
        scene!.scaleMode = .aspectFit
        skView.presentScene(scene)
        
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
