//
//  GameViewController.swift
//  RunningGame
//
//  Created by Rossi on 3/17/16.
//  Copyright (c) 2016 Rossi. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = StartScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
