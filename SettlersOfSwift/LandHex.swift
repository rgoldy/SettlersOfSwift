//
//  LandHex.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-02-07.
//  Copyright © 2017 Comp361. All rights reserved.
//

import SpriteKit

//class to reperesent a land hex and its respective attributes, including references to its LandHexVertices and LandHexEdges
class LandHex {
    var column: Int
    var row: Int
    var tile: SKTileDefinition
    var neighbouringTiles = [LandHex?]() //0 is top, 1 is top right, 2 is bot right... nil indicates water tile
    var corners = [LandHexVertex]() //object on corner of hex i.e. port, city, settlement etc..., 0 is top left, 1 is top right...
    var edges = [LandHexEdge]() //object on edge of hex i.e. boat or road, 0 is top, 1 is top right, 2 is bot right..
    
    init(column:Int, row: Int, tile: SKTileDefinition) { //, number: Int) {
        self.column = column
        self.row = row
        self.tile = tile
    }
}
