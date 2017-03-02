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
//    let event = GKRandomDistribution.d6()
    
    //returns an array of integers [red, yellow, event]
    func rollDice() -> [Int] {
        return [red.nextInt(), yellow.nextInt()]
    }
    
}
