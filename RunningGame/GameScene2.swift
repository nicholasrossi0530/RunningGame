//
//  GameScene2.swift
//  RunningGame
//
//  Created by Rossi on 3/25/16.
//  Copyright © 2016 Rossi. All rights reserved.
//

import SpriteKit

class GameScene2: SKScene, SKPhysicsContactDelegate  {
    
    var player: SKSpriteNode!
    var groundNode = SKSpriteNode()
    var scrollNode = SKNode()
    var groundSpeed = 5
    var boxNode = SKSpriteNode()
    
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
    
    
    
    override func didMoveToView(view: SKView) {
        
        setupPhysics()
        setupGround()
        setupPlayer()
        setupBoxes()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        view.addGestureRecognizer(longPressRecognizer)
    }
    
    override func update(currentTime: NSTimeInterval) {
        boxRunner()
    }
    
    func boxRunner() {
        
        for (box,boxStatus) in self.boxStatuses {
            
            let thisBox = self.childNodeWithName(box)
            if boxStatus.shouldRunBlock() {
                boxStatus.timeGapforNextRun = random()
                boxStatus.currentInterval = 0
                boxStatus.isRunning = true
            }
            if boxStatus.isRunning{
                
                if thisBox?.position.x > boxMaxX {
                    thisBox?.position.x -= CGFloat(groundSpeed)
                }
                else{
                    thisBox?.position.x = self.originalBoxPositionX
                    boxStatus.isRunning = false
                }
                
            }
            else {
                boxStatus.currentInterval++
            }
            
        }
        
    }
    
    func setupPhysics() {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, -5)
        //physicsWorld.speed = 3
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if onGround == true {
            playerPositionY = player.position.y
            player.physicsBody?.velocity = CGVectorMake(0, 0)
            player.physicsBody?.applyImpulse(CGVectorMake(0, 40))
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
    }
    
    func setupPlayer() {
        
        let playerTexture = SKTexture(imageNamed: "isaac")
        playerTexture.filteringMode = .Nearest
        
        player = SKSpriteNode(texture: playerTexture)
        player.setScale(0.75)
        playerBaseline = (groundNode.size.height / 2) + (player.size.height / 2)
        //player.position = CGPointMake(self.frame.size.width * 0.35, self.frame.size.height * 0.5)
        player.position = CGPointMake(CGRectGetMinX(self.frame) + (player.size.width) + (player.size.width / 4), self.playerBaseline)
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody!.dynamic = true
        player.physicsBody!.allowsRotation = false
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = spikeCategory | boxCategory | groundCategory
        player.physicsBody?.contactTestBitMask = spikeCategory | boxCategory | groundCategory
        
        self.addChild(player)
    }
    
    func setupGround() {
        
        let groundTexture = SKTexture(imageNamed: "ground")
        
        let groundTextureSize = groundTexture.size()
        let groundTextureWidth = groundTextureSize.width
        let groundTextureHeight = groundTextureSize.height
        
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
        
        
        self.addChild(groundNode)
        self.addChild(scrollNode)
        
    }
    
    func random() -> UInt32 {
        
        let range = UInt32(50)...UInt32(200)
        return range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1)
        
    }
    
    var boxStatuses:Dictionary<String,BoxStatus> = [:]
    
    func setupBoxes() {
        
        let boxTexture = SKTexture(imageNamed: "box")
        boxNode.position = CGPointMake(CGRectGetMaxX(self.frame) + boxTexture.size().width, playerBaseline)
        boxNode.texture = boxTexture
        
        self.boxNode.physicsBody = SKPhysicsBody(rectangleOfSize: boxNode.size)
        self.boxNode.physicsBody?.dynamic = false
        self.boxNode.physicsBody?.categoryBitMask = boxCategory
        self.boxNode.physicsBody?.collisionBitMask = playerCategory
        self.boxNode.physicsBody?.contactTestBitMask = playerCategory
        
        self.boxNode.name = "box"
        
        boxStatuses["box"] = BoxStatus(isRunning: false, timeGapForNextRun: random(), currentInterval: UInt32(0))
        boxMaxX = 0 - boxNode.size.width / 2
        originalBoxPositionX = boxNode.position.x
        
        self.addChild(boxNode)
        
    }
    
}