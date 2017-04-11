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
    var landHexVertexArray : [LandHexVertex] = []
    var landHexEdgeArray : [LandHexEdge] = []
    var landHexDictionary : Dictionary <Int, [(Int,Int)]> = [:] //dictionary with key number and value (col, row) of hex with that number
    let NumRows = 9

    //landhex neighbouring array coords difference
    let xOffset = [0, 1, 1, 0, -1, -1]
    let yEvenOffset = [1, 0, -1, -1, -1, 0]
    let yOddOffset = [1, 1, 0, -1, 0, 1]
    
    //vertex center's neighbour array coords
    let xEvenOffsetV = [-1, 0, 1, 0, -1, -1]
    let xOddOffsetV = [0, 1, 1, 1, 0, -1]
    let yOffsetV = [1, 1, 0, -1, -1, 0]
    
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
        placeTiles(tilesArray: tilesArray, onMainIsland: true, water: false, harbour: false)
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
        placeTiles(tilesArray: tilesArray2, onMainIsland: false, water: false, harbour: false)
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
        
        //init waterTiles
        
        //get tile layout
        guard let tilesArray3 = dictionary["waterTiles"] as? [[Int]] else { return }
        
        //place tiles
        placeTiles(tilesArray: tilesArray3, onMainIsland: false, water: true, harbour: false)
        
        //init harbourTiles
        
        //get tile layout
        guard let tilesArray4 = dictionary["harbourTiles"] as? [[Int]] else { return }
        
        //place tiles
        placeTiles(tilesArray: tilesArray4, onMainIsland: false, water: false, harbour: true)
        
        //init all hex attributes
        initHexAttributes()
    }
    
    //takes in a 2d int tile array and initialises and places the tile in landBackground with a valid tile type
    func placeTiles(tilesArray : [[Int]], onMainIsland: Bool, water: Bool, harbour: Bool) {
        var harbourCounter = 0
        
        for (row, rowArray) in tilesArray.enumerated() {
            let tileRow = NumRows - row - 1
            for (column, value) in rowArray.enumerated() {
                if (water) {
                    if value == 0 {
                        let hex = LandHex(column: column, row: tileRow, type : "water", onMainIsland: onMainIsland, water: true)
                        landHexArray.append(hex)
                    }
                } else if (harbour) {
                    if value == 1 {
                        let hex = landHexArray.first(where: {$0.column == column && $0.row == tileRow})
                        switch harbourCounter {
                        case 0: hex?.harbourType = .General
                                landBackground.setTileGroup(terrainTiles.tileGroups[8], forColumn: column, row: tileRow)
                        case 1: hex?.harbourType = .Stone
                                landBackground.setTileGroup(terrainTiles.tileGroups[10], forColumn: column, row: tileRow)
                        case 2: hex?.harbourType = .Brick
                                landBackground.setTileGroup(terrainTiles.tileGroups[13], forColumn: column, row: tileRow)
                        case 3: hex?.harbourType = .Wheat
                                landBackground.setTileGroup(terrainTiles.tileGroups[11], forColumn: column, row: tileRow)
                        case 4: hex?.harbourType = .Wood
                                landBackground.setTileGroup(terrainTiles.tileGroups[12], forColumn: column, row: tileRow)
                        case 5: hex?.harbourType = .General
                                landBackground.setTileGroup(terrainTiles.tileGroups[7], forColumn: column, row: tileRow)
                        case 6: hex?.harbourType = .Sheep
                                landBackground.setTileGroup(terrainTiles.tileGroups[9], forColumn: column, row: tileRow)
                        case 7: hex?.harbourType = .General
                                landBackground.setTileGroup(terrainTiles.tileGroups[7], forColumn: column, row: tileRow)
                        default: break
                        }
                        harbourCounter+=1
                    }
                } else {
                    if value == 1 {
                        let currTile = getValidTileGroup()
                        landBackground.setTileGroup(currTile, forColumn: column, row: tileRow)
                        let hex = LandHex(column: column, row: tileRow, type : currTile.name!, onMainIsland: onMainIsland, water: false)
                        landHexArray.append(hex)
                    }
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
    
    //function that will initialize every hex's neighbours, corners and edges and init the corner and edge arrays in tileHandler
    func initHexAttributes() {
        
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
        for hex in landHexArray {
            let currPosition = landBackground.centerOfTile(atColumn: hex.column, row: hex.row)
            let centerVertexCol = Vertices.tileColumnIndex(fromPosition: currPosition) - 2 //need to subtract 2 from col for some reason. NOTED
            let centerVertexRow = Vertices.tileRowIndex(fromPosition: currPosition)
            hex.center = LandHexVertex(tile1: hex, column: centerVertexCol, row: centerVertexRow)
            hex.center?.isCenter = true
            
            //init robber
            if(hex.column == 7 && hex.row == (NumRows - 4)) {
                Vertices.setTileGroup(verticesTiles.tileGroups.first(where: {$0.name == "robber"}), forColumn: centerVertexCol, row: centerVertexRow)
                hex.center?.hasRobber = true
            }
            //init pirate
            if(hex.column == 4 && hex.row == (NumRows - 8)) {
                Vertices.setTileGroup(verticesTiles.tileGroups.first(where: {$0.name == "pirate"}), forColumn: centerVertexCol, row: centerVertexRow)
                hex.center?.hasPirate = true
            }
            
                var vertex : LandHexVertex
            for i in 0...5 {
                if (centerVertexRow % 2 == 0) {
                    if let neighbour = landHexVertexArray.first(where: {$0.column == centerVertexCol + xEvenOffsetV[i] && $0.row == centerVertexRow + yOffsetV[i]}) {
                        hex.corners.append(neighbour)
                        neighbour.addTile(landHex: hex)
                    } else {
                        vertex = LandHexVertex(tile1: hex, column: centerVertexCol + xEvenOffsetV[i], row: centerVertexRow + yOffsetV[i])
                        hex.corners.append(vertex)
                        landHexVertexArray.append(vertex)
                    }
                } else {
                    if let neighbour = landHexVertexArray.first(where: {$0.column == centerVertexCol + xOddOffsetV[i] && $0.row == centerVertexRow + yOffsetV[i]}) {
                        hex.corners.append(neighbour)
                        neighbour.addTile(landHex: hex)
                    } else {
                        vertex = LandHexVertex(tile1: hex, column: centerVertexCol + xOddOffsetV[i], row: centerVertexRow + yOffsetV[i])
                        hex.corners.append(vertex)
                        landHexVertexArray.append(vertex)
                    }
                }
            }
            
            //init harbour
            var harbourCounter = 0
            for _ in 0...5 {
                if(hex.harbourType != nil) {
                    switch harbourCounter {
                    case 0: hex.corners[2].isHarbour = true
                            hex.corners[2].harbourType = hex.harbourType
                            hex.corners[3].isHarbour = true
                            hex.corners[3].harbourType = hex.harbourType
                    case 1: hex.corners[4].isHarbour = true
                            hex.corners[4].harbourType = hex.harbourType
                            hex.corners[5].isHarbour = true
                            hex.corners[5].harbourType = hex.harbourType
                    case 2: hex.corners[3].isHarbour = true
                            hex.corners[3].harbourType = hex.harbourType
                            hex.corners[4].isHarbour = true
                            hex.corners[4].harbourType = hex.harbourType
                    case 3: hex.corners[3].isHarbour = true
                            hex.corners[3].harbourType = hex.harbourType
                            hex.corners[4].isHarbour = true
                            hex.corners[4].harbourType = hex.harbourType
                    case 4: hex.corners[2].isHarbour = true
                            hex.corners[2].harbourType = hex.harbourType
                            hex.corners[3].isHarbour = true
                            hex.corners[3].harbourType = hex.harbourType
                    case 5: hex.corners[0].isHarbour = true
                            hex.corners[0].harbourType = hex.harbourType
                            hex.corners[1].isHarbour = true
                            hex.corners[1].harbourType = hex.harbourType
                    case 6: hex.corners[5].isHarbour = true
                            hex.corners[5].harbourType = hex.harbourType
                            hex.corners[0].isHarbour = true
                            hex.corners[0].harbourType = hex.harbourType
                    case 7: hex.corners[0].isHarbour = true
                            hex.corners[0].harbourType = hex.harbourType
                            hex.corners[1].isHarbour = true
                            hex.corners[1].harbourType = hex.harbourType
                    default: break
                    }
                    harbourCounter+=1
                }
            }
        }
        
        //init hex edges
        for hex in landHexArray {
            let currPosition = landBackground.centerOfTile(atColumn: hex.column, row: hex.row)
            let centerEdgeCol = Edges.tileColumnIndex(fromPosition: currPosition)
            let centerEdgeRow = Edges.tileRowIndex(fromPosition: currPosition)
            
            var edge : LandHexEdge
            for i in 0...5 {
                if (centerEdgeCol % 2 == 0) {
                    if let neighbour = landHexEdgeArray.first(where: {$0.column == centerEdgeCol + xOffset[i] && $0.row == centerEdgeRow + yEvenOffset[i]}) {
                        hex.edges.append(neighbour)
                        neighbour.addTile(landHex: hex)
                    } else {
                        switch i {
                        case 0: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yEvenOffset[i], direction: directionType.flat, neighbour1: hex.corners[0], neighbour2: hex.corners[1])
                        case 1: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yEvenOffset[i], direction: directionType.lDiagonal, neighbour1: hex.corners[1], neighbour2: hex.corners[2])
                        case 2: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yEvenOffset[i], direction: directionType.rDiagonal, neighbour1: hex.corners[2], neighbour2: hex.corners[3])
                        case 3: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yEvenOffset[i], direction: directionType.flat, neighbour1: hex.corners[3], neighbour2: hex.corners[4])
                        case 4: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yEvenOffset[i], direction: directionType.lDiagonal, neighbour1: hex.corners[4], neighbour2: hex.corners[5])
                        //5
                        default: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yEvenOffset[i], direction: directionType.rDiagonal, neighbour1: hex.corners[5], neighbour2: hex.corners[0])
                        }
                        hex.edges.append(edge)
                        landHexEdgeArray.append(edge)
                    }
                } else {
                    if let neighbour = landHexEdgeArray.first(where: {$0.column == centerEdgeCol + xOffset[i] && $0.row == centerEdgeRow + yOddOffset[i]}) {
                        hex.edges.append(neighbour)
                        neighbour.addTile(landHex: hex)
                    } else {
                        switch i {
                        case 0: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yOddOffset[i], direction: directionType.flat, neighbour1: hex.corners[0], neighbour2: hex.corners[1])
                        case 1: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yOddOffset[i], direction: directionType.lDiagonal, neighbour1: hex.corners[1], neighbour2: hex.corners[2])
                        
                        case 2: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yOddOffset[i], direction: directionType.rDiagonal, neighbour1: hex.corners[2], neighbour2: hex.corners[3])
                        case 3: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yOddOffset[i], direction: directionType.flat, neighbour1: hex.corners[3], neighbour2: hex.corners[4])
                        case 4: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yOddOffset[i], direction: directionType.lDiagonal, neighbour1: hex.corners[4], neighbour2: hex.corners[5])
                        //5
                        default: edge = LandHexEdge(tile1: hex, column: centerEdgeCol + xOffset[i], row: centerEdgeRow + yOddOffset[i], direction: directionType.rDiagonal, neighbour1: hex.corners[5], neighbour2: hex.corners[0])
                        }
                        hex.edges.append(edge)
                        landHexEdgeArray.append(edge)
                    }
                }
            }
        }
        
        //init vertex neighbourEdges and neighbourVertices
        for hex in landHexArray {
            for i in 0...5 {
                let vertex = hex.corners[i]
                if( vertex.neighbourVertices.count == 3 && vertex.neighbourEdges.count == 3) {continue}
                switch i {
                case 0:
                    vertex.neighbourVertices.append(hex.corners[5])
                    vertex.neighbourEdges.append(hex.edges[5])
                    vertex.neighbourVertices.append(hex.neighbouringTiles[5]?.corners[1])
                    vertex.neighbourEdges.append(hex.neighbouringTiles[5]?.edges[1])
                    vertex.neighbourVertices.append(hex.corners[1])
                    vertex.neighbourEdges.append(hex.edges[0])
                case 1:
                    vertex.neighbourVertices.append(hex.corners[0])
                    vertex.neighbourEdges.append(hex.edges[0])
                    vertex.neighbourVertices.append(hex.neighbouringTiles[0]?.corners[2])
                    vertex.neighbourEdges.append(hex.edges[2])
                    vertex.neighbourVertices.append(hex.corners[2])
                    vertex.neighbourEdges.append(hex.edges[1])
                case 2:
                    vertex.neighbourVertices.append(hex.corners[3])
                    vertex.neighbourEdges.append(hex.edges[2])
                    vertex.neighbourVertices.append(hex.corners[1])
                    vertex.neighbourEdges.append(hex.edges[1])
                    vertex.neighbourVertices.append(hex.neighbouringTiles[2]?.corners[1])
                    vertex.neighbourEdges.append(hex.neighbouringTiles[2]?.edges[0])
                case 3:
                    vertex.neighbourVertices.append(hex.corners[4])
                    vertex.neighbourEdges.append(hex.edges[3])
                    vertex.neighbourVertices.append(hex.corners[2])
                    vertex.neighbourEdges.append(hex.edges[2])
                    vertex.neighbourVertices.append(hex.neighbouringTiles[2]?.corners[4])
                    vertex.neighbourEdges.append(hex.neighbouringTiles[2]?.edges[4])
                case 4:
                    vertex.neighbourVertices.append(hex.neighbouringTiles[4]?.corners[3])
                    vertex.neighbourEdges.append(hex.neighbouringTiles[4]?.edges[2])
                    vertex.neighbourVertices.append(hex.corners[5])
                    vertex.neighbourEdges.append(hex.edges[4])
                    vertex.neighbourVertices.append(hex.corners[3])
                    vertex.neighbourEdges.append(hex.edges[3])
                default: //5
                    vertex.neighbourVertices.append(hex.neighbouringTiles[4]?.corners[0])
                    vertex.neighbourEdges.append(hex.neighbouringTiles[4]?.edges[0])
                    vertex.neighbourVertices.append(hex.corners[0])
                    vertex.neighbourEdges.append(hex.edges[5])
                    vertex.neighbourVertices.append(hex.corners[4])
                    vertex.neighbourEdges.append(hex.edges[4])
                }
            }
        }
    }
    
    //function that will redraw landBackground and Numbers using new landHexArray and landHexDictionary
    func updateGUI() {
        for entry in landHexDictionary {
            for (column, tileRow) in entry.value {
                let numberTile = numberTiles.tileGroups.first(where: {$0.name == "\(entry.key)"})
                Numbers.setTileGroup(numberTile, forColumn: column, row: tileRow)
                let hex = landHexArray.first(where: {$0.column == column && $0.row == tileRow})
                let terrainType = hex?.type?.rawValue
                let terrainTile = terrainTiles.tileGroups.first(where: {$0.name == terrainType!})
                if(hex?.harbourType == nil) { landBackground.setTileGroup(terrainTile, forColumn: column, row: tileRow) }
            }
        }
    }
}
