//
//  StartScene.swift
//  RunningGame
//
//  Created by Rossi on 3/28/16.
//  Copyright © 2016 Rossi. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    
    let startButton = SKSpriteNode(imageNamed: "start")
    let titleLabel = SKSpriteNode(imageNamed: "title")
    
    override func didMoveToView(view: SKView) {
        self.startButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100)
        self.addChild(self.startButton)
        
        self.titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 100)
        self.addChild(self.titleLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.startButton {
                let scene = GameScene(size: self.size)
                let skView = view! as SKView
                skView.ignoresSiblingOrder = true
                scene.scaleMode = .ResizeFill
                scene.size = skView.bounds.size
                skView.presentScene(scene)
            }
        }
    }
}
