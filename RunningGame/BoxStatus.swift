//
//  BlockStatus.swift
//  RunningGame
//
//  Created by Nick Rossi on 3/30/16.
//  Copyright © 2016 Rossi. All rights reserved.
//

import Foundation

class BoxStatus {
    var isRunning = false
    var timeGapforNextRun = UInt32(0)
    var currentInterval = UInt32(0)
    init(isRunning:Bool, timeGapForNextRun:UInt32, currentInterval:UInt32) {
        
        self.isRunning = isRunning
        self.timeGapforNextRun = timeGapForNextRun
        self.currentInterval = currentInterval
        
    }
    
    func shouldRunBlock() -> Bool {
        
        return self.currentInterval > self.timeGapforNextRun
        
    }
}
