//
//  tileHandler.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-02-27.
//  Copyright © 2017 Comp361. All rights reserved.
//

import SpriteKit
import GameplayKit

//class to handle all the tiles
class tileHandler {
    //init scenenodes
    var waterBackground:SKTileMapNode!
    var landBackground:SKTileMapNode!
    var Numbers:SKTileMapNode!
    var terrainTiles:SKTileSet!
    var numberTiles:SKTileSet!
    var Vertices:SKTileMapNode!
    var landHexArray:[LandHex] = []
    
    let NumRows = 9

    //neighbouring array coords difference
    let xChange = [0, 1, 1, 0, -1, -1]
    let yChange = [1, 0, -1, -1, -1, 0]
    
    //init initial tile values
    var tileValues : Dictionary<String, Int> = [:]
    var numberTileValues : Dictionary<String, Int> = [:]
    
    //will set current scene nodes to the initialized ones from the gamescene
    init(waterBackground : SKTileMapNode, landBackground: SKTileMapNode, Numbers : SKTileMapNode, Vertices : SKTileMapNode, terrainTiles : SKTileSet, numberTiles : SKTileSet) {
        self.waterBackground = waterBackground
        self.landBackground = landBackground
        self.Numbers = Numbers
        self.terrainTiles = terrainTiles
        self.numberTiles = numberTiles
        self.Vertices = Vertices
    }
    
    //function to read layout from json files and place correct amount of tiles
    func initTiles(filename: String) {
        
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else { return }
        
        //init main island
        
        //fill tileValue dictionary
        tileValues = Dictionary<String, Int>()
        tileValues["brick"] = (dictionary["brick"] as? Int)!
        tileValues["wheat"] = (dictionary["wheat"] as? Int)!
        tileValues["wood"] = (dictionary["wood"] as? Int)!
        tileValues["sheep"] = (dictionary["sheep"] as? Int)!
        tileValues["stone"] = (dictionary["stone"] as? Int)!
        tileValues["gold"] = (dictionary["gold"] as? Int)!
        
        //fill numberTileValue dictionary
        numberTileValues = Dictionary<String, Int>()
        numberTileValues["2"] = (dictionary["2"] as? Int)!
        numberTileValues["3"] = (dictionary["3"] as? Int)!
        numberTileValues["4"] = (dictionary["4"] as? Int)!
        numberTileValues["5"] = (dictionary["5"] as? Int)!
        numberTileValues["6"] = (dictionary["6"] as? Int)!
        numberTileValues["8"] = (dictionary["8"] as? Int)!
        numberTileValues["9"] = (dictionary["9"] as? Int)!
        numberTileValues["10"] = (dictionary["10"] as? Int)!
        numberTileValues["11"] = (dictionary["11"] as? Int)!
        numberTileValues["12"] = (dictionary["12"] as? Int)!
        
        //get tile layout
        guard let tilesArray = dictionary["mainTiles"] as? [[Int]] else { return }
        
        //place tiles
        placeTiles(tilesArray: tilesArray);
        
        //init smallIslands
        
        //fill tileValue dictionary
        tileValues = Dictionary<String, Int>()
        tileValues["brick"] = (dictionary["ibrick"] as? Int)!
        tileValues["wheat"] = (dictionary["iwheat"] as? Int)!
        tileValues["wood"] = (dictionary["iwood"] as? Int)!
        tileValues["sheep"] = (dictionary["isheep"] as? Int)!
        tileValues["stone"] = (dictionary["istone"] as? Int)!
        tileValues["gold"] = (dictionary["igold"] as? Int)!
        
        //fill numberTileValue dictionary
        numberTileValues = Dictionary<String, Int>()
        numberTileValues["2"] = (dictionary["i2"] as? Int)!
        numberTileValues["3"] = (dictionary["i3"] as? Int)!
        numberTileValues["4"] = (dictionary["i4"] as? Int)!
        numberTileValues["5"] = (dictionary["i5"] as? Int)!
        numberTileValues["6"] = (dictionary["i6"] as? Int)!
        numberTileValues["8"] = (dictionary["i8"] as? Int)!
        numberTileValues["9"] = (dictionary["i9"] as? Int)!
        numberTileValues["10"] = (dictionary["i10"] as? Int)!
        numberTileValues["11"] = (dictionary["i11"] as? Int)!
        numberTileValues["12"] = (dictionary["i12"] as? Int)!
        
        //get tile layout
        guard let tilesArray2 = dictionary["islandTiles"] as? [[Int]] else { return }
        
        //place tiles
        placeTiles(tilesArray: tilesArray2);
        
        //set neighbouring tiles in every hex
        for hex in landHexArray {
            for i in 0...5 {
                if let neighbour = landHexArray.first(where: {$0.column == hex.column + yChange[i] && $0.row == hex.row + xChange[i]}) {
                    hex.neighbouringTiles.append(neighbour)
                } else {
                    hex.neighbouringTiles.append(nil)
                }
            }
        }
        
        //init hex vertices
    }
    
    //takes in a 2d int tile array and initialises and places the tile in landBackground witha valid tile type and number
    func placeTiles(tilesArray : [[Int]]) {
        for (row, rowArray) in tilesArray.enumerated() {
            let tileRow = NumRows - row - 1
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    let currTile = getValidTileGroup()
                    landBackground.setTileGroup(currTile, forColumn: column, row: tileRow)
                    let currNumberTile = getValidNumberTileGroup()
                    Numbers.setTileGroup(currNumberTile, forColumn: column, row: tileRow)
                    let hex = LandHex(column: column, row: tileRow, tile: landBackground.tileDefinition(atColumn: column, row: tileRow)!, number: Int(Numbers.tileDefinition(atColumn: column, row: tileRow)!.name!)!)
                    landHexArray.append(hex)
                }
            }
        }
    }
    
    //get a valid tile to put in game
    func getValidTileGroup() -> SKTileGroup {
        var random:Int
        var name:String
        
        //keep randomizing if all tiles of one type already used up
        repeat {
            random = Int(arc4random_uniform(6)) + 1
            name = terrainTiles.tileGroups[random].name!
        } while (tileValues[name] == 0)
        
        //get tile and decrement value by 1
        let tile = terrainTiles.tileGroups[random]
        tileValues[name] = tileValues[name]!-1
        
        return tile
    }
    
    //get a valid number tile to put in game
    func getValidNumberTileGroup() -> SKTileGroup {
        var random:Int
        var name:String
        
        //keep randomizing if all tiles of one type already used up
        repeat {
            random = Int(arc4random_uniform(10))
            name = numberTiles.tileGroups[random].name!
        } while (numberTileValues[name] == 0)
        
        //get tile and decrement value by 1
        let tile = numberTiles.tileGroups[random]
        numberTileValues[name] = numberTileValues[name]!-1
        
        return tile
    }

}
