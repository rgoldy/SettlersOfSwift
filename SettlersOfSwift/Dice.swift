//
//  Dice.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-03-02.
//  Copyright © 2017 Comp361. All rights reserved.
//

import GameplayKit

//class to represent the dice
class Dice {
    let red = GKRandomDistribution.d6()
    let yellow = GKRandomDistribution.d6()
    // let event = GKRandomDistribution.d6()
    
    var redValue = -1
    var yellowValue = -1
    // var eventValue: Int
    
    //returns an array of integers [red + yellow, event]
    func rollDice() -> [Int] {
        redValue = red.nextInt()
        yellowValue = yellow.nextInt()
        // eventValue = event.nextInt()
        
        return [redValue + yellowValue]
        // return [redValue + yellowValue, eventValue]
    }
    
}
