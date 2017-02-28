//
//  LandHexVertex.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-02-09.
//  Copyright © 2017 Comp361. All rights reserved.
//

import SpriteKit

class LandHexVertex {
    var tile1: LandHex
    var tile2: LandHex
    var tile3: LandHex
    var position: CGPoint
    var currentObject: AnyObject?
    //var neighbours: [LandHexVertex] //array of 3 neighbouring vertices
    
    init(tile1: LandHex, tile2: LandHex, tile3: LandHex, position: CGPoint) {
        self.tile1 = tile1
        self.tile2 = tile2
        self.tile3 = tile3
        self.position = position
    }
}
