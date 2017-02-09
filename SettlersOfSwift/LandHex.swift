//
//  LandHex.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-02-07.
//  Copyright © 2017 Comp361. All rights reserved.
//

import SpriteKit

class LandHex {
    var column: Int
    var row: Int
    var tile: SKTileDefinition
    var number: Int
    var neighbouringTiles = [LandHex?]() //0 is top, 1 is top right, 2 is bot right... nil indicates water tile
    var corners = [AnyObject]() //object on corner of hex i.e. port, city, settlement etc...
    var edges = [AnyObject]() //TODO: change road object when created
    
    
    init(column:Int, row: Int, tile: SKTileDefinition, number: Int) {
        self.column = column
        self.row = row
        self.tile = tile
        self.number = number
    }
}
