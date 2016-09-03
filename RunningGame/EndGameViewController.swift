//
//  EndScene.swift
//  RunningGame
//
//  Created by Nick Rossi on 4/18/16.
//  Copyright © 2016 Rossi. All rights reserved.
//

import UIKit
import SpriteKit

class EndGameViewController: UITableViewController {
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
    }
    
    override func viewDidAppear(animated: Bool) {
        table.reloadData()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScoreCell")!
        let index = indexPath.row
        let defaults = NSUserDefaults.standardUserDefaults()
        let scores = defaults.arrayForKey("scores")
        let text = "\(scores![index]) points"
        cell.textLabel?.text = text
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let defaults = NSUserDefaults.standardUserDefaults()
        let scores = defaults.arrayForKey("scores")
        return scores!.count
    }

}
