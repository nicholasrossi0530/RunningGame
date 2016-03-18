//
//  Utilities.swift
//  RunningGame
//
//  Created by Rossi on 3/17/16.
//  Copyright © 2016 Rossi. All rights reserved.
//

import SpriteKit
import Foundation

class Utilities{

    class func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if(value > max) {
            return max
        }
        else if(value < min){
            return min
        }
        else{
            return value
        }
    }
}
