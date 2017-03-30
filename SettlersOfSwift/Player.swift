//
//  Player.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-03-01.
//  Copyright © 2017 Comp361. All rights reserved.
//

//color enum
enum playerColor:String {
    case Red
    case Blue
    case Orange
}

//class which represents each player and it's respective attributes
class Player {
    var wood = 0
    var wheat = 0
    var stone = 0
    var sheep = 0
    var brick = 0
    var gold = 2
    
    var paper = 0
    var cloth = 0
    var coin = 0
    
    var fish : [FishToken] = []
    var hasOldBoot = false
    
    var victoryPoints = 0
    
    var name : String
    var longestRoad = 0
    var ownedCorners : [LandHexVertex] = []
    var ownedEdges : [LandHexEdge] = []
    var color : playerColor
    
    init(name : String, playerNumber : Int) {
        self.name = name
        switch playerNumber {
        case 1:
            color = playerColor.Blue
        case 2:
            color = playerColor.Orange
        default:
            color = playerColor.Red
        }
    }
    
    func getPlayerText() -> String {
        return "\(name) : Wood = \(wood), Wheat = \(wheat), Stone = \(stone), Sheep = \(sheep), Brick = \(brick), Gold = \(gold)"
    }
    
    func discardFish(numFish: Int) -> [FishToken] {
        let powerset = getPowerset(list: fish)
        for set in powerset {
            // get number of fish in the set
            var sum = 0
            for f in set {
                sum += f.value
            }
            
            // discard this set if it sums to the desired value
            if sum == numFish {
                var setIndex = 0
                for _ in 0..<self.fish.count {
                    for i in 0..<self.fish.count {
                        if setIndex < set.count && set[setIndex].value == self.fish[i].value {
                            self.fish.remove(at: i)
                            setIndex += 1
                        }
                    }
                }
                return set
            }
        }
        
        return []
    }
    
    func getPowerset(list: [FishToken]) -> [[FishToken]] {
        var powerset: [[FishToken]] {
            if list.count == 0 {
                return [list]
            }
            else {
                let tail = Array(list[1..<list.endIndex])
                let head = list[0]
                
                let withoutHead = getPowerset(list: tail)
                let withHead = withoutHead.map { $0 + [head] }
                
                return withHead + withoutHead
            }
        }
        return powerset
    }
}
