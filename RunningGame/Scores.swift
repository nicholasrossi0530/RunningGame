//
//  Scores.swift
//  RunningGame
//
//  Created by Nick Rossi on 4/28/16.
//  Copyright © 2016 Rossi. All rights reserved.
//

import Foundation

class Scores {
    
    func saveScores(score: Int) {
        let scoreSave = NSUserDefaults.standardUserDefaults()
        var scoreArray = scoreSave.arrayForKey("scores")
        scoreArray?.append(score)
        scoreSave.setValue(scoreArray, forKey: "scores")
    }
    
    func getScores() -> [Int] {
        let scoreSave = NSUserDefaults.standardUserDefaults()
        let scoreArray = scoreSave.arrayForKey("scores")
        return scoreArray as! [Int]
    }
    
}