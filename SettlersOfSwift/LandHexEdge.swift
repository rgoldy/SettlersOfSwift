//
//  LandHexEdge.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-02-09.
//  Copyright © 2017 Comp361. All rights reserved.
//

import SpriteKit

enum directionType:String {
    case flat
    case lDiagonal
    case rDiagonal
}

//class to reperesent a LandHexEdge with its respectve attributes
class LandHexEdge {
    var tile1: LandHex
    var tile2: LandHex?
    var column: Int
    var row: Int
    var edgeObject : edgeObject?
    var neighbourVertex1 : LandHexVertex
    var neighbourVertex2 : LandHexVertex
    var direction : directionType

    init(tile1: LandHex, column : Int, row : Int, direction : directionType, neighbour1 : LandHexVertex, neighbour2 : LandHexVertex) {
        self.tile1 = tile1
        self.column = column
        self.row = row
        self.direction = direction
        neighbourVertex1 = neighbour1
        neighbourVertex2 = neighbour2
    }
    
    func addTile(landHex: LandHex) {
        if(tile2 != nil) {
            print("current edge already has 2 tiles.")
        }
        tile2 = landHex
    }
}
