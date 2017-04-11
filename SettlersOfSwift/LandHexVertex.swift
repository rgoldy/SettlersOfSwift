//
//  LandHexVertex.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-02-09.
//  Copyright © 2017 Comp361. All rights reserved.
//

import SpriteKit

//class to reperesent a LandHexVertex with its respectve attributes
class LandHexVertex {
    var tile1: LandHex
    var tile2: LandHex?
    var tile3: LandHex?
    var column: Int
    var row: Int
    var cornerObject : cornerObject?
    var neighbourVertices: [LandHexVertex?] = []//array of 3 neighbouring vertices
    var neighbourEdges: [LandHexEdge?] = [] //array of 3 neighbouring vertices
    var isHarbour : Bool = false
    var harbourType : harbourType?
    var isCenter: Bool = false
    var hasRobber: Bool = false
    var hasPirate: Bool = false
    var isValidFish: Bool = false
    
    init(tile1: LandHex, column : Int, row : Int) {
        self.tile1 = tile1
        self.column = column
        self.row = row
    }
    
    func addTile(landHex: LandHex) {
        if (tile2 == nil) {
            tile2 = landHex
        } else {
            tile3 = landHex
        }
    }
}
