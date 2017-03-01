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
    var verticesTiles:SKTileSet!
    var Edges:SKTileMapNode!
    var edgesTiles:SKTileSet!
    var landHexArray:[LandHex] = []
    var landHexDictionary : Dictionary <Int, [(Int,Int)]> = [:] //dictionary with key number and value (col, row) of hex with that number
    let NumRows = 9

    //neighbouring array coords difference
    let xOffset = [0, 1, 1, 0, -1, -1]
    let yEvenOffset = [1, 0, -1, -1, -1, 0]
    let yOddOffset = [1, 1, 0, -1, 0, 1]
    
    //neighbouring vertex array coords
    let xChangeVertex = [-1, 0, 1, 0, -1, -1]
    let yChangeVertex = [-1, -1, 0, 1, 1, 0]
    
    //init initial tile values
    var tileValues : Dictionary<String, Int> = [:]
    var numberTileValues : Dictionary<String, Int> = [:]
    
    //will set current scene nodes to the initialized ones from the gamescene
    init(waterBackground : SKTileMapNode, landBackground: SKTileMapNode, Numbers : SKTileMapNode, Vertices : SKTileMapNode, terrainTiles : SKTileSet, numberTiles : SKTileSet, verticesTiles : SKTileSet, Edges : SKTileMapNode, edgesTiles : SKTileSet) {
        self.waterBackground = waterBackground
        self.landBackground = landBackground
        self.Numbers = Numbers
        self.terrainTiles = terrainTiles
        self.numberTiles = numberTiles
        self.Vertices = Vertices
        self.verticesTiles = verticesTiles
        self.Edges = Edges
        self.edgesTiles = edgesTiles
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
        placeTiles(tilesArray: tilesArray)
        _ = placeNumberTiles(tilesArray: tilesArray)
        
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
        placeTiles(tilesArray: tilesArray2)
        _ = placeNumberTiles(tilesArray: tilesArray2)
        
        //init landHexDictionary
        for row in 0...NumRows-1 {
            for col in 0...NumRows-1 {
                let numberString = Numbers.tileGroup(atColumn: col, row: row)?.name!
                if (numberString != nil) {
                    let number = Int(numberString!)!
                    if(landHexDictionary[number] == nil) { landHexDictionary[number] = [] }
                    landHexDictionary[number]!.append((col, row))
                }
            }
        }
        
//        for entry in landHexDictionary {
//            print ("\(entry.key) -   \(entry.value)")
//        }
        
        //set neighbouring tiles in every hex
        for hex in landHexArray {
            for i in 0...5 {
                if(hex.column % 2 == 0) {
                    if let neighbour = landHexArray.first(where: {$0.column == hex.column + xOffset[i] && $0.row == hex.row + yEvenOffset[i]}) {
                        hex.neighbouringTiles.append(neighbour)
                    } else {
                        hex.neighbouringTiles.append(nil)
                    }
                } else {
                    if let neighbour = landHexArray.first(where: {$0.column == hex.column + xOffset[i] && $0.row == hex.row + yOddOffset[i]}) {
                        hex.neighbouringTiles.append(neighbour)
                    } else {
                        hex.neighbouringTiles.append(nil)
                    }
                }
            }
        }
        
        //init hex vertices
        
        //init hex
        
       
    }
    
    //takes in a 2d int tile array and initialises and places the tile in landBackground with a valid tile type
    func placeTiles(tilesArray : [[Int]]) {
        for (row, rowArray) in tilesArray.enumerated() {
            let tileRow = NumRows - row - 1
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    let currTile = getValidTileGroup()
                    landBackground.setTileGroup(currTile, forColumn: column, row: tileRow)
                    let hex = LandHex(column: column, row: tileRow, tile: landBackground.tileDefinition(atColumn: column, row: tileRow)!)
                    landHexArray.append(hex)
                }
            }
        }
    }
    
    //recursive function for setting number tiles
    func placeNumberTiles(tilesArray : [[Int]]) -> Bool {
        for (row, rowArray) in tilesArray.enumerated() {
            let tileRow = NumRows - row - 1
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    var used : [Int] = []
                    for _ in 0...9 { //repeat a total of 10 times before returning false, to try all 10 possible numbers
                        let currNumberTile = getValidNumberTileGroup()
                        let currNumber = Int(currNumberTile.name!)!
                        
                        //if already used, continue
                        if(used.contains(currNumber)) {
                            incrementNumberTileValue(name : currNumberTile.name!)
                            continue
                        }
                        
                        //if is a red number and neighbours contain a red number, continue
                        if ((currNumber == 6 || currNumber == 8) && neighbourContainsRedNumber(col: column, row: tileRow)) {
                            used.append(currNumber)
                            incrementNumberTileValue(name : currNumberTile.name!)
                            continue
                        }
                        
                        //otherwise, set the number tile, set current location of 2d array to 0 and recursively call
                        Numbers.setTileGroup(currNumberTile, forColumn: column, row: tileRow)
                        
                        var newArray = tilesArray
                        newArray[row][column] = 0
                        
                        if (placeNumberTiles(tilesArray: newArray)) {
                            //empty array for memory efficiency
                            newArray.removeAll()
                            return true
                        }
                        else {
                            used.append(currNumber)
                            incrementNumberTileValue(name : currNumberTile.name!)
                        }
                    }
                    return false
                }
            }
        }
        return true
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
    
    //will add 1 to a numberTileValue, to be used after a failed recursive call
    func incrementNumberTileValue(name: String) {
        numberTileValues[name] = numberTileValues[name]! + 1
    }

    //returns true if a neighbouring number is 6 or 8
    func neighbourContainsRedNumber(col : Int, row : Int) -> Bool {
        var neighbourName : String?
        for i in 0...5 {
            if (col % 2 == 0) {
                neighbourName = Numbers.tileGroup(atColumn: col + xOffset[i], row: row + yEvenOffset[i])?.name!
            } else {
                neighbourName = Numbers.tileGroup(atColumn: col + xOffset[i], row: row + yOddOffset[i])?.name!
            }
            if (neighbourName == "6" || neighbourName == "8") { return true }
        }
        return false
    }
}
