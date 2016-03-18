//
//  GameScene.swift
//  RunningGame
//
//  Created by Rossi on 3/17/16.
//  Copyright (c) 2016 Rossi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let sceneColor = SKColor(red: 128, green: 0, blue: 128, alpha: 1)
    let playerCat: UInt32 = 1<<0
    let boxCat: UInt32 = 1<<1
    let levelCat: UInt32 = 1<<2
    let scoreCat: UInt32 = 1<<3
    let boxGap: CGFloat = 150.0
    let message = "Click to start!"
    
    
    var player:SKSpriteNode!
    var scrollNode = SKNode()
    var groundNode = SKNode()
    var boxUpTexture = SKTexture(imageNamed: "box")
    var boxDownTexture = SKTexture(imageNamed: "box")
    var boxesNode = SKNode()
    var scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var startLabel = SKLabelNode(fontNamed: "Chalkduster")
    var score = 0
    var isGameOver = false
    var isStarted = false
    
    var moveBoxesAndRemove: SKAction!
    var makeSkyRed: SKAction!
    var makeSkyBlue: SKAction!
    var makeGameEnd: SKAction!
    

    
    override func didMoveToView(view: SKView) {
        
        view.paused = true
        
        self.backgroundColor = sceneColor
        
        self.physicsWorld.gravity = CGVectorMake(0, -4.9)
        self.physicsWorld.contactDelegate = self
        self.boxUpTexture.filteringMode = .Nearest
        self.boxDownTexture.filteringMode = .Nearest
        
        self.setUpStartLabel()
        self.player = setupPlayer()
        self.setupGround()
        self.setUpSkyLine()
        self.setupBoxes()
        
        self.makeGameEnd = SKAction.runBlock({self.isGameOver = true})
        
        self.makeSkyBlue = SKAction.runBlock({self.backgroundColor = self.sceneColor})
        
        self.makeSkyRed = SKAction.runBlock({self.backgroundColor = UIColor.redColor()})
        
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + (CGRectGetMidY(self.frame) / 2))
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.text = String(score)
        self.addChild(scoreLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if  !self.isStarted && self.scene!.view!.paused {
            self.isStarted = true
            self.scene!.view!.paused = false
            
            self.startLabel.removeFromParent()
        }
        
        if self.scrollNode.speed > 0 {
            for _: AnyObject in touches {
                self.player.physicsBody!.velocity = CGVectorMake(0,0)
                self.player.physicsBody!.applyImpulse(CGVectorMake(0, 40))
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if let myPlayer = self.player {
            self.player.zRotation = Utilities.clamp(-1, max: 0.5, value: myPlayer.physicsBody!.velocity.dy * (myPlayer.physicsBody?.velocity.dy < 0 ? 0.003 : 0.001))
        }
        if self.isGameOver {
            restart()
        }
    }
    
    func setUpStartLabel() {
        startLabel = SKLabelNode(text: self.message)
        startLabel.fontSize = 30
        startLabel.fontColor = UIColor.blackColor()
        startLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + (CGRectGetMidY(self.frame) / 3))
        
        self.addChild(startLabel)
    }
    
    func restart() {
        let s = GameScene(size: self.size)
        s.scaleMode = .AspectFill
        self.view?.presentScene(s)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if scrollNode.speed > 0 {
            if(contact.bodyA.categoryBitMask & scoreCat) == scoreCat || (contact.bodyB.categoryBitMask & scoreCat) == scoreCat {
                score++
                scoreLabel.text = String(score)
                
                scoreLabel.runAction(SKAction.sequence([SKAction.scaleTo(2.0, duration: NSTimeInterval(0.1)),SKAction.scaleTo(1.0, duration: NSTimeInterval(0.1))]))
            }
            else {
                self.scrollNode.speed = 0
                
                self.runAction(SKAction.sequence([self.makeSkyRed,SKAction.waitForDuration(NSTimeInterval(0.05)),self.makeSkyBlue,self.makeGameEnd]),withKey: "gameover")
            }
        }
    }
    
    
    func spawnBoxes() {
        let boxPair = SKNode()
        boxPair.position = CGPointMake(self.frame.size.width + self.boxUpTexture.size().width * 2.0, 0)
        boxPair.zPosition = -10
        let height = CGFloat(self.frame.size.height / 4)
        let y = CGFloat(Double(arc4random())) % height + height
        
        let boxDown = SKSpriteNode(texture: self.boxDownTexture)
        boxDown.setScale(2.0)
        boxDown.position = CGPointMake(0.0, y + boxDown.size.height + boxGap)
        boxDown.physicsBody = SKPhysicsBody(rectangleOfSize: boxDown.size)
        boxDown.physicsBody?.dynamic = false
        boxDown.physicsBody?.categoryBitMask = boxCat
        boxDown.physicsBody?.contactTestBitMask = playerCat
        boxPair.addChild(boxDown)
        
        let boxUp = SKSpriteNode(texture: self.boxUpTexture)
        boxUp.setScale(2.0)
        boxUp.position = CGPointMake(0.0, y)
        boxUp.physicsBody = SKPhysicsBody(rectangleOfSize: boxUp.size)
        boxUp.physicsBody?.dynamic = false
        boxUp.physicsBody?.categoryBitMask = boxCat
        boxUp.physicsBody?.contactTestBitMask = playerCat
        boxPair.addChild(boxUp)
        
        let contactNode = SKNode()
        contactNode.position = CGPointMake(boxDown.size.width + player.size.width / 2, CGRectGetMidY(self.frame))
        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(boxUp.size.width, self.frame.size.height))
        contactNode.physicsBody?.dynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCat
        contactNode.physicsBody?.contactTestBitMask = playerCat
        
        boxPair.addChild(contactNode)
        boxPair.runAction(moveBoxesAndRemove)
        self.boxesNode.addChild(boxPair)
        
    }
    
    func setupBoxes() {
        SKAction.runBlock({})
        let spawn = SKAction.runBlock({self.spawnBoxes()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * self.boxUpTexture.size().width)
        let moveBoxes = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        let removeBoxes = SKAction.removeFromParent()
        moveBoxesAndRemove = SKAction.sequence([moveBoxes, removeBoxes])
        
        self.runAction(spawnThenDelayForever)
        self.addChild(self.boxesNode)
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
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / (groundTextureWidth * 2.0); i++ {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.0)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0)
            sprite.runAction(moveGroundSpritesForever)
            self.scrollNode.addChild(sprite)
        }
        
        self.groundNode.position = CGPointMake(0, groundTextureHeight)
        self.groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTextureHeight * 2.0))
        self.groundNode.physicsBody!.dynamic = false
        self.groundNode.physicsBody!.categoryBitMask = levelCat
        
        self.addChild(groundNode)
        self.addChild(scrollNode)
    }
    
    func setupPlayer() -> SKSpriteNode {
        
        let playerTexture = SKTexture(imageNamed: "isaac")
        playerTexture.filteringMode = .Nearest
        
        let player = SKSpriteNode(texture: playerTexture)
        
        player.setScale(0.75)
        player.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
        
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody!.dynamic = true
        player.physicsBody!.allowsRotation = false
        player.physicsBody?.categoryBitMask = playerCat
        player.physicsBody?.collisionBitMask = levelCat | boxCat
        player.physicsBody?.contactTestBitMask = levelCat | boxCat
        
        self.addChild(player)
        return player
    }
    
    func setUpSkyLine(){
        
        let skyTexture = SKTexture(imageNamed: "sky")
        let groundTexture = SKTexture(imageNamed: "ground")
        
        let skyTextureSize = skyTexture.size()
        let skyTextureWidth = skyTextureSize.width
        
        let moveSkySprite = SKAction.moveByX(-skyTextureWidth * 2.0, y: 0, duration: NSTimeInterval(0.1 * skyTextureWidth * 2.0))
        let resetSkySprite = SKAction.moveByX(skyTextureWidth * 2.0, y: 0, duration: 0)
        let moveSkySpriteForever = SKAction.repeatActionForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
        skyTexture.filteringMode = .Nearest
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / (skyTextureWidth * 2.0); i++ {
            let sprite = SKSpriteNode(texture: skyTexture)
            sprite.setScale(2.0)
            sprite.zPosition = -20
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0 + groundTexture.size().height * 2.0)
            sprite.runAction(moveSkySpriteForever)
            self.scrollNode.addChild(sprite)
        }
    }
    

    
}
