//
//  LandHex.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-02-07.
//  Copyright © 2017 Comp361. All rights reserved.
//

import SpriteKit

enum hexType:String {
    case wood
    case wheat
    case stone
    case sheep
    case brick
    case gold
    case water
}

//class to reperesent a land hex and its respective attributes, including references to its LandHexVertices and LandHexEdges
class LandHex {
    var column: Int
    var row: Int
    var type : hexType?
    var neighbouringTiles = [LandHex?]() //0 is top, 1 is top right, 2 is bot right... nil indicates water tile
    var corners = [LandHexVertex]() //object on corner of hex i.e. port, city, settlement etc..., 0 is top left, 1 is top right...
    var edges = [LandHexEdge]() //object on edge of hex i.e. boat or road, 0 is top, 1 is top right, 2 is bot right..
    var onMainIsland: Bool //bool to determine if a landhex is on the main island or not
    var water: Bool //bool to indicate if this tile is a water tile or not
    
    init(column:Int, row: Int, type : String, onMainIsland: Bool, water: Bool) {
        self.column = column
        self.row = row
        self.onMainIsland = onMainIsland
        self.water = water
        switch type {
        case "wood": self.type = hexType.wood
        case "wheat": self.type = hexType.wheat
        case "stone": self.type = hexType.stone
        case "sheep": self.type = hexType.sheep
        case "brick": self.type = hexType.brick
        case "gold": self.type = hexType.gold
        case "water": self.type = hexType.water
        default:
            self.type = nil
        }
    }
}
