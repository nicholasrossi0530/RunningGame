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
    
    override func didMoveToView(view: SKView) {
        self.startButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(self.startButton)
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
