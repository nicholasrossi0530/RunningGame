//
//  GameScene2.swift
//  RunningGame
//
//  Created by Rossi on 3/25/16.
//  Copyright © 2016 Rossi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    var player: SKSpriteNode!
    var groundNode = SKSpriteNode()
    var scrollNode = SKNode()
    var groundSpeed = 5
    var boxNode = SKNode()
    
    var playerBaseline = CGFloat(0)
    var onGround = true
    var playerPositionY = CGFloat()
    
    let playerCategory: UInt32 = 0x1 << 0
    let spikeCategory: UInt32 = 0x1 << 1
    let boxCategory: UInt32 = 0x1 << 2
    let groundCategory: UInt32 = 0x1 << 3
    
    var longPressing = false
    var boxMaxX = CGFloat(0)
    var originalBoxPositionX = CGFloat(0)
    var moveBoxesAndRemove = SKAction()
    var boxTexture = SKTexture()
    var groundHeight = CGFloat()
    var boxArray: [SKNode] = []
    var levelArray: NSArray?
    var levelSpot = 0
    var score = 0
    var scores:[Int] = []
    var scoreLabel: UILabel!
    var scoreTimer: NSTimer!
    var outOfScene = false
    var scoreClass = Scores()
    
    override func didMoveToView(view: SKView) {
        
        setupScoreItems()
        setupPhysics()
        setupGround()
        setupPlayer()
        spawnBoxes()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.handleLongPress(_:)))
        view.addGestureRecognizer(longPressRecognizer)
        let path = NSBundle.mainBundle().pathForResource("Levels", ofType: "plist")
        levelArray = NSArray(contentsOfFile: path!)
        outOfScene = false
    }
    
    override func update(currentTime: NSTimeInterval) {
    }
    
    func setupScoreItems() {
        let scoreLabelRect = CGRect(x: (self.view?.frame.maxX)! - 100, y: 0, width: 100, height: 20)
        scoreLabel = UILabel(frame: scoreLabelRect)
        scoreLabel.text = "Score: \(score)"
        scoreLabel.adjustsFontSizeToFitWidth = true
        self.view?.addSubview(scoreLabel)
        
        scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(GameScene.scoreCounter), userInfo: nil, repeats: true)
        
        let scoreSave = NSUserDefaults.standardUserDefaults()
        let scoreArray = scoreSave.arrayForKey("scores")
        //scores = scoreArray as! [Int]
    }
    
    func scoreCounter() {
        score += 1
        scoreLabel.text = "Score: \(score)"
        
    }
    
    func setupPhysics() {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, -6)
        //physicsWorld.speed = 3
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if onGround == true {
            playerPositionY = player.position.y
            player.physicsBody?.velocity = CGVectorMake(0, 0)
            player.physicsBody?.applyImpulse(CGVectorMake(0, 35))
            onGround = false
        }
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        if(sender.state == .Began){
            jump()
            longPressing = true
        }
        else if sender.state == .Ended {
            longPressing = false
        }
        
    }
    
    func jump() {
        if onGround == true {
            playerPositionY = player.position.y
            player.physicsBody?.velocity = CGVectorMake(0, 0)
            player.physicsBody?.applyImpulse(CGVectorMake(0, 40))
            onGround = false
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if firstBody.categoryBitMask & groundCategory == 0 {
            onGround = true
            if longPressing {
                jump()
            }
        }
        if secondBody.categoryBitMask == boxCategory {
            if ((firstBody.node?.position.y)! - playerBaseline) <= secondBody.node?.position.y {
                goToScoreView()
            }
        }
    }
    
    func setupPlayer() {
        
        let playerTexture = SKTexture(imageNamed: "isaac")
        playerTexture.filteringMode = .Nearest
        
        player = SKSpriteNode(texture: playerTexture)
        player.setScale(0.75)
        playerBaseline = (groundNode.size.height / 2) + (player.size.height / 2)
        player.position = CGPointMake(CGRectGetMinX(self.frame) + (player.size.width) + (player.size.width / 4), self.playerBaseline)
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody!.dynamic = true
        player.physicsBody!.allowsRotation = false
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = spikeCategory | boxCategory | groundCategory
        player.physicsBody?.contactTestBitMask = spikeCategory | boxCategory | groundCategory
        player.name = "player"
        
        self.addChild(player)
    }
    
    func setupGround() {
        
        let groundTexture = SKTexture(imageNamed: "ground")
        
        let groundTextureSize = groundTexture.size()
        let groundTextureWidth = groundTextureSize.width
        let groundTextureHeight = groundTextureSize.height
        groundHeight = groundTextureHeight / 2
        
        let moveGroundSprite = SKAction.moveByX(-groundTextureWidth * 2.0, y: 0, duration: NSTimeInterval(0.02 * groundTextureWidth * 2.0))
        let resetGroundSprite = SKAction.moveByX(groundTextureWidth * 2.0, y: 0, duration: 0)
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        groundTexture.filteringMode = .Nearest
        
        for var i:CGFloat = 0; i < (8 + self.frame.size.width / (groundTextureWidth * 2.0)); i++ {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0)
            sprite.runAction(moveGroundSpritesForever)
            self.scrollNode.addChild(sprite)
        }
        
        self.groundNode.position = CGPointMake(0, 0)
        self.groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTextureHeight * 2))
        self.groundNode.physicsBody?.dynamic = false
        self.groundNode.physicsBody?.categoryBitMask = groundCategory
        groundNode.name = "ground"
        
        self.addChild(groundNode)
        self.addChild(scrollNode)
        
    }
    
    func random() -> UInt32 {
        
        let range = UInt32(0.1)...UInt32(10)
        return range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1)
        
    }
    
    func spawnBoxes() {
        boxTexture = SKTexture(imageNamed: "box")
        boxTexture.filteringMode = .Nearest
        
        let spawn = SKAction.performSelector(#selector(setupBoxes), onTarget: self)
        let delay = SKAction.waitForDuration(0.5)
        let spawnThenDelay = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        
        let distanceToMove = self.frame.size.width + 2 * boxTexture.size().width
        //actualduration: 0.01 * Double(distanceToMove)
        let moveBoxes = SKAction.moveByX(-distanceToMove, y: 0, duration: 0.01 * Double(distanceToMove))
        let removeBoxes = SKAction.removeFromParent()
        moveBoxesAndRemove = SKAction.sequence([moveBoxes,removeBoxes])
        
        
        self.runAction(spawnThenDelayForever)
        self.addChild(boxNode)
    }
    
    func setupBoxes() {
        for box in boxArray {
            if box.position.x <= 0 {
                boxArray.removeAtIndex(boxArray.indexOf(box)!)
            }
        }
        if levelSpot < levelArray?.count{
            var levelXAdder = CGFloat(0)
            var levelYAdder = CGFloat(0)
            if (levelArray![levelSpot] as! Int) > 9 {
                let levelModifier = levelArray![levelSpot] as! Int
                let x = levelModifier - (levelModifier % 10)
                let y = levelModifier % 10
                let width = Int(self.boxNode.frame.width)
                levelXAdder = CGFloat(x * width)
                levelYAdder = CGFloat(y * 50)
            }
            else {
                levelYAdder = CGFloat(levelArray![levelSpot] as! Int * 50)
            }
            let boxNode = SKSpriteNode(texture: boxTexture)
            boxNode.setScale(1.5)
            
            boxNode.position = CGPointMake( self.frame.size.width + self.boxTexture.size().width * 2.0 + levelXAdder, self.frame.size.height * 0.4 - groundHeight + playerBaseline/4 + levelYAdder)
            boxNode.physicsBody = SKPhysicsBody(rectangleOfSize: boxNode.size)
            boxNode.physicsBody?.dynamic = false
            boxNode.physicsBody?.categoryBitMask = boxCategory
            
            boxNode.runAction(moveBoxesAndRemove)
            boxNode.name = "box\(levelSpot)"
            levelSpot += 1
            boxArray.append(boxNode)
            self.boxNode.addChild(boxNode)
        }
        if boxArray.isEmpty && outOfScene == false {
            goToScoreView()
        }
    }
    
    func restart() {
        removeAllChildren()
        removeAllActions()
        scoreTimer.invalidate()
        scoreLabel.removeFromSuperview()
    }
    
    func goToScoreView() {
        scoreClass.saveScores(score)
        outOfScene = true
        restart()
        let scene = StartScene(size: self.size)
        let skView = view! as SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.size = skView.bounds.size
        skView.presentScene(scene)
//        let gameView = self.view?.window?.rootViewController
//        gameView?.performSegueWithIdentifier("EndGameSegue", sender: nil)
        
    }
    
}