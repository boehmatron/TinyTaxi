//
//  GameScene.swift
//  TinyTaxi
//
//  Created by Johannes Boehm on 04.01.16.
//  Copyright (c) 2016 Johannes Boehm. All rights reserved.
//

import UIKit
import SpriteKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


// TODO: Timer erstellen, der nach x Sekunden einen passenger spawnen lässt - basierend auf den vorgegebenen startPlatform/destinationPlatform
// TODO: HUD anzeigen mit: Restlicher Zeit, Punktestand und Pause-Button
// DONE: Overlay bei beendetem Level anzeigen
// TODO: Overlay bei Pause anzeigen mit Optionen: Weiter und beenden
// TODO: iAd integration
// TODO: In-App Purchases integrieren

// TODO: Sprite zum aktuellen Taxi-Standpunkt laufen lassen


struct PhysicsCategory {
    static let None:        UInt32 = 0
    static let Taxi:        UInt32 = 0b1 // 1
    static let Block:       UInt32 = 0b10 // 2
    static let Edge:        UInt32 = 0b100 // 4
    static let Platform1:   UInt32 = 0b1000 // 8
    static let Platform2:   UInt32 = 0b10000 // 16
    static let Platform3:   UInt32 = 0b100000 // 32
    static let Platform4:   UInt32 = 0b1000000 // 64
    static let Platform5:   UInt32 = 0b10000000 // 128
    static let Platform6:   UInt32 = 0b100000000 // 256
    static let Passenger:   UInt32 = 0b1000000000 // 512
}

protocol CustomTaxiNodeEvents {
    func didMoveToScene()
    func throttleLeft()
    func throttleRight()
}


protocol CustomNodeEvents {
    func didMoveToScene()
}

protocol InteractiveNode {
    func interact(_ taxiNode: TaxiNode)
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    // MARK: Simulate Water
    let VISCOSITY: CGFloat = 40 // 40 Increase to make the water "thicker/stickier," creating more friction.
    let BUOYANCY: CGFloat = 0.4 //Slightly increase to make the object "float up faster," more buoyant.
    let OFFSET: CGFloat = 115 //120 Increase to make the object float to the surface higher.
    
    
    //MARK: Particles
    var showParticles : Bool = false
    var particles_left : SKEmitterNode = SKEmitterNode(fileNamed: "rocketParticles.sks")!
    var particles_right : SKEmitterNode = SKEmitterNode(fileNamed: "rocketParticles.sks")!
    
    
    // MARK: Variable Definitions
    var myGameViewController = GameViewController.self
    var currentLevel: Int = 1
    let passengerSpeed: Float = 20.0

    
    // Score
    let userDefaults = UserDefaults.standard
    
    var scoreTimer = Timer()
    var scoreLabel: SKLabelNode!
    var totalScoreLabel: SKLabelNode!
    
    var passengerScore :Int!
    var levelScore :Int!
    var totalScore :Int!
    
    var hud: SKNode?
    
    
    // Menu
    var overlay_bg: SKNode! = nil
    var menu_bg: SKNode! = nil
    var menuTitleLabel : SKLabelNode?
    var startGameLabel: SKLabelNode?
    
    // --
    var passengerAnimation = [SKTexture]()
    var animatePassengerAction = SKAction()
    
    // Sprites
    var taxiNode: TaxiNode!
    var blockNode: BlockNode!
    var waterGroup: SKNode!
    var water: SKSpriteNode!
    var water2: SKSpriteNode!
    
    
    var passenger: PassengerNode!
    
    var platforms: PlatformsNode!
    var platformNode1: PlatformNode!
    var platformNode2: PlatformNode!
    var platformNode3: PlatformNode?
    var platformNode4: PlatformNode?
    var platformNode5: PlatformNode?
    var platformNode6: PlatformNode?
    
    var destinationSign: SKSpriteNode?
    
    var overlay: SKNode!
    
    var platformArray = [SKNode]()
    
    let levelFinishedTest = SKLabelNode(fontNamed: "Chalkduster")
    
    var passengerNumber:Int = 0
    var passengerOnBoard: Bool = false
    var passengerOnTheWayToGate: Bool = false
    var correctPlatform: Bool = false
    
    
    
    // MARK: Level Configuration
    var startP: [[Int]] =    [[0, 0],
                              [2, 1, 3],
                              [2,1]
    ]
    
    var destP: [[Int]] =   [[2, 1],
                            [0, 2, 1],
                            [3,0]
    ]
    
    func timerTest(){
        print("timer fired!")
    }
    
    override func didMove(to view: SKView) {

        SwiftyAds.shared.removeBanner()
        
        setupWater()
        setupCustomEvents()
        setupOverlay()
        setupScoreLabels()
        setupPlayerScores()

        
        if (currentLevel > 1) {
            
        }
        
        // Calculate playable margin
        let maxAspectRatio: CGFloat = 16.0/9.0 // iPhone 5
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height - maxAspectRatioHeight)/2
        
        let playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: size.height-playableMargin*2-25)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
        physicsWorld.contactDelegate = self
        //physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        // make Nodes acccessible
        taxiNode = childNode(withName: "taxi") as? TaxiNode
//        let taxiAnchorPoint = CGPoint(x: taxiNode.size.width/2, y: 0)
//        
//        taxiNode.physicsBody = SKPhysicsBody(rectangleOf: taxiNode.size, center: taxiAnchorPoint)
        
        blockNode = childNode(withName: "block") as? BlockNode
        platforms = childNode(withName: "platforms") as? PlatformsNode
        
        platformNode1 = childNode(withName: "//platform1") as? PlatformNode
        platformNode1.physicsBody?.categoryBitMask = PhysicsCategory.Platform1
        
        platformNode2 = childNode(withName: "//platform2") as? PlatformNode
        platformNode2.physicsBody?.categoryBitMask = PhysicsCategory.Platform2
        
        platformNode3 = childNode(withName: "//platform3") as? PlatformNode
        platformNode3?.physicsBody?.categoryBitMask = PhysicsCategory.Platform3
        
        platformNode4 = childNode(withName: "//platform4") as? PlatformNode
        platformNode4?.physicsBody?.categoryBitMask = PhysicsCategory.Platform4
        
        platformNode5 = childNode(withName: "//platform5") as? PlatformNode
        platformNode5?.physicsBody?.categoryBitMask = PhysicsCategory.Platform5
        
        platformNode6 = childNode(withName: "//platform6") as? PlatformNode
        platformNode6?.physicsBody?.categoryBitMask = PhysicsCategory.Platform6
        

        particles_left.position = CGPoint(x: -taxiNode.size.width-20, y: -taxiNode.size.height-20)
        particles_right.position = CGPoint(x: taxiNode.size.width+20, y: -taxiNode.size.height-20)
        self.taxiNode.addChild(particles_left)
        self.taxiNode.addChild(particles_right)
        self.particles_left.isHidden = true
        self.particles_right.isHidden = true

        

        
        
        // Iterate over all available platforms and put them into an array
        for platform in platforms.children {
            print ("\(platform.name)")
            
            platformArray.append(platform)
            
        }
        platformArray.sort { $0.name < $1.name }
        print("Number of platforms in Array:", platformArray.count)
        
        spawnPassenger(x: platformArray[startP[currentLevel - 1][passengerNumber]].position.x, y: platformArray[startP[currentLevel - 1][passengerNumber]].position.y, showDestinationInSpeechBubble: true, passengerAtCorrectDestination: false)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        // Calculations for the water effect
        if water.frame.contains(CGPoint(x:taxiNode.position.x, y:taxiNode.position.y-taxiNode.size.height/2.0)) {
            let rate: CGFloat = 0.01; //Controls rate of applied motion. You shouldn't really need to touch this.
            let disp = (((water.position.y+OFFSET)+water.size.height/2.0)-((taxiNode.position.y)-taxiNode.size.height/2.0)) * BUOYANCY
            let targetPos = CGPoint(x: taxiNode.position.x, y: taxiNode.position.y+disp)
            let targetVel = CGPoint(x: (targetPos.x-taxiNode.position.x)/(1.0/60.0), y: (targetPos.y-taxiNode.position.y)/(1.0/60.0))
            let relVel: CGVector = CGVector(dx:targetVel.x-taxiNode.physicsBody!.velocity.dx*VISCOSITY, dy:targetVel.y-taxiNode.physicsBody!.velocity.dy*VISCOSITY);
            taxiNode.physicsBody?.velocity=CGVector(dx:(taxiNode.physicsBody?.velocity.dx)!+relVel.dx*rate, dy:(taxiNode.physicsBody?.velocity.dy)!+relVel.dy*rate);
        }
        
        print(passengerOnBoard)
        
    }
    
    // MARK: Setup Functions
    
    func setupWater(){
  
        water = SKSpriteNode(imageNamed: "water_1")
        water.anchorPoint = CGPoint.zero
        water.position = CGPoint(x: self.size.width/2.0, y: 0)
        water.alpha = 0.75
        water.zPosition = 200
        addChild(water)
        
        let waterAnimation = SKAction.moveBy(x: 50, y: 4, duration: 4)
        let waterAnimationReversed = SKAction.moveBy(x: -50, y: -4, duration: 4)
        let waterAnimationSequence = SKAction.sequence([waterAnimation, waterAnimationReversed])
        self.water.run(SKAction.repeatForever(waterAnimationSequence))
        
        water2 = SKSpriteNode(imageNamed: "water_1")
        water2.anchorPoint = CGPoint.zero
        water2.position = CGPoint(x: -self.size.width/2.0, y: 0)
        water2.alpha = 0.75
        water2.zPosition = 200
        addChild(water2)
        
        let waterAnimation2 = SKAction.moveBy(x: 50, y: 4, duration: 4)
        let waterAnimationReversed2 = SKAction.moveBy(x: -50, y: -4, duration: 4)
        let waterAnimationSequence2 = SKAction.sequence([waterAnimation2, waterAnimationReversed2])
        self.water2.run(SKAction.repeatForever(waterAnimationSequence2))
    }
    
    func setupCustomEvents(){
        // add Custom events to all Nodes
        enumerateChildNodes(withName: "//*", using: {node, _ in
            if let customNode = node as? CustomNodeEvents {
                customNode.didMoveToScene()
            }
        })
    }
    
    func setupScoreLabels(){
        scoreLabel = childNode(withName: "//scoreLabel") as! SKLabelNode
        totalScoreLabel = childNode(withName: "//totalScoreLabel") as! SKLabelNode
        
    }
    
    func setupPlayerScores(){
        
        self.passengerScore = 1000
        self.levelScore = 0
        self.scoreLabel.text = String(levelScore)
        
        if (currentLevel <= 1) {
            self.totalScore = 0
        } else {
            self.totalScore = userDefaults.integer(forKey: "totalScore")
        }
        self.totalScoreLabel.text = String(totalScore)
        
    }
    
    
    // MARK: Game Score
    
    func updatePassengerScore(){
        
        if passengerScore! > 0 {
        passengerScore = passengerScore! - 1
        } else {
            passengerScore = 0
        }
        //print(passengerScore)
        scoreLabel.text = String(passengerScore)
    }
    
    
    func savePlayerScore() {
        let currentScore = self.totalScore
        self.userDefaults.set(currentScore, forKey: "totalScore")
        self.userDefaults.synchronize()
        
    }
    
    
    func showDestination(){
        
        switch destP[currentLevel - 1][passengerNumber] {
        case 0:
            destinationSign = SKSpriteNode(imageNamed: "chat_1")
        case 1:
            destinationSign = SKSpriteNode(imageNamed: "chat_2")
        case 2:
            destinationSign = SKSpriteNode(imageNamed: "chat_3")
        case 3:
            destinationSign = SKSpriteNode(imageNamed: "chat_4")
        case 4:
            destinationSign = SKSpriteNode(imageNamed: "chat_5")
        case 5:
            destinationSign = SKSpriteNode(imageNamed: "chat_6")
            
        default:
            destinationSign = SKSpriteNode(imageNamed: "chat_1")
            print ("something with the cases went wrong in showDestination()")
        }

        destinationSign?.position.x = 0
        destinationSign?.position.y = 33
        destinationSign!.zPosition = 200
        destinationSign?.setScale(0.01)
        destinationSign?.alpha = 0
        
        passenger.addChild(destinationSign!)
        
        let show = SKAction.scale(to: 1.0, duration: 0.2)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        let moveDown = SKAction.moveBy(x: 0, y: -5.0, duration: 0.2)
        let removeFromParent = SKAction.removeFromParent()
        
        let remove = SKAction.group([fadeOut, moveDown])
        
        let showDestinationAction = SKAction.sequence([wait, fadeIn, show, wait, remove, removeFromParent])
        
        destinationSign!.run(showDestinationAction)
    }
    
    func spawnPassenger( x: CGFloat, y: CGFloat, showDestinationInSpeechBubble: Bool, passengerAtCorrectDestination: Bool ){
        
        passenger = PassengerNode(start: 0, destination: 1, texture: "sprite_1")
        passenger.position.x = x
        passenger.position.y = y
        passenger.zPosition = 5
        passenger.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        passenger.setScale(0.1)
        
        addChild(passenger)
        
        // Animation: grow passenger
        let scalePassengerToFullSizeAction = SKAction.scale(to: 1.0, duration: 0.4 );
        
        if showDestinationInSpeechBubble == true {
            self.passengerOnBoard = false
            self.passengerOnTheWayToGate = false
            self.correctPlatform = false
            showDestination()
        } else {

        }
        
        if passengerAtCorrectDestination == true {
            
            passengerOnTheWayToGate = true
            
        }
        
        passenger.run(scalePassengerToFullSizeAction)
        
    }
    
    
    func nextPassenger() {
        
//        savePlayerScore()
        
        if passengerNumber < startP[currentLevel - 1].count - 1 {
            
            passengerNumber += 1
            
            spawnPassenger(x: platformArray[startP[currentLevel - 1][passengerNumber]].position.x, y: platformArray[startP[currentLevel - 1][passengerNumber]].position.y, showDestinationInSpeechBubble: true, passengerAtCorrectDestination: false)
            
        } else {
            
            passengerNumber = 1
            print("level finished")
//            SwiftyAds.shared.showInterstitial(withInterval: 1, from: view?.window?.rootViewController)
            showOverlay()
            
        }
    }
    
    func throttleRight() {
        taxiNode.throttleRight()
        
    }
    
    func throttleLeft() {
        taxiNode.throttleLeft()
    }
    
    // MARK: Passenger Animations
    
    // Calculate action duration btw two points and speed
    func getDuration(pointA:CGPoint,pointB:CGPoint,speed:CGFloat)->TimeInterval {
        let xDist = (pointB.x - pointA.x)
        let yDist = (pointB.y - pointA.y)
        let distance = sqrt((xDist * xDist) + (yDist * yDist));
        let duration : TimeInterval = TimeInterval(distance/speed)
        return duration
    }
    
    func onBoardingPassengerFromPlatform(platform: PlatformNode) {
        
        // Set direction and start walking animation
        if (passenger!.position.x < taxiNode!.position.x) {
            self.passenger.startWalkingRight()
        } else {
            self.passenger.startWalkingLeft()
        }
        
        // Animations
        let moveToTaxi = SKAction.move(to: CGPoint(x: taxiNode.position.x, y: platform.position.y), duration: getDuration(pointA: platform.position, pointB: taxiNode.position, speed: CGFloat(passengerSpeed)))
        let removePassenger = SKAction.removeFromParent()
        let setPassengerToOnBoard = SKAction.run({ () -> Void in
            self.passengerOnBoard = true
            self.passengerScore = 1000
            self.scoreTimer.invalidate()
            self.scoreTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updatePassengerScore), userInfo: nil, repeats: true)
        })
        let onBoardActionSequence = SKAction.sequence([moveToTaxi, removePassenger, setPassengerToOnBoard])
        
        self.passenger.run(onBoardActionSequence, withKey: "isOnboarding")
        
    }
    
    func offboardingPassengerFromTaxi(platform: PlatformNode){
        
        spawnPassenger(x: taxiNode.position.x, y: platform.position.y, showDestinationInSpeechBubble: false, passengerAtCorrectDestination: true)
        
        print(platform.name as Any)
        
        if (passenger!.position.x < platform.position.x) {
            self.passenger.startWalkingRight()
        } else {
            self.passenger.startWalkingLeft()
        }
        
        //move passenger
        let offBoardTaxi = SKAction.move(to: CGPoint(x: platform.position.x, y: platform.position.y), duration: getDuration(pointA: taxiNode.position, pointB: platform.position, speed: CGFloat(passengerSpeed)))
        let scaleDown = SKAction.scale(to: 0, duration: 0.75)
        let removePassenger = SKAction.removeFromParent()
        let callNextPassenger = SKAction.run({ () -> Void in
            
            //self.passengerArrivedAtGate = true
            self.scoreTimer.invalidate()
            
            self.totalScore! = self.totalScore! + self.passengerScore!
            
            self.totalScoreLabel.text = String(self.totalScore)
            
            self.savePlayerScore()

            self.passengerScore = 0
            
            self.nextPassenger()
            
        })
        
        let offBoardActionSequence = SKAction.sequence([offBoardTaxi, scaleDown, removePassenger,callNextPassenger])
        passenger.run(offBoardActionSequence, withKey: "isOffoarding")
 
        print("timer invalidate")
        
    }
    
    func movePassengerBackToOrigin(platform: PlatformNode){
        
        let stopAnimation_Action = SKAction.run({ () -> Void in
            self.passenger.removeAction(forKey: "passengerIsMoving")
            self.passenger.stopWalking()
        })
        let movePassengerToPlatformOrigin_Sequence = SKAction.sequence([stopAnimation_Action])
        self.passenger.run(movePassengerToPlatformOrigin_Sequence)
        
    }
    
    func movePassengerToGate(platform: PlatformNode){
        
        let stopAnimation_Action = SKAction.run({ () -> Void in
            self.passenger.removeAction(forKey: "passengerIsMoving")
            self.passenger.stopWalking()
        })
        let movePassengerToPlatformOrigin_Sequence = SKAction.sequence([stopAnimation_Action])
        self.passenger.run(movePassengerToPlatformOrigin_Sequence)
        
    }
    
    
    // MARK: Collision Handling
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        print("update within the loop")
        
                        // TODO: Passenger erst laufen lassen, wenn das Taxi still steht
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        // COLLISION PLATFORM 1
        if collision == PhysicsCategory.Taxi | PhysicsCategory.Platform1 {
            
            if (passenger != nil) {

                if passengerOnBoard == false {
                    
                    if startP[currentLevel - 1][passengerNumber] == 0 {
                        
                        
                            onBoardingPassengerFromPlatform(platform: platformNode1)
                        }
              
                }
                if passengerOnBoard == true {
                    
                    if destP[currentLevel - 1][passengerNumber] == 0 {
                        
                        offboardingPassengerFromTaxi(platform: platformNode1)
                        
                    } else {
                        
                        print("wrong platform")
                        
                    }
                }

            }
        } // end collision Taxi <-> Platform1
        
        // COLLISION PLATFORM 2
        if collision == PhysicsCategory.Taxi | PhysicsCategory.Platform2 {
            
            if (passenger != nil) {

                if passengerOnBoard == false {
                    
                    if startP[currentLevel - 1][passengerNumber] == 1 {
                        
                        onBoardingPassengerFromPlatform(platform: platformNode2)
                        
                    }
                }
                if passengerOnBoard == true {
                    
                    if destP[currentLevel - 1][passengerNumber] == 1 {
                        
                        offboardingPassengerFromTaxi(platform: platformNode2)
                        
                    } else {
                        
                        print("wrong platform")
                        
                    }
                }
                
            }
        } // end collision Taxi <-> Platform2
        
        // COLLISION PLATFORM 3
        if collision == PhysicsCategory.Taxi | PhysicsCategory.Platform3 {
            
            if (passenger != nil) {

                if passengerOnBoard == false {
                    
                    if startP[currentLevel - 1][passengerNumber] == 2 {
                        
                        onBoardingPassengerFromPlatform(platform: platformNode3!)
                        
                    }
                }
                if passengerOnBoard == true {
                    
                    if destP[currentLevel - 1][passengerNumber] == 2 {
                        
                        offboardingPassengerFromTaxi(platform: platformNode3!)
                        
                    } else {
                        
                        print("wrong platform")
                        
                    }
                }
                
            }
        } // end collision Taxi <-> Platform3
        
        // COLLISION PLATFORM 4
        if collision == PhysicsCategory.Taxi | PhysicsCategory.Platform4 {
            
            if (passenger != nil) {

                if passengerOnBoard == false {
                    
                    if startP[currentLevel - 1][passengerNumber] == 3 {
                        
                        onBoardingPassengerFromPlatform(platform: platformNode4!)
                        
                    }
                }
                if passengerOnBoard == true {
                    
                    if destP[currentLevel - 1][passengerNumber] == 3 {
                        
                        offboardingPassengerFromTaxi(platform: platformNode4!)
                        
                    } else {
                        
                        print("wrong platform")
                        
                    }
                }
                
            }
        } // end collision Taxi <-> Platform4
        
    } // <-- end Collision Handling DID BEGIN CONTACT
    // Start Collision Handling DID END CONTACT
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        // COLLISION ENDED PLATFORM 1
        if collision == PhysicsCategory.Taxi | PhysicsCategory.Platform1 {
            if (passenger != nil) {
                
                if passengerOnBoard == false && passengerOnTheWayToGate == false {
                    
                    self.passenger.removeAction(forKey: "isOnboarding")
                    self.movePassengerBackToOrigin(platform: platformNode1!)
                    
                }
            }
        }
        // COLLISION ENDED PLATFORM 2
        if collision == PhysicsCategory.Taxi | PhysicsCategory.Platform2 {
            if (passenger != nil) {
                
                if passengerOnBoard == false && passengerOnTheWayToGate == false {
                    
                    self.passenger.removeAction(forKey: "isOnboarding")
                    self.movePassengerBackToOrigin(platform: platformNode2!)
                    
                }
            }
        }
        // COLLISION ENDED PLATFORM 3
        if collision == PhysicsCategory.Taxi | PhysicsCategory.Platform3 {
            if (passenger != nil) {
                
                if passengerOnBoard == false && passengerOnTheWayToGate == false {
                    
                    self.passenger.removeAction(forKey: "isOnboarding")
                    self.movePassengerBackToOrigin(platform: platformNode3!)
                    
                }
                
                if passengerOnBoard == false && passengerOnTheWayToGate == true {
                    print("be happy")
                }
                

            
            }
        }
        // COLLISION ENDED PLATFORM 4
        if collision == PhysicsCategory.Taxi | PhysicsCategory.Platform4 {
            if (passenger != nil) {
                
                if passengerOnBoard == false && passengerOnTheWayToGate == false {
                    
                    self.passenger.removeAction(forKey: "isOnboarding")
                    self.movePassengerBackToOrigin(platform: platformNode4!)
                    
                }
            }
        }
        
    }
    
    
    
    // MARK: User Interactions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // to stop the countdown action
        //if actionForKey("countdown") != nil {removeActionForKey("countdown")}
        
        if let touch = touches.first {
            //get the touch location
            let location = touch.location(in: self)
            //print(location)
            
            let showParticles = SKAction.run({ () -> Void in
                self.particles_left.isHidden = false
                self.particles_right.isHidden = false
            })
            
            let hideParticles = SKAction.run({ () -> Void in
                self.particles_left.isHidden = true
                self.particles_right.isHidden = true
            })
            
            let wait = SKAction.wait(forDuration: 0.3)
            
            let showParticlesWithThrottle = SKAction.sequence([showParticles, wait, hideParticles])
            
            
            if location.x >= 0 && location.x < size.width/2 {
                
                throttleLeft()
                
                self.particles_left.run(showParticlesWithThrottle)
                self.particles_right.run(showParticlesWithThrottle)
                
            } else {
                
                throttleRight()
                
                self.particles_left.run(showParticlesWithThrottle)
                self.particles_right.run(showParticlesWithThrottle)
                
            }
            
        }
        
    } // <-- end touches began

    

    

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    //    object.position = (touches.anyObject() as! UITouch).location(in: self);object.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        // Loop over all the touches in this event
        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
            let location = touch.location(in: menu_bg)
            // Check if the location of the touch is within the button's bounds
            if startGameLabel!.contains(location) {
                print("tapped!")
                hideMenu()
                
                //                self.myGameViewController.displayAd()
                
                nextLevel()
                //                if (self.interstitialAd.isReady) {
                //                    self.interstitialAd.presentFromRootViewController(self)
                //                    
                //                }
            }
        }
    }
    
    // MARK: Game Level Controls
    class func level(_ levelNum: Int) -> GameScene? {
        let scene = GameScene(fileNamed: "Level\(levelNum)")!
        scene.currentLevel = levelNum
        scene.scaleMode = .aspectFill
        return scene
    }
    
    func nextLevel(){
        currentLevel += 1
        
        let scene = Scoreboard(fileNamed: "Scoreboard")
        view!.presentScene(scene)
    }
    
    
    // MARK: Everything Overlay related
    func setupOverlay(){
        
        //menu_bg = SKSpriteNode(color: SKColor.blueColor(), size: CGSize(width: 800, height: 600))
        
        overlay_bg = SKSpriteNode(color: SKColor.black, size: CGSize(width: self.frame.width, height: self.frame.height))
        overlay_bg.position = CGPoint(x: self.frame.width/2 , y: self.frame.height/2)
        overlay_bg.alpha = 0
        self.addChild(overlay_bg)
        
        menu_bg = SKSpriteNode(imageNamed: "menu_bg")
        
        // Put it in the center of the scene
        menu_bg.position = CGPoint(x: self.frame.width/2 , y: self.frame.height+200)
        menu_bg.zPosition = 1000
        
        self.addChild(menu_bg)
        
        self.menuTitleLabel = SKLabelNode(fontNamed: "Chalkduster")
        self.startGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        
        self.menuTitleLabel!.fontSize = 36
        self.startGameLabel!.fontSize = 22
        
        self.menuTitleLabel?.fontColor = UIColor.red
        self.startGameLabel?.fontColor = UIColor.red
        
        self.menuTitleLabel!.text = "Tiny Taxi Menu"
        self.startGameLabel!.text = "Start Game"
        
        self.menuTitleLabel!.name = "menuTitle"
        self.startGameLabel!.name = "startGame"
        
        self.menuTitleLabel!.zPosition = 1001
        self.startGameLabel!.zPosition = 1002
        
        self.menu_bg.addChild(menuTitleLabel!)
        self.menu_bg.addChild(startGameLabel!)
        
        self.menuTitleLabel!.position = CGPoint(x: 0, y: 50)
        self.startGameLabel!.position = CGPoint(x: 0, y: 0)
        
    }
    
    func blurWithCompletion() {
        let duration: CGFloat = 0.5
        let filter: CIFilter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius" : NSNumber(value:1.0)])!
        scene!.filter = filter
        scene!.shouldRasterize = true
        scene!.shouldEnableEffects = true
        scene!.run(SKAction.customAction(withDuration: 0.5, actionBlock: { (node: SKNode, elapsedTime: CGFloat) in
            let radius = (elapsedTime/duration)*10.0
            (node as? SKEffectNode)!.filter!.setValue(radius, forKey: "inputRadius")
            
        }))
    }
    
    func showOverlay(){
        
        let fadeInAction = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
        self.overlay_bg.run(fadeInAction)
        
        let screenCenter = CGPoint(x: self.size.width/2, y: self.size.height/2)
        let centerOverlayAction = SKAction.move(to: screenCenter, duration: 2)
        self.menu_bg.run(centerOverlayAction)
        //blurWithCompletion()
        
    }
    
    func hideMenu(){
        //let hideMenuAction = SKAction.moveTo(CGPoint(x: self.size.width + 500, y: 200), duration: 1)
        let hideMenuAction = SKAction.scale(to: 0.0, duration: 0.2)
        self.menu_bg.run(hideMenuAction)
    }
    
}
