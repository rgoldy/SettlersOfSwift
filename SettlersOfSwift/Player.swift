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
    var gold = 0
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
}
