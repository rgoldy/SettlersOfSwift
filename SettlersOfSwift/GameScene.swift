//
//  GameScene.swift
//  SettlersOfSwift
//
//  Created by Riley Goldman on 1/25/17.
//  Written by Mario Youssef, 
//  Copyright © 2017 Comp361. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GamePhase : String {
    case Setup
    case placeFirstSettlement
    case placeFirstRoad
    case wait
    case placeSecondRoad
    case placeSecondSettlement
    case p1Turn
    case p2Turn
    case p3Turn
}

enum EventDieSides: Int {
    case BarbarianSideA = 1
    case BarbarianSideB = 2
    case BarbarianSideC = 3
    case PoliticsSide   = 4
    case SciencesSide   = 5
    case TradesSide     = 6
}

class GameScene: SKScene {
    
    //init scene nodes
    var cam:SKCameraNode!
    var currGamePhase = GamePhase.Setup
    let dice = Dice()
    var players: [Player] = []
    var currentPlayer = 0
    var myPlayerIndex = -1
    var fishDeck: [FishToken] = []
    
    //  NEED TO BE PASSED TO ALL PLAYERS TO ENSURE DECK CONSISTENCY
    
    var gameDeck = ProgressCardsType.generateNewGameDeck()
    
    let gameButton = UITextField()
    let cancelButton = UITextField()
    let buildUpgradeButton = UITextField()
    let buildRoadButton = UITextField()
    let buildShipButton = UITextField()
    let gameText = UITextField()
    let redDiceUI = UIImageView()
    let yellowDiceUI = UIImageView()
    let eventDiceUI = UIImageView()
    
    var rolled : Bool = false
    var buildSettlement : Bool = false
    var buildRoad : Bool = false
    var buildShip: Bool = false
    
    var oldBootButton = UIImageView()
    var showingBootMenu : Bool = false
    
    var tradeOpen : Bool = false
    var leftTradeItem : hexType?
    var rightTradeItem : hexType?
    
    //  SHOULD BE PASSED TO ALL PLAYERS SUCH THAT THEY DO NOT PLACE METROPOLIS BY ACCIDENT
    
    var politicsMetropolisPlaced = false
    var sciencesMetropolisPlaced = false
    var tradesMetropolisPlaced = false
    
    var maximaPoliticsImprovementReached = false
    var maximaSciencesImprovementReached = false
    var maximaTradesImprovementReached = false
    
    var detailsStarted = false
    
    //  END OF SEND TO ALL PLAYERS
    
    var requiredVictoryPoints = 13
    
    //init tile handler
    var handler : tileHandler!
    
    // Access to network manager
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var pirateRemoved = false
    var robberRemoved = false
    
    var barbariansDistanceFromCatan = 7
    
    override func didMove(to view: SKView) {
        //load tiles
        loadSceneNodes()
        
        //init cam
        cam = SKCameraNode()
        cam.xScale = 0.9
        cam.yScale = 0.9
        
        self.camera = cam
        self.addChild(cam)
        
        cam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        let verticalConstraint = SKConstraint.positionY(SKRange(lowerLimit: handler.waterBackground.frame.minY, upperLimit: handler.waterBackground.frame.maxY))
        let horizontalConstraint = SKConstraint.positionX(SKRange(lowerLimit: handler.waterBackground.frame.minX, upperLimit: handler.waterBackground.frame.maxX))
        
        verticalConstraint.enabled = true
        horizontalConstraint.enabled = true
        verticalConstraint.referenceNode = handler.waterBackground
        horizontalConstraint.referenceNode = handler.waterBackground
        
        cam.constraints = [horizontalConstraint, verticalConstraint]
        
        //init gesture recognizers
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanFrom(recognizer:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(recognizer:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        let edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleRightEdgeSwipe(recognizer:)))
        edgeSwipeGestureRecognizer.edges = .right
        view.addGestureRecognizer(edgeSwipeGestureRecognizer)
        
        //init UI
        
        gameButton.frame = CGRect(x: self.view!.bounds.width/12 * 10.5, y: self.view!.bounds.height/20.5, width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        gameButton.text = "End Turn"
        gameButton.font = UIFont(name: "Arial", size: 13)
        gameButton.backgroundColor = UIColor.gray
        gameButton.borderStyle = UITextBorderStyle.roundedRect
        gameButton.isUserInteractionEnabled = false
        gameButton.textAlignment = NSTextAlignment.center
        self.view?.addSubview(gameButton)
        
        cancelButton.frame = CGRect(x: self.view!.bounds.width * 0.025, y: self.view!.bounds.height/20.5, width: self.view!.bounds.width/7, height: self.view!.bounds.height/14)
        cancelButton.text = "Cancel Action"
        cancelButton.font = UIFont(name: "Arial", size: 13)
        cancelButton.backgroundColor = UIColor.gray
        cancelButton.borderStyle = UITextBorderStyle.roundedRect
        cancelButton.isUserInteractionEnabled = false
        cancelButton.textAlignment = NSTextAlignment.center
        self.view?.addSubview(cancelButton)
        
        redDiceUI.frame = CGRect(x: self.view!.bounds.width * 0.025, y: self.view!.bounds.height - self.view!.bounds.width/12, width: self.view!.bounds.width/12, height: self.view!.bounds.width/12)
        redDiceUI.image = UIImage(named: "red1")
        self.view?.addSubview(redDiceUI)
        
        yellowDiceUI.frame = CGRect(x: self.view!.bounds.width/11 + self.view!.bounds.width * 0.025, y: self.view!.bounds.height - self.view!.bounds.width/12, width: self.view!.bounds.width/12, height: self.view!.bounds.width/12)
        yellowDiceUI.image = UIImage(named: "yellow1")
        self.view?.addSubview(yellowDiceUI)
        
        eventDiceUI.frame = CGRect(x: self.view!.bounds.width * 0.182 + self.view!.bounds.width * 0.025, y: self.view!.bounds.height - self.view!.bounds.width/12, width: self.view!.bounds.width/12, height: self.view!.bounds.width/12)
        eventDiceUI.image = UIImage(named: "event1")
        self.view?.addSubview(eventDiceUI)
        
        oldBootButton.frame = CGRect(x: self.view!.bounds.width * 0.025, y: self.view!.bounds.height/20.5 + self.view!.bounds.height/13.5, width: self.view!.bounds.width/8, height: self.view!.bounds.width/12)
        oldBootButton.image = UIImage(named: "oldBoot")
    }
    
    func loadSceneNodes() {
        //load landBackground tiles
        guard let landBackground = childNode(withName: "LandBackground")
            as? SKTileMapNode else {
                fatalError("LandBackground node not loaded")
        }
        
        //load terrainTiles tile set
        guard let terrainTiles = SKTileSet(named: "Terrain Tiles") else {
            fatalError("terrainTiles node not loaded")
        }
        
        //load waterBackground tiles
        guard let waterBackground = childNode(withName: "WaterBackground")
            as? SKTileMapNode else {
                fatalError("WaterBackground node not loaded")
        }
        
        //load Numbers tiles
        guard let Numbers = childNode(withName: "Numbers")
            as? SKTileMapNode else {
                fatalError("Numbers node not loaded")
        }
        
        //load terrainTiles tile set
        guard let numberTiles = SKTileSet(named: "Number Values") else {
            fatalError("numberTiles node not loaded")
        }
        
        //load Vertices tiles
        guard let Vertices = childNode(withName: "Vertices")
            as? SKTileMapNode else {
                fatalError("Vertices node not loaded")
        }
        
        //load terrainTiles tile set
        guard let verticesTiles = SKTileSet(named: "Vertices") else {
            fatalError("Vertices tile set node not loaded")
        }
        
        //load Edges tiles
        guard let Edges = childNode(withName: "Edges")
            as? SKTileMapNode else {
                fatalError("Edges node not loaded")
        }
        
        //load terrainTiles tile set
        guard let edgesTiles = SKTileSet(named: "Edges") else {
            fatalError("Edges tile set node not loaded")
        }
        
        //init handler
        handler = tileHandler(waterBackground : waterBackground, landBackground: landBackground, Numbers : Numbers, Vertices : Vertices, terrainTiles : terrainTiles, numberTiles : numberTiles, verticesTiles : verticesTiles, Edges : Edges, edgesTiles : edgesTiles);
        
        //init tiles
        handler.initTiles(filename: "3player")
    }
    
    // Added by Riley
    func getBoardLayout() -> String {
        // Data identifier
        var board = "boardLayout."
        
        // Obtain hex info
        for hex in handler.landHexArray {
            var value = 0
            searching: for j in 2...12 {
                let positions = handler.landHexDictionary[j]
                if (positions == nil) { continue }
                for (col, rw) in positions! {
                    if (col == hex.column && rw == hex.row) {
                        value = j
                        break searching
                    }
                }
            }
            if (value == 0) {
                print("Unable to locate hex. <GameScene.swift - getBoardLayout()>")
            }
            
            var type: Int!
            switch hex.type! {
            case .wood: type = 0
            case .wheat: type = 1
            case .stone: type = 2
            case .sheep: type = 3
            case .brick: type = 4
            case .gold: type = 5
            case .fish: type = 7
            default: type = 6
            }
            
            board.append("\(hex.column),\(hex.row),\(type!),\(value);")
        }
        return board
    }
    
    // Added by Riley
    func setBoardLayout(encoding: String) {
        // Reset hex values
        handler.landHexDictionary.removeAll()
        
        // Obtain hex types and values
        let hexDataArray = encoding.components(separatedBy: ";").dropLast()
        for hexData in hexDataArray {
            let hexInfo = hexData.components(separatedBy: ",")
            let column = Int(hexInfo[0])
            let row = Int(hexInfo[1])
            let value = Int(hexInfo[3])!
            var type: hexType!
            switch hexInfo[2] {
                case "0": type = .wood
                case "1": type = .wheat
                case "2": type = .stone
                case "3": type = .sheep
                case "4": type = .brick
                case "5": type = .gold
                case "6": type = .water
                case "7": type = .fish
                default: type = .water
            }
            
            
            let hex = handler.landHexArray.first(where: {$0.column == column && $0.row == row})
            hex?.type = type
            
            if(handler.landHexDictionary[value] == nil) { handler.landHexDictionary[value] = [] }
            handler.landHexDictionary[value]!.append((column!, row!))
        }
    }
    
    func initPlayers() {
        let p1 = Player(name: appDelegate.networkManager.getName(), playerNumber: 0)
        players.append(p1)
        var playerInfo = "playerData.\(appDelegate.networkManager.getName()),\(0);"
        myPlayerIndex = 0
        
        var i = 1
        for peer in appDelegate.networkManager.session.connectedPeers {
            let p = Player(name: peer.displayName, playerNumber: i)
            players.append(p)
            playerInfo.append("\(peer.displayName),\(i);")
            i += 1
        }
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: playerInfo)
        if (!sent) {
            print ("failed to sync player info")
        }
        else {
            print ("successful sync player info")
        }
        
        currGamePhase = GamePhase.placeFirstSettlement
        gameText.text = "Place First Settlement"
        gameText.isHidden = false
    }
    
    func initFish() {
        for _ in 1...11 {
            fishDeck.append(FishToken(v: 1))
        }
        for _ in 1...10 {
            fishDeck.append(FishToken(v: 2))
        }
        for _ in 1...8 {
            fishDeck.append(FishToken(v: 3))
        }
        fishDeck.append(FishToken(v:0))
        
        shuffleFish(deck: fishDeck)
        sendFishDeck()
    }
    
    func setPlayers(info: String) {
        players.removeAll()
        let playersDataArray = info.components(separatedBy: ";").dropLast()
        for playersData in playersDataArray {
            let playerInfo = playersData.components(separatedBy: ",")
            let pName = playerInfo[0]
            let pNumb = Int(playerInfo[1])!
            players.append(Player(name: pName, playerNumber: pNumb))
        }
        for i in 1...players.count-1 {
            if (players[i].name == appDelegate.networkManager.getName()) {
                myPlayerIndex = i
                print ("I am player \(i+1)")
            }
        }
        
        currGamePhase = GamePhase.placeFirstSettlement
        gameText.text = "Place First Settlement"
    }
    
    //method to send message to other players and update the currentplayer
    func sendNewCurrPlayer() {
        let currPlayerInfo = "currPlayerData.\(currentPlayer)"
        
        if (currentPlayer == myPlayerIndex) {
            DispatchQueue.main.async {
                self.gameButton.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
            }
        }
        else {
            DispatchQueue.main.async {
                self.gameButton.backgroundColor = UIColor.gray
            }
        }
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: currPlayerInfo)
        if (!sent) {
            print ("failed to sync currentPlayer")
        }
        else {
            print ("successful sync currentPlayer")
        }
    }
    
    //set current player to message recieved
    func setNewCurrPlayer(info: String) {
        endTurn(player: currentPlayer)
        currentPlayer = Int(info)!
        
        if (currentPlayer == myPlayerIndex) {
            DispatchQueue.main.async {
                self.gameButton.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
            }
        }
        else {
            DispatchQueue.main.async {
                self.gameButton.backgroundColor = UIColor.gray
            }
        }
    }
    
    //method to send message to other players and update their gamephase
    func sendNewGamePhase(gamePhase : GamePhase) {
        let gamePhaseInfo = "gamePhaseData.\(gamePhase)"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: gamePhaseInfo)
        if (!sent) {
            print ("failed to sync gamePhase")
        }
        else {
            print ("successful sync gamePhase")
        }
    }
    
    //set currGamePhase to message recieved
    func setNewGamePhase(info: String) {
        currGamePhase = GamePhase(rawValue: info)!
    }
    
    //function that will place a corner object and set its owner then send info to other players
    func placeCornerObject(column : Int, row : Int, type : cornerType, setup: Bool) -> Bool {
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false }
        if (corner!.cornerObject != nil) { return false }
        if (type != .Knight && canPlaceCorner(corner: corner!) == false) { return false }
        //if (type == .Knight && !canPlaceKnight(corner: corner!)) { return false }
        if (corner!.tile1.onMainIsland == false) { return false }


        corner!.cornerObject = cornerObject(cornerType : type, owner: myPlayerIndex)
        if type == .Knight {
            players[currentPlayer].ownedKnights.append(corner!)
        }
        else {
            players[currentPlayer].ownedCorners.append(corner!)
        }
        
        var tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)"})
        
        var cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),\(type.rawValue),\(corner!.cornerObject!.strength),\(corner!.cornerObject!.isActive),\(corner!.cornerObject!.hasBeenUpgradedThisTurn),\(corner!.cornerObject!.didActionThisTurn)"
        
        if type == .City {
            tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.hasCityWall)"})
            
                cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),\(type.rawValue),\(corner!.cornerObject!.hasCityWall)"
        }
        else if type == .Knight {
            tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
        }
        
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        else {
            print ("successful sync cornerObject")
        }
        
        if (setup) {
            distributeResourcesOnSetup(vertex: corner!)
        }
        
        
        //check if corner is a harbour, update the trade ratio
        if corner!.isHarbour {
            switch (corner!.harbourType!) {
            case .Brick: players[currentPlayer].brickTradeRatio = 2
            case .Wheat: players[currentPlayer].wheatTradeRatio = 2
            case .Stone: players[currentPlayer].stoneTradeRatio = 2
            case .Sheep: players[currentPlayer].sheepTradeRatio = 2
            case .Wood: players[currentPlayer].woodTradeRatio = 2
            case .General:  if(players[currentPlayer].brickTradeRatio == 4) { players[currentPlayer].brickTradeRatio = 3 }
            if(players[currentPlayer].wheatTradeRatio == 4) { players[currentPlayer].wheatTradeRatio = 3 }
            if(players[currentPlayer].stoneTradeRatio == 4) { players[currentPlayer].stoneTradeRatio = 3 }
            if(players[currentPlayer].sheepTradeRatio == 4) { players[currentPlayer].sheepTradeRatio = 3 }
            if(players[currentPlayer].woodTradeRatio == 4) { players[currentPlayer].woodTradeRatio = 3 }
            }
        }
        
        if corner!.cornerObject!.type == .Settlement {
            give(victoryPoints: 1, to: currentPlayer)
        }
        else if corner!.cornerObject!.type == .City {
            give(victoryPoints: 2, to: currentPlayer)
        }
        else if corner!.cornerObject?.type == .Metropolis {
            give(victoryPoints: 4, to: currentPlayer)
        }
        
        return true
    }
    
    //function to check if a corner can be placed
    func canPlaceCorner(corner : LandHexVertex) -> Bool {
        for vertex in corner.neighbourVertices {
            if (vertex?.cornerObject != nil) {
                return false
            }
        }
        if(corner.tile1.type == hexType.water && corner.tile2?.type == hexType.water && corner.tile3?.type == hexType.water) { return false }
        return true
    }
    
    func canPlaceKnight(corner: LandHexVertex) -> Bool {
        if(corner.tile1.type == hexType.water && corner.tile2?.type == hexType.water && corner.tile3?.type == hexType.water) { return false }
        return true
    }
    
    func buildSettlement(column : Int, row : Int, valid: Bool) -> Bool {
        if (!valid) { return false }
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false}
        if (corner?.cornerObject != nil) { return false }
        if (!canPlaceCorner(corner: corner!)) { return false }
        if (!hasResourcesForNewSettlement()) { return false }
        
        var nextToRoad : Bool = false
        for edge in corner!.neighbourEdges {
            if (edge?.edgeObject?.owner == myPlayerIndex) {
                nextToRoad = true
                break
            }
        }
        if (!nextToRoad) { return false }
        
        corner!.cornerObject = cornerObject(cornerType : .Settlement, owner: myPlayerIndex)
        players[currentPlayer].ownedCorners.append(corner!)
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        let cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),\(cornerType.Settlement)"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        
        // Remove resources from hand
        players[myPlayerIndex].wood -= 1
        players[myPlayerIndex].brick -= 1
        players[myPlayerIndex].sheep -= 1
        players[myPlayerIndex].wheat -= 1
        
        // Send new resource amounts to other players
        sendPlayerData(player: myPlayerIndex)
        
        //check if corner is a harbour, update the trade ratio
        if corner!.isHarbour {
            switch (corner!.harbourType!) {
            case .Brick: players[currentPlayer].brickTradeRatio = 2
            case .Wheat: players[currentPlayer].wheatTradeRatio = 2
            case .Stone: players[currentPlayer].stoneTradeRatio = 2
            case .Sheep: players[currentPlayer].sheepTradeRatio = 2
            case .Wood: players[currentPlayer].woodTradeRatio = 2
            case .General:  if(players[currentPlayer].brickTradeRatio == 4) { players[currentPlayer].brickTradeRatio = 3 }
                            if(players[currentPlayer].wheatTradeRatio == 4) { players[currentPlayer].wheatTradeRatio = 3 }
                            if(players[currentPlayer].stoneTradeRatio == 4) { players[currentPlayer].stoneTradeRatio = 3 }
                            if(players[currentPlayer].sheepTradeRatio == 4) { players[currentPlayer].sheepTradeRatio = 3 }
                            if(players[currentPlayer].woodTradeRatio == 4) { players[currentPlayer].woodTradeRatio = 3 }
            }
        }
        
        give(victoryPoints: 1, to: currentPlayer)
        
        return true
    }
    
    func moveRobber(column: Int, row: Int, valid: Bool) -> Bool {
        if (!valid) { return false }
        let hex = handler.landHexArray.first(where: {$0.column == column && $0.row == row})
        if(hex == nil) { return false }
        if(hex?.type == .water || hex?.type == .fish) { return false }
        
        let oldHex = handler.landHexArray.first(where: {$0.center?.hasRobber == true})
        oldHex?.center?.hasRobber = false
        handler.Vertices.setTileGroup(nil, forColumn: (oldHex?.center?.column)!, row: (oldHex?.center?.row)!)
        
        handler.Vertices.setTileGroup(handler.verticesTiles.tileGroups.first(where: {$0.name == "robber"}), forColumn: hex!.center!.column, row: hex!.center!.row)
        hex?.center?.hasRobber = true
        
        let cornerObjectInfo = "moveRobber.\(oldHex!.column),\(oldHex!.row),\(column),\(row)"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync moveRobber")
        }

        return true
    }
    
    func movePirate(column: Int, row: Int, valid: Bool) -> Bool {
        if (!valid) { return false }
        let hex = handler.landHexArray.first(where: {$0.column == column && $0.row == row})
        if(hex == nil) { return false }
        if(hex?.type != .water || hex?.type != .fish) { return false }
        
        let oldHex = handler.landHexArray.first(where: {$0.center?.hasPirate == true})
        oldHex?.center?.hasPirate = false
        handler.Vertices.setTileGroup(nil, forColumn: (oldHex?.center?.column)!, row: (oldHex?.center?.row)!)
        
        handler.Vertices.setTileGroup(handler.verticesTiles.tileGroups.first(where: {$0.name == "pirate"}), forColumn: hex!.center!.column, row: hex!.center!.row)
        hex?.center?.hasPirate = true
        
        let cornerObjectInfo = "movePirate.\(oldHex!.column),\(oldHex!.row),\(column),\(row)"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync movePirate")
        }
        
        return true
    }
    
    func moveRobberFromMessage(oldColumn: Int, oldRow: Int, column: Int, row: Int) {
        let hex = handler.landHexArray.first(where: {$0.column == column && $0.row == row})
        
        let oldHex = handler.landHexArray.first(where: {$0.column == oldColumn && $0.row == oldRow})
        oldHex?.center?.hasRobber = false
        handler.Vertices.setTileGroup(nil, forColumn: (oldHex?.center?.column)!, row: (oldHex?.center?.row)!)
        
        handler.Vertices.setTileGroup(handler.verticesTiles.tileGroups.first(where: {$0.name == "robber"}), forColumn: hex!.center!.column, row: hex!.center!.row)
        hex?.center?.hasRobber = true
    }
    
    func movePirateFromMessage(oldColumn: Int, oldRow: Int, column: Int, row: Int) {
        let hex = handler.landHexArray.first(where: {$0.column == column && $0.row == row})

        let oldHex = handler.landHexArray.first(where: {$0.column == oldColumn && $0.row == oldRow})
        oldHex?.center?.hasPirate = false
        handler.Vertices.setTileGroup(nil, forColumn: (oldHex?.center?.column)!, row: (oldHex?.center?.row)!)
        
        handler.Vertices.setTileGroup(handler.verticesTiles.tileGroups.first(where: {$0.name == "pirate"}), forColumn: hex!.center!.column, row: hex!.center!.row)
        hex?.center?.hasPirate = true
    }
    
    func getPlayersToStealFrom(column: Int, row: Int) -> [Int] {
        let hex = handler.landHexArray.first(where: {$0.column == column && $0.row == row})
        var playerIndices = [Int]()
        
        for i in 0...5 {
            if(hex!.corners[i].cornerObject != nil && hex!.corners[i].cornerObject?.type != .Knight) {
                if(hex!.corners[i].cornerObject?.owner != myPlayerIndex && playerIndices.contains((hex!.corners[i].cornerObject?.owner)!) == false) {
                    playerIndices.append((hex!.corners[i].cornerObject?.owner)!);
                }
            }
        }
        
        return playerIndices
    }
    
    func buildRoad(column: Int, row: Int, type: edgeType, valid:Bool) -> Bool {
        if (!valid) { return false }
        let edge = handler.landHexEdgeArray.first(where: {$0.column == column && $0.row == row})
        if (edge == nil) { return false }
        if (edge?.tile2 == nil) { return false }
        if (edge!.tile1.type == hexType.water && edge!.tile2!.type == hexType.water) { return false }
        if (edge!.edgeObject != nil) { return false }
        if (!canPlaceEdge(edge: edge!)) { return false }
        if (!hasResourcesForNewRoad() && players[currentPlayer].nextAction != .WillBuildRoadForFree) { return false }
        
        edge!.edgeObject = edgeObject(edgeType : type, owner : myPlayerIndex)
        players[currentPlayer].ownedEdges.append(edge!)
        let tileGroup = handler.edgesTiles.tileGroups.first(where: {$0.name == "\(edge!.direction.rawValue)\(players[currentPlayer].color.rawValue)\(edge!.edgeObject!.type.rawValue)"})
        handler.Edges.setTileGroup(tileGroup, forColumn: column, row: row)
        
        let edgeObjectInfo = "edgeData.\(currentPlayer),\(column),\(row),\(type.rawValue)"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: edgeObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        else {
            print ("successful sync cornerObject")
        }
        
        // Take resources from hand if not building road for free
        if(players[currentPlayer].nextAction != .WillBuildRoadForFree) {
            players[myPlayerIndex].brick -= 1
            players[myPlayerIndex].wood -= 1
        }
        
        // Inform others of resource change
        sendPlayerData(player: myPlayerIndex)
        
        return true
    }
    
    func buildShip(column: Int, row: Int, type: edgeType, valid:Bool) -> Bool {
        if (!valid) { return false }
        let edge = handler.landHexEdgeArray.first(where: {$0.column == column && $0.row == row})
        if (edge == nil) { return false }
        if (edge?.tile2?.type != hexType.water) { return false }
        if (edge?.edgeObject != nil) { return false }
        if (!canPlaceEdge(edge: edge!)) { return false }
        if (!hasResourcesForNewShip() && players[currentPlayer].nextAction != .WillBuildShipForFree) { return false }
        
        edge!.edgeObject = edgeObject(edgeType : type, owner : myPlayerIndex)
        players[currentPlayer].ownedEdges.append(edge!)
        let tileGroup = handler.edgesTiles.tileGroups.first(where: {$0.name == "\(edge!.direction.rawValue)\(players[currentPlayer].color.rawValue)\(edge!.edgeObject!.type.rawValue)"})
        handler.Edges.setTileGroup(tileGroup, forColumn: column, row: row)
        
        let edgeObjectInfo = "edgeData.\(currentPlayer),\(column),\(row),\(type.rawValue)"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: edgeObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        else {
            print ("successful sync cornerObject")
        }
        
        // Take resources from hand if not building ship for free
        if(players[currentPlayer].nextAction != .WillBuildShipForFree) {
            players[myPlayerIndex].sheep -= 1
            players[myPlayerIndex].wood -= 1
        }
        
        // Inform others of resource change
        sendPlayerData(player: myPlayerIndex)
        
        return true
    }

    
    func moveShip(column: Int, row: Int, valid:Bool) -> Bool {
        if (!valid) { return false }
        if (players[myPlayerIndex].movedShipThisTurn) { return false }
        let edge = handler.landHexEdgeArray.first(where: {$0.column == column && $0.row == row})
        if (edge == nil) { return false }
        if (edge!.edgeObject == nil) { return false }
        if (edge!.edgeObject!.type != edgeType.Boat) { return false }
        if (edge!.edgeObject!.justBuilt) { return false }
        if(!canMoveShip(edge: edge!)) { return false }
        
        handler.Edges.setTileGroup(nil, forColumn: column, row: row)
        edge!.edgeObject = nil
        let index = players[currentPlayer].ownedEdges.index(where: {$0.column == column && $0.row == row})
        players[currentPlayer].ownedEdges.remove(at: index!)
        
        let edgeObjectInfo = "edgeData.\(currentPlayer),\(column),\(row),nil"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: edgeObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        else {
            print ("successful sync cornerObject")
        }
        
        //BUILDSHIPFORFREE
        players[currentPlayer].nextAction = PlayerIntentions.WillBuildShipForFree
        
        players[currentPlayer].movedShipThisTurn = true
        return true
    }
    
    func canMoveShip(edge: LandHexEdge) -> Bool {
        
        var neighbourCounter1 = 0
        var neighbourCounter2 = 0
        
        if (edge.neighbourVertex1.cornerObject?.owner == myPlayerIndex) { neighbourCounter1 += 2 }
        if (edge.neighbourVertex2.cornerObject?.owner == myPlayerIndex) { neighbourCounter2 += 2 }
        
        for i in 0...2 {
            let edgeObject1 = edge.neighbourVertex1.neighbourEdges[i]?.edgeObject
            let edgeObject2 = edge.neighbourVertex2.neighbourEdges[i]?.edgeObject
            
            if (edgeObject1 != nil) {
                if(edgeObject1!.type == edgeType.Boat && edgeObject1!.owner == myPlayerIndex) {
                    neighbourCounter1 += 1
                }
            }
            if (edgeObject2 != nil) {
                if(edgeObject2!.type == edgeType.Boat && edgeObject2!.owner == myPlayerIndex) {
                    neighbourCounter2 += 1
                }
            }
        }
        
        if (neighbourCounter1 > 1 && neighbourCounter2 > 1) { return false }
        
        return true
    }
    
    func upgradeSettlement(column : Int, row : Int, valid:Bool) -> Bool {
        if (!valid) { return false }
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false}
        if (corner?.cornerObject == nil) { return false }
        if (corner?.cornerObject!.type != cornerType.Settlement) { return false }
        if (corner?.cornerObject?.owner != myPlayerIndex) { return false }
        if (!hasResourcesToUpgradeSettlement()) { return false }
        
        corner?.cornerObject?.type = .City
        
        // Subtract resources
        players[myPlayerIndex].stone -= 3
        players[myPlayerIndex].wheat -= 2
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.hasCityWall)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        // Inform other players of resource change
        sendPlayerData(player: myPlayerIndex)
        
        let cornerObjectInfo = "cornerData.\(myPlayerIndex),\(column),\(row),\(cornerType.City.rawValue),false"
        
        // Send object info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        else {
            print ("successful sync cornerObject")
        }

        give(victoryPoints: 1, to: myPlayerIndex)
        return true
    }
    
    func buildKnight(column : Int, row : Int, valid: Bool) -> Bool {
        if (!valid) { return false }
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false}
        if (corner?.cornerObject != nil) { return false }
        //if (!canPlaceKnight(corner: corner!)) { return false }
        if (!hasResourcesToBuildKnight()) { return false }
        
        var nextToRoad : Bool = false
        for edge in corner!.neighbourEdges {
            if (edge?.edgeObject?.owner == myPlayerIndex) {
                nextToRoad = true
                break
            }
        }
        if (!nextToRoad) { return false }
        
        corner!.cornerObject = cornerObject(cornerType : .Knight, owner: myPlayerIndex)
        players[currentPlayer].ownedKnights.append(corner!)
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
        
        if tileGroup == nil {print("Unable to find knight asset - \(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(String(describing: corner!.cornerObject!.isActive))")}
        
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        let cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),\(corner!.cornerObject!.type.rawValue),\(corner!.cornerObject!.strength),\(corner!.cornerObject!.isActive),\(corner!.cornerObject!.hasBeenUpgradedThisTurn),\(corner!.cornerObject!.didActionThisTurn)"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        
        // Remove resources from hand
        players[myPlayerIndex].stone -= 1
        players[myPlayerIndex].sheep -= 1
        
        // Send new resource amounts to other players
        sendPlayerData(player: myPlayerIndex)
        
        return true
    }
    
    func upgradeKnight(column : Int, row : Int, valid:Bool) -> Bool {
        if (!valid) { return false }
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false}
        if (corner?.cornerObject == nil) { return false }
        if (corner?.cornerObject!.type != cornerType.Knight) { return false }
        if (corner?.cornerObject?.owner != myPlayerIndex) { return false }
        if (!hasResourcesToPromoteKnight()) { return false }
        if (corner?.cornerObject?.hasBeenUpgradedThisTurn)! { return false }
        if (corner?.cornerObject?.strength == 3) { return false }
        if (corner?.cornerObject?.strength == 2 && players[myPlayerIndex].politicsImprovementLevel < 2) {
            return false
        }
        
        corner?.cornerObject?.strength += 1
        corner?.cornerObject?.hasBeenUpgradedThisTurn = true
        
        // Subtract resources
        players[myPlayerIndex].stone -= 1
        players[myPlayerIndex].sheep -= 1
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        // Inform other players of resource change
        sendPlayerData(player: myPlayerIndex)
        
        // Inform other players of knight change
        var cornerObjectInfo = "cornerData.\(myPlayerIndex),\(column),\(row),nil"
        var sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if !sent { print("failed to sync knight") }
        
        cornerObjectInfo = "cornerData.\(myPlayerIndex),\(column),\(row),\(cornerType.Knight.rawValue),\(corner!.cornerObject!.strength),\(corner!.cornerObject!.isActive),\(corner!.cornerObject!.hasBeenUpgradedThisTurn),\(corner!.cornerObject!.didActionThisTurn)"
        
        // Send object info to other players
        sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        else {
            print ("successful sync cornerObject")
        }
        
        return true
    }
    
    func activateKnight(column : Int, row : Int, valid:Bool) -> Bool {
        if (!valid) { return false }
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false}
        if (corner?.cornerObject == nil) { return false }
        if (corner?.cornerObject!.type != cornerType.Knight) { return false }
        if (corner?.cornerObject?.owner != myPlayerIndex) { return false }
        if (corner?.cornerObject?.isActive)! { return false }
        if (!hasResourcesToActivateKnight()) { return false }
        
        corner?.cornerObject?.isActive = true

        // Subtract resources
        players[myPlayerIndex].wheat -= 1
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        // Inform other players of resource change
        sendPlayerData(player: myPlayerIndex)
        
        var cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),nil"
        var sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {print ("failed to sync knight")}
        
        cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),\(corner!.cornerObject!.type.rawValue),\(corner!.cornerObject!.strength),\(corner!.cornerObject!.isActive),\(corner!.cornerObject!.hasBeenUpgradedThisTurn),\(corner!.cornerObject!.didActionThisTurn)"
        
        // Send object info to other players
        sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync knight")
        }
        
        return true
    }
    
    func moveKnight(column: Int, row: Int, valid:Bool) -> Bool {
        if (!valid) { return false }
        let corner = players[myPlayerIndex].ownedKnights.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false }
        if (corner!.cornerObject == nil) { return false }
        if (corner!.cornerObject!.type != .Knight) { return false }
        if (corner!.cornerObject!.didActionThisTurn) { return false }
        if (!corner!.cornerObject!.isActive) { return false }
        
        handler.Vertices.setTileGroup(nil, forColumn: column, row: row)
        let index = players[currentPlayer].ownedKnights.index(where: {$0.column == column && $0.row == row})
        players[currentPlayer].ownedKnights.remove(at: index!)
        
        let cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),nil"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        
        //BUILDKNIGHTFORFREE
        players[currentPlayer].nextAction = PlayerIntentions.WillBuildKnightForFree
        players[currentPlayer].movingKnightStrength = corner!.cornerObject!.strength
        players[currentPlayer].movingKnightUpgraded = corner!.cornerObject!.hasBeenUpgradedThisTurn
        players[currentPlayer].movingKnightFromRow = row
        players[currentPlayer].movingKnightFromCol = column
        
        return true
    }
    
    func placeKnightForFree(column: Int, row: Int, valid: Bool, displacable: Bool) -> Bool {
        if (!valid) { return false }
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false}
        //if (!canPlaceKnight(corner: corner!)) { return false }
        
        var nextToRoad : Bool = false
        for edge in corner!.neighbourEdges {
            if (edge?.edgeObject?.owner == myPlayerIndex) {
                nextToRoad = true
                break
            }
        }
        if (!nextToRoad) { return false }
        
        let start = handler.landHexVertexArray.first(where: {$0.column == players[myPlayerIndex].movingKnightFromCol && $0.row == players[myPlayerIndex].movingKnightFromRow})
        let connected = pathBetween(a: start, b: corner)
        if (!connected) { return false }
        
        if (corner?.cornerObject != nil && !displacable) { return false }
        else if (corner?.cornerObject != nil) {
            let displace = corner!.cornerObject!
            if (displace.type != .Knight) { return false }
            if (displace.owner == myPlayerIndex) { return false }
            if (displace.strength >= players[myPlayerIndex].movingKnightStrength) { return false }
            
            let index = players[displace.owner].ownedKnights.index(where: {$0.column == column && $0.row == row})
            players[displace.owner].ownedKnights.remove(at: index!)
            
            corner?.cornerObject = nil
            
            let displaceInfo = "cornerData.\(displace.owner),\(column),\(row),nil"
            let sent = appDelegate.networkManager.sendData(data: displaceInfo)
            if (!sent) {
                print ("failed to sync cornerObject")
            }
            
            sendDisplaceRequest(player: displace.owner, column: column, row: row, strength: displace.strength, active: displace.isActive)
        }
        
        corner!.cornerObject = cornerObject(cornerType : .Knight, owner: myPlayerIndex)
        corner!.cornerObject!.strength = players[myPlayerIndex].movingKnightStrength
        if (displacable) {
            corner!.cornerObject!.hasBeenUpgradedThisTurn = players[myPlayerIndex].movingKnightUpgraded
        }
        else {
            corner!.cornerObject!.isActive = players[myPlayerIndex].movingKnightUpgraded
        }
        players[myPlayerIndex].ownedKnights.append(corner!)
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[myPlayerIndex].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        let cornerObjectInfo = "cornerData.\(myPlayerIndex),\(column),\(row),\(corner!.cornerObject!.type.rawValue),\(corner!.cornerObject!.strength),\(corner!.cornerObject!.isActive),\(corner!.cornerObject!.hasBeenUpgradedThisTurn),\(corner!.cornerObject!.didActionThisTurn)"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        
        return true
    }
    
    func sendDisplaceRequest(player: Int, column:Int, row:Int, strength: Int, active: Bool) {
        let message = "displace.\(player),\(column),\(row),\(strength),\(active)"
        
        let sent = appDelegate.networkManager.sendData(data: message)
        if !sent {
            print("Failed to send displace knight message")
        }
    }
    
    func displaceKnight(data: String) {
        let info = data.components(separatedBy: ",")
        let player = Int(info[0])!
        let col = Int(info[1])!
        let row = Int(info[2])!
        let strength = Int(info[3])!
        let active = Bool(info[4])!
        
        if !replacementExists(row: row, col: col) {
            return
        }
        
        players[player].movingKnightFromCol = col
        players[player].movingKnightFromRow = row
        players[player].movingKnightStrength = strength
        players[player].movingKnightUpgraded = active
        players[player].nextAction = .WillDisplaceKnight
        
        // alert
        if (player == myPlayerIndex) {
            let alert = UIAlertController(title: "Knight Displaced", message: "Select a new position for your knight.", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default)
            alert.addAction(okay)
            OperationQueue.main.addOperation { () -> Void in
                self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func pathBetween(a: LandHexVertex?, b: LandHexVertex?) -> Bool {
        if (a == nil || b == nil) { return false }
        
        var queue : [LandHexVertex] = []
        var visited : [LandHexEdge] = []
        queue.append(a!)
        
        while (queue.count > 0) {
            let v = queue.remove(at: 0)
            
            if (v.column == b?.column && v.row == b?.row) {
                return true
            }
            
            let e1 = v.neighbourEdges[0]
            let e2 = v.neighbourEdges[1]
            let e3 = v.neighbourEdges[2]
            let has1 = visited.first(where: {$0.column == e1?.column && $0.row == e1?.row})
            let has2 = visited.first(where: {$0.column == e2?.column && $0.row == e2?.row})
            let has3 = visited.first(where: {$0.column == e3?.column && $0.row == e3?.row})
            
            if (has1 == nil && e1 != nil && e1?.edgeObject?.owner == myPlayerIndex) {
                let v1 = e1?.neighbourVertex1
                let v2 = e1?.neighbourVertex2
                visited.append(e1!)
                if (v1?.cornerObject == nil || v1?.cornerObject?.owner == myPlayerIndex) {
                    if (v1?.row != v.row || v1?.column != v.column) {
                        queue.append(v1!)
                    }
                }
                else if (v1?.cornerObject != nil) {
                    if v1!.cornerObject?.type == .Knight && v1!.row == b?.row && v1!.column == b?.column && v1?.cornerObject?.owner != myPlayerIndex {
                        queue.append(v1!)
                    }
                }
                
                if (v2?.cornerObject == nil || v2?.cornerObject?.owner == myPlayerIndex) {
                    if (v2?.row != v.row || v2?.column != v.column) {
                        queue.append(v2!)
                    }
                }
                else if (v2?.cornerObject != nil) {
                    if v2!.cornerObject?.type == .Knight && v2!.row == b?.row && v2!.column == b?.column && v2?.cornerObject?.owner != myPlayerIndex {
                        queue.append(v2!)
                    }
                }
            }
            if (has2 == nil && e2 != nil && e2?.edgeObject?.owner == myPlayerIndex) {
                let v1 = e2?.neighbourVertex1
                let v2 = e2?.neighbourVertex2
                visited.append(e2!)
                if (v1?.cornerObject == nil || v1?.cornerObject?.owner == myPlayerIndex) {
                    if (v1?.row != v.row || v1?.column != v.column) {
                        queue.append(v1!)
                    }
                }
                else if (v1?.cornerObject != nil) {
                    if v1!.cornerObject?.type == .Knight && v1!.row == b?.row && v1!.column == b?.column && v1?.cornerObject?.owner != myPlayerIndex {
                        queue.append(v1!)
                    }
                }
                
                if (v2?.cornerObject == nil || v2?.cornerObject?.owner == myPlayerIndex) {
                    if (v2?.row != v.row || v2?.column != v.column) {
                        queue.append(v2!)
                    }
                }
                else if (v2?.cornerObject != nil) {
                    if v2!.cornerObject?.type == .Knight && v2!.row == b?.row && v2!.column == b?.column && v2?.cornerObject?.owner != myPlayerIndex  {
                        queue.append(v2!)
                    }
                }            }
            if (has3 == nil && e3 != nil && e3?.edgeObject?.owner == myPlayerIndex) {
                let v1 = e3?.neighbourVertex1
                let v2 = e3?.neighbourVertex2
                visited.append(e3!)
                if (v1?.cornerObject == nil || v1?.cornerObject?.owner == myPlayerIndex) {
                    if (v1?.row != v.row || v1?.column != v.column) {
                        queue.append(v1!)
                    }
                }
                else if (v1?.cornerObject != nil) {
                    if v1!.cornerObject?.type == .Knight && v1!.row == b?.row && v1!.column == b?.column && v1?.cornerObject?.owner != myPlayerIndex {
                        queue.append(v1!)
                    }
                }
                
                if (v2?.cornerObject == nil || v2?.cornerObject?.owner == myPlayerIndex) {
                    if (v2?.row != v.row || v2?.column != v.column) {
                        queue.append(v2!)
                    }
                }
                else if (v2?.cornerObject != nil) {
                    if v2!.cornerObject?.type == .Knight && v2!.row == b?.row && v2!.column == b?.column && v2?.cornerObject?.owner != myPlayerIndex {
                        queue.append(v2!)
                    }
                }
            }
        }
        
        return false
    }
    
    func replacementExists(row: Int, col: Int) -> Bool {
        let start = handler.landHexVertexArray.first(where:{$0.row == row && $0.column == col})
        var queue : [LandHexVertex] = []
        var visited : [LandHexEdge] = []
        queue.append(start!)
        
        while (queue.count > 0) {
            let v = queue.remove(at: 0)
            
            if (v.cornerObject == nil && (v.row != start?.row || v.column != start?.column)) {
                return true
            }
            
            let e1 = v.neighbourEdges[0]
            let e2 = v.neighbourEdges[1]
            let e3 = v.neighbourEdges[2]
            let has1 = visited.first(where: {$0.column == e1?.column && $0.row == e1?.row})
            let has2 = visited.first(where: {$0.column == e2?.column && $0.row == e2?.row})
            let has3 = visited.first(where: {$0.column == e3?.column && $0.row == e3?.row})
            
            if (has1 == nil && e1 != nil && e1?.edgeObject?.owner == myPlayerIndex) {
                let v1 = e1?.neighbourVertex1
                let v2 = e1?.neighbourVertex2
                visited.append(e1!)
                if (v1?.cornerObject == nil || v1?.cornerObject?.owner == myPlayerIndex) {
                    if (v1?.row == v.row && v1?.column == v.column) {
                        queue.append(v2!)
                    }
                    else {
                        queue.append(v1!)
                    }
                }
            }
            if (has2 == nil && e2 != nil && e2?.edgeObject?.owner == myPlayerIndex) {
                let v1 = e2?.neighbourVertex1
                let v2 = e2?.neighbourVertex2
                visited.append(e2!)
                if (v1?.cornerObject == nil || v1?.cornerObject?.owner == myPlayerIndex) {
                    if (v1?.row != v.row || v1?.column != v.column) {
                        queue.append(v1!)
                    }
                }
                if (v2?.cornerObject == nil || v2?.cornerObject?.owner == myPlayerIndex) {
                    if (v2?.row != v.row || v2?.column != v.column) {
                        queue.append(v1!)
                    }
                }
                
            }
            if (has3 == nil && e3 != nil && e3?.edgeObject?.owner == myPlayerIndex) {
                let v1 = e3?.neighbourVertex1
                let v2 = e3?.neighbourVertex2
                visited.append(e3!)
                if (v1?.cornerObject == nil || v1?.cornerObject?.owner == myPlayerIndex) {
                    if (v1?.row != v.row || v1?.column != v.column) {
                        queue.append(v1!)
                    }
                }
                if (v2?.cornerObject == nil || v2?.cornerObject?.owner == myPlayerIndex) {
                    if (v2?.row != v.row || v2?.column != v.column) {
                        queue.append(v1!)
                    }
                }
            }
        }
        
        return false
    }

    func hasResourcesForNewSettlement() -> Bool {
        var numSettlements = 0
        for corner in players[myPlayerIndex].ownedCorners {
            if (corner.cornerObject?.type == .Settlement) {
                numSettlements += 1
            }
        }
        if (numSettlements == 5) { return false }
        let p = players[myPlayerIndex]
        if (p.wood > 0 && p.brick > 0 && p.sheep > 0 && p.wheat > 0) {
            return true
        }
        return false
    }
    
    func hasResourcesForNewRoad() -> Bool {
        if (players[myPlayerIndex].ownedEdges.count == 15) {return false }
        if (players[myPlayerIndex].wood > 0 && players[myPlayerIndex].brick > 0) {
            return true
        }
        return false
    }
    
    func hasResourcesForNewShip() -> Bool {
        if (players[myPlayerIndex].ownedEdges.count == 15) {return false}
        if (players[myPlayerIndex].wood > 0 && players[myPlayerIndex].sheep > 0) {
            return true
        }
        return false
    }
    
    func hasResourcesToUpgradeSettlement() -> Bool {
        var numCities = 0
        for corner in players[myPlayerIndex].ownedCorners {
            if (corner.cornerObject?.type == .City) {
                numCities += 1
            }
        }
        if (numCities == 4) { return false }
        if (players[myPlayerIndex].stone > 2 && players[myPlayerIndex].wheat > 1) {
            return true
        }
        return false
    }
    
    func hasResourcesToBuildKnight() -> Bool {
        if (players[myPlayerIndex].stone >= 1 && players[myPlayerIndex].sheep >= 1) {
            return true
        }
        return false
    }
    
    func hasResourcesToActivateKnight() -> Bool {
        if (players[myPlayerIndex].wheat >= 1) {
            return true
        }
        return false
    }

    func hasResourcesToPromoteKnight() -> Bool {
        if (players[myPlayerIndex].stone >= 1 && players[myPlayerIndex].sheep >= 1) {
            return true
        }
        return false
    }
    
    func hasResourcesForCityWall() -> Bool {
        if (players[myPlayerIndex].brick < 2) { return false }
        var numWalls = 0
        for cityCorner in players[myPlayerIndex].ownedCorners {
            let city = cityCorner.cornerObject!
            if city.hasCityWall {
                numWalls += 1
            }
        }
        if numWalls == 3 { return false }
        return true
    }
    
    func buildCityWall(column: Int, row: Int, valid: Bool) -> Bool {
        if !valid { return false }
        var hasEngineerCard = false
        var usingEngineerCard = false
        for item in players[myPlayerIndex].progressCards { if item == .Engineer { hasEngineerCard = true } }
        if hasEngineerCard {
            var decisionMade = false
            let alert = UIAlertController(title: "Progress Card", message: "Would you like to use the Engineer card instead to build this wall?", preferredStyle: .alert)
            let alertActionA = UIAlertAction(title: "YES", style: .default, handler: { action -> Void in
                usingEngineerCard = true
                decisionMade = true
            })
            alert.addAction(alertActionA)
            let alertActionB = UIAlertAction(title: "YES", style: .default, handler: { action -> Void in
                decisionMade = true
            })
            alert.addAction(alertActionB)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            while !decisionMade { }
        }
        if !hasResourcesForCityWall() && !usingEngineerCard { return false }
        let corner = players[myPlayerIndex].ownedCorners.first(where: {$0.column == column && $0.row == row})
        if corner == nil { return false }
        if corner?.cornerObject == nil { return false }
        if corner?.cornerObject!.type != .City && corner?.cornerObject!.type != .Metropolis { return false }
        if (corner?.cornerObject!.hasCityWall)! { return false }
        if corner!.cornerObject!.owner != myPlayerIndex { return false }
        
        corner?.cornerObject!.hasCityWall = true
        
        // Pay for wall and update others of payment
        if !usingEngineerCard {
            players[myPlayerIndex].brick -= 2
        } else {
            for index in 0..<players[myPlayerIndex].progressCards.count {
                if players[myPlayerIndex].progressCards[index] == .Engineer {
                    players[myPlayerIndex].progressCards.remove(at: index)
                    break
        }   }   }
        sendPlayerData(player: myPlayerIndex)
        
        var cornerObjectInfo = "cornerData.\(myPlayerIndex),\(column),\(row),nil"
        var sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if !sent { print("failed to sync city") }
        // Update others of wall construction
        cornerObjectInfo = "cornerData.\(myPlayerIndex),\(column),\(row),\(cornerType.City.rawValue),true"
        sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if !sent { print("failed to sync city") }
        
        // Buildwall
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)true"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        return true
    }
    
    func isFirstToReach(level: Int, type: ProgressCardsCategory) -> Bool {
        var count = 0
        for player in players {
            if type == .Politics {
                if player.politicsImprovementLevel >= level {count += 1}
            }
            else if type == .Sciences {
                if player.sciencesImprovementLevel >= level {count += 1}
            }
            else {
                if player.tradesImprovementLevel >= level {count += 1}
            }
        }
        
        return (count == 1)
    }
    
    func buildMetropolis(col: Int, row: Int, valid: Bool) -> Bool {
        let corner = players[myPlayerIndex].ownedCorners.first(where: {$0.column == col && $0.row == row})
        if corner == nil {return false}
        if corner?.cornerObject == nil {return false}
        if corner!.cornerObject!.type != .City {return false}
        if corner!.cornerObject!.owner != myPlayerIndex {return false}
        
        corner!.cornerObject!.type = .Metropolis
        
        var cornerObjectInfo = "cornerData.\(currentPlayer),\(col),\(row),nil"
        var sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if !sent {print("failed to sync metropolis")}
        
        cornerObjectInfo = "cornerData.\(currentPlayer),\(col),\(row),\(cornerType.Metropolis),\(corner!.cornerObject!.hasCityWall)"
        sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if !sent {print("failed to sync metropolis")}
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[myPlayerIndex].color.rawValue)\(cornerType.Metropolis)\(corner!.cornerObject!.hasCityWall)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: col, row: row)
    
        return true
    }
    func removeMetropolis(from :Int, type: ProgressCardsCategory) {
        let player = players[from]
        if type == .Politics {
            player.holdsPoliticsMetropolis = false;
            let sent = appDelegate.networkManager.sendData(data: "metropolis.Politics.\(from).false")
            if !sent { print("unable to update metropolis info") }
        }
        else if type == .Sciences {
            player.holdsSciencesMetropolis = false;
            let sent = appDelegate.networkManager.sendData(data: "metropolis.Sciences.\(from).false")
            if !sent { print("unable to update metropolis info") }
        }
        else {
            player.holdsTradesMetropolis = false;
            let sent = appDelegate.networkManager.sendData(data: "Trades.\(from).false")
            if !sent { print("unable to update metropolis info") }
        }
        
        var num = 0
        for corner in players[from].ownedCorners {
            if corner.cornerObject!.type == .Metropolis {
                num += 1
            }
        }
        if num > 1 {
            // if player has multiple
            players[from].nextAction = .WillRemoveMetropolis
            let sent = appDelegate.networkManager.sendData(data: "intentions.\(from).WillRemoveMetropolis")
            if !sent {print("unable to sync remove metropolis")}
            
            let sent3 = appDelegate.networkManager.sendData(data: "metropolis.\(type.rawValue).\(from).false")
            if !sent3 { print("unable to update metropolis info") }

        }
        else if num == 1 {
            // reduce to city
            let corner = players[from].ownedCorners.first(where: {$0.cornerObject!.type == .Metropolis})
            
            let removeNotification = "cornerObject.\(from),\(corner!.column),\(corner!.row),nil"
            let sent = appDelegate.networkManager.sendData(data: removeNotification)
            if !sent {print("failed to sync metropolis")}
            
            corner?.cornerObject?.type = .City
            
            let cornerObjectInfo = "cornerData.\(from),\(corner!.column),\(corner!.row),\(cornerType.City),\(corner!.cornerObject!.hasCityWall)"
            let sent2 = appDelegate.networkManager.sendData(data: cornerObjectInfo)
            if !sent2 {print("failed to sync metropolis")}
            
            let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[from].color.rawValue)\(cornerType.City)\(corner!.cornerObject!.hasCityWall)"})
            handler.Vertices.setTileGroup(tileGroup, forColumn: corner!.column, row: corner!.row)
            
            let sent3 = appDelegate.networkManager.sendData(data: "metropolis.\(type.rawValue).\(from).false")
            if !sent3 { print("unable to update metropolis info") }
        }
        else {
            // remove right to build when obtain city
            players[from].canBuildMetropolis -= 1
            let sent = appDelegate.networkManager.sendData(data: "intentToBuildMetropolis.\(from).false")
            if !sent { print("unable to update metropolis info") }
            
            let sent3 = appDelegate.networkManager.sendData(data: "metropolis.\(type.rawValue).\(from).false")
            if !sent3 { print("unable to update metropolis info") }

        }
        
    }
    func reduceMetropolis(column: Int, row: Int, valid: Bool) -> Bool {
        let corner = players[myPlayerIndex].ownedCorners.first(where: {$0.column == column && $0.row == row})
        if corner == nil {return false}
        if corner!.cornerObject == nil {return false}
        if corner!.cornerObject!.owner != myPlayerIndex {return false}
        if corner!.cornerObject!.type != .Metropolis {return false}
        
        let removeNotification = "cornerObject.\(myPlayerIndex),\(column),\(row),nil"
        let sent = appDelegate.networkManager.sendData(data: removeNotification)
        if !sent {print("failed to sync metropolis")}
        
        corner?.cornerObject?.type = .City
        
        let cornerObjectInfo = "cornerData.\(myPlayerIndex),\(column),\(row),\(cornerType.City),\(corner!.cornerObject!.hasCityWall)"
        let sent2 = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if !sent2 {print("failed to sync metropolis")}
        
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[myPlayerIndex].color.rawValue)\(cornerType.City)\(corner!.cornerObject!.hasCityWall)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        return true
    }
    func notifyMetropolisLost() {
        let alert = UIAlertController(title: "Metropolis Stolen", message: "Another player has stolen a Metropolis from you. Choose which one to give away.", preferredStyle: UIAlertControllerStyle.alert)
        let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default)
        alert.addAction(okay)
        
        OperationQueue.main.addOperation { () -> Void in
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    //function that will read a recieved message and set the corner object
    func setCornerObjectFromMessage(info:String) {
        let cornerInfo = info.components(separatedBy: ",")
        let who = Int(cornerInfo[0])!
        let column = Int(cornerInfo[1])!
        let row = Int(cornerInfo[2])!
        if(cornerInfo[3] != "nil") {
            let type = cornerType(rawValue: cornerInfo[3])
            
            let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
            
            corner?.cornerObject = cornerObject(cornerType : type!, owner: who)
            
            if type == .Knight {
                corner?.cornerObject?.strength = Int(cornerInfo[4])!
                let active = Bool(cornerInfo[5])
                if (active == nil) {
                    corner?.cornerObject?.isActive = false
                }
                else {
                    corner?.cornerObject?.isActive = active!
                }
                let upgraded = Bool(cornerInfo[6])
                if (upgraded == nil) {
                    corner?.cornerObject?.hasBeenUpgradedThisTurn = false
                }
                else {
                    corner?.cornerObject?.hasBeenUpgradedThisTurn = upgraded!
                }
                let used = Bool(cornerInfo[7])
                if (used == nil) {
                    corner?.cornerObject?.didActionThisTurn = true
                }
                else {
                    corner?.cornerObject?.didActionThisTurn = used!
                }
                
                players[who].ownedKnights.append(corner!)
            }
            else { // either Settlement, City, or Metropolis
                players[who].ownedCorners.append(corner!)
                
                if type == .Metropolis || type == .City {
                    let hasCityWall = Bool(cornerInfo[4])!
                    corner?.cornerObject?.hasCityWall = hasCityWall
                }
                else {
                    corner?.cornerObject?.hasCityWall = false
                }
            }
            
            var tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[who].color.rawValue)\(corner!.cornerObject!.type.rawValue)"})
            
            if type == .City || type == .Metropolis {
                tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[who].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.hasCityWall)"})

            }
            else if type == .Knight {
                tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[who].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
            }
            
            handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        }
        else {
            var isKnight = false
            var index = players[who].ownedCorners.index(where: {$0.column == column && $0.row == row})
            
            if (index == nil) {
                index = players[who].ownedKnights.index(where: {$0.column == column && $0.row == row})
                isKnight = true
            }
            
            if (isKnight) {
                players[who].ownedKnights.remove(at: index!)
            }
            else {
                players[who].ownedCorners.remove(at: index!)
            }
            
            handler.Vertices.setTileGroup(nil, forColumn: column, row: row)
        }
    }
    
    //function that will place an edge object and set its owner then send info to other players
    func placeEdgeObject(column : Int, row : Int, type : edgeType) -> Bool {
        let edge = handler.landHexEdgeArray.first(where: {$0.column == column && $0.row == row})
        if (edge == nil) { return false }
        if (edge!.edgeObject != nil) { return false }
        if (canPlaceEdge(edge: edge!) == false) { return false }
        if (edge!.tile1.onMainIsland == false) { return false }
        
        edge!.edgeObject = edgeObject(edgeType : type, owner : myPlayerIndex)
        players[currentPlayer].ownedEdges.append(edge!)
        let tileGroup = handler.edgesTiles.tileGroups.first(where: {$0.name == "\(edge!.direction.rawValue)\(players[currentPlayer].color.rawValue)\(edge!.edgeObject!.type.rawValue)"})
        handler.Edges.setTileGroup(tileGroup, forColumn: column, row: row)
        
        let edgeObjectInfo = "edgeData.\(currentPlayer),\(column),\(row),\(type.rawValue)"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: edgeObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        else {
            print ("successful sync cornerObject")
        }
        
        return true
    }
    
    //function to check if an edge can be placed
    func canPlaceEdge(edge : LandHexEdge) -> Bool {
        
        if (players[currentPlayer].ownedCorners.contains(where: {$0.column == edge.neighbourVertex1.column && $0.row == edge.neighbourVertex1.row})) { return true }
        if (players[currentPlayer].ownedCorners.contains(where: {$0.column == edge.neighbourVertex2.column && $0.row == edge.neighbourVertex2.row})) { return true }
        
        if (edge.column % 2 == 0) {
            switch edge.direction {
            case .flat:
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[1]) && $0.row == (edge.row + handler.yEvenOffset[1])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[2]) && $0.row == (edge.row + handler.yEvenOffset[2])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[4]) && $0.row == (edge.row + handler.yEvenOffset[4])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[5]) && $0.row == (edge.row + handler.yEvenOffset[5])})) { return true }
            case .lDiagonal:
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[0]) && $0.row == (edge.row + handler.yEvenOffset[0])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[2]) && $0.row == (edge.row + handler.yEvenOffset[2])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[3]) && $0.row == (edge.row + handler.yEvenOffset[3])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[5]) && $0.row == (edge.row + handler.yEvenOffset[5])})) { return true }
            case .rDiagonal:
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[0]) && $0.row == (edge.row + handler.yEvenOffset[0])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[1]) && $0.row == (edge.row + handler.yEvenOffset[1])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[3]) && $0.row == (edge.row + handler.yEvenOffset[3])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[4]) && $0.row == (edge.row + handler.yEvenOffset[4])})) { return true }
            }
            
        } else {
            switch edge.direction {
            case .flat:
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[1]) && $0.row == (edge.row + handler.yOddOffset[1])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[2]) && $0.row == (edge.row + handler.yOddOffset[2])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[4]) && $0.row == (edge.row + handler.yOddOffset[4])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[5]) && $0.row == (edge.row + handler.yOddOffset[5])})) { return true }
            case .lDiagonal:
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[0]) && $0.row == (edge.row + handler.yOddOffset[0])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[2]) && $0.row == (edge.row + handler.yOddOffset[2])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[3]) && $0.row == (edge.row + handler.yOddOffset[3])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[5]) && $0.row == (edge.row + handler.yOddOffset[5])})) { return true }
            case .rDiagonal:
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[0]) && $0.row == (edge.row + handler.yOddOffset[0])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[1]) && $0.row == (edge.row + handler.yOddOffset[1])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[3]) && $0.row == (edge.row + handler.yOddOffset[3])})) { return true }
                if (players[currentPlayer].ownedEdges.contains(where: {$0.column == (edge.column + handler.xOffset[4]) && $0.row == (edge.row + handler.yOddOffset[4])})) { return true }
            }
        }
        
        return false
    }
    
    //function that will read a recieved message and set the edge object
    func setEdgeObjectFromMessage(info:String) {
        let edgeInfo = info.components(separatedBy: ",")
        let currPlayerNumber = Int(edgeInfo[0])!
        let column = Int(edgeInfo[1])!
        let row = Int(edgeInfo[2])!
        if(edgeInfo[3] != "nil") {
            let type = edgeType(rawValue: edgeInfo[3])
            let edge = handler.landHexEdgeArray.first(where: {$0.column == column && $0.row == row})
            edge?.edgeObject = edgeObject(edgeType : type!, owner : currPlayerNumber)
            players[currPlayerNumber].ownedEdges.append(edge!)
            let tileGroup = handler.edgesTiles.tileGroups.first(where: {$0.name == "\(edge!.direction.rawValue)\(players[currPlayerNumber].color.rawValue)\(edge!.edgeObject!.type.rawValue)"})
            handler.Edges.setTileGroup(tileGroup, forColumn: column, row: row)
        } else {
            let index = players[currPlayerNumber].ownedEdges.index(where: {$0.column == column && $0.row == row})
            players[currPlayerNumber].ownedEdges.remove(at: index!)
            handler.Edges.setTileGroup(nil, forColumn: column, row: row)
        }
    }
    
    func barbarianAttack() {
        var knightStrength : [Int] = [0, 0, 0]
        var barbarianStrength = 0
        
        var immune : [Bool] = [true, true, true]
        for player in 0..<players.count {
            for knightCorner in players[player].ownedKnights {
                if (knightCorner.cornerObject?.isActive)! {
                    knightStrength[player] += (knightCorner.cornerObject?.strength)!
                    knightCorner.cornerObject!.isActive = false
                    
                    //Update knight GUI
                    updateKnightGUI(row: knightCorner.row, col: knightCorner.column, player: player, strength: knightCorner.cornerObject!.strength, isActive: false)
                }
            }
            for cityCorner in players[player].ownedCorners {
                if (cityCorner.cornerObject!.type == .City) {
                    barbarianStrength += 1
                    immune[player] = false
                }
                else if (cityCorner.cornerObject!.type == .Metropolis) {
                    barbarianStrength += 1
                }
            }
        }
        
        if knightStrength[0] + knightStrength[1] + knightStrength[2] < barbarianStrength {
            // determine weakest player(s)
            var weakest = 100
            if !immune[0] { weakest = knightStrength[0] }
            if knightStrength[1] < weakest && !immune[1] { weakest = knightStrength[1] }
            if knightStrength[2] < weakest && !immune[2] && players.count > 2 { weakest = knightStrength[2] }
            
            var num = 0
            for player in 0..<players.count {
                if knightStrength[player] == weakest {
                    num += 1
                }
            }
            
            // If everyone is immune nothing happens
            if num == 0 {
                return
            }
            
            if knightStrength[myPlayerIndex] == weakest {
                var numCities = 0
                for cityCorner in players[myPlayerIndex].ownedCorners {
                    if cityCorner.cornerObject?.type == .City {
                        numCities += 1
                    }
                }
                
                if (numCities == 1) {
                    let alert = UIAlertController(title: "Barbarians Arrived in Catan", message: "The barbarians are stronger than the knights, and will pillage your city", preferredStyle: UIAlertControllerStyle.alert)
                    let okay: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (alertAction) -> Void in
                        let cityCorner = self.players[self.myPlayerIndex].ownedCorners.first(where: {$0.cornerObject?.type == .City})
                        let _ = self.destroyCity(column: (cityCorner?.column)!, row: (cityCorner?.row)!, who: self.myPlayerIndex)
                    }
                    alert.addAction(okay)
                    OperationQueue.main.addOperation { () -> Void in
                        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    let alert = UIAlertController(title: "Barbarians Arrived in Catan", message: "The barbarians have defeated the knights - choose which city they pillage", preferredStyle: UIAlertControllerStyle.alert)
                    let okay: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (alertAction) -> Void in
                        self.players[self.myPlayerIndex].nextAction = .WillDestroyCity
                        let sent = self.appDelegate.networkManager.sendData(data: "intentions.\(self.myPlayerIndex).WillDestroyCity")
                        if !sent {print("failed to send player intentions")}
                    }
                    alert.addAction(okay)
                    OperationQueue.main.addOperation { () -> Void in
                        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            // determine strongest player(s)
            var strongest = knightStrength[0]
            if knightStrength[1] > strongest { strongest = knightStrength[1] }
            if knightStrength[2] > strongest && players.count > 2 { strongest = knightStrength[2] }
            
            var num = 0
            for player in 0..<players.count {
                if knightStrength[player] == strongest {
                    num += 1
                }
            }
            
            if num == 1 {
                if knightStrength[myPlayerIndex] == strongest {
 
                    let alert = UIAlertController(title: "Barbarians Arrived in Catan", message: "The knights have defeated the barbarians! You are the \"Defender of Catan\", and receive one victory point!", preferredStyle: UIAlertControllerStyle.alert)
                    let okay: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (alertAction) -> Void in
                        self.give(victoryPoints: 1, to: self.myPlayerIndex)
                    }
                    alert.addAction(okay)
                    OperationQueue.main.addOperation { () -> Void in
                        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    var winner = 0
                    if knightStrength[0] == strongest { winner = 0 }
                    else if knightStrength[1] == strongest { winner = 1 }
                    else if knightStrength[2] == strongest && players.count > 2 { winner = 2 }
                    
                    let alert = UIAlertController(title: "Barbarians Arrived in Catan", message: "The knights have defeated the barbarians! \(players[winner].name) is the \"Defender of Catan\"", preferredStyle: UIAlertControllerStyle.alert)
                    let okay: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (alertAction) -> Void in
                        
                    }
                    alert.addAction(okay)
                    OperationQueue.main.addOperation { () -> Void in
                        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                if knightStrength[myPlayerIndex] == strongest {
                    let alert = UIAlertController(title: "Barbarians Arrived in Catan", message: "The knights have defeated the barbarians! Draw a Progress Card", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let trade: UIAlertAction = UIAlertAction(title: "Trade", style: UIAlertActionStyle.default) { (alertAction) -> Void in
                        self.players[self.myPlayerIndex].progressCards.append(ProgressCardsType.getNextCardOfCategory(.Trades, fromDeck: &self.gameDeck)!)
                        
                        let sent = self.appDelegate.networkManager.sendData(data: "drewProgressCard.TRADES")
                        if !sent { print("failed to send draw progress card") }
                    }
                    
                    let politics = UIAlertAction(title: "Politics", style: UIAlertActionStyle.default) { (alertAction) -> Void in
                        self.players[self.myPlayerIndex].progressCards.append(ProgressCardsType.getNextCardOfCategory(.Politics, fromDeck: &self.gameDeck)!)
                        
                        let sent = self.appDelegate.networkManager.sendData(data: "drewProgressCard.POLITICS")
                        if !sent { print("failed to send draw progress card") }
                    }
                    
                    let science = UIAlertAction(title: "Science", style: UIAlertActionStyle.default) { (alertAction) -> Void in
                        self.players[self.myPlayerIndex].progressCards.append(ProgressCardsType.getNextCardOfCategory(.Sciences, fromDeck: &self.gameDeck)!)
                        
                        let sent = self.appDelegate.networkManager.sendData(data: "drewProgressCard.SCIENCES")
                        if !sent { print("failed to send draw progress card") }
                    }
                    
                    alert.addAction(trade)
                    alert.addAction(politics)
                    alert.addAction(science)
                    
                    OperationQueue.main.addOperation { () -> Void in
                        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func destroyCity(column: Int, row: Int, who: Int) -> Bool {
        let cityCorner = players[who].ownedCorners.first(where: {$0.column == column && $0.row == row})
        if cityCorner == nil {return false}
        if cityCorner?.cornerObject == nil {return false}
        if cityCorner?.cornerObject?.owner != who {return false}
        if cityCorner?.cornerObject?.type != .City {return false}
        
        cityCorner?.cornerObject?.type = .Settlement
        cityCorner?.cornerObject?.hasCityWall = false
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[who].color.rawValue)\(cityCorner!.cornerObject!.type.rawValue)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        var cornerObjectInfo = "cornerData.\(who),\(column),\(row),nil"
        var sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        print("DestroyCity \(cornerObjectInfo)")
        if !sent { print ("Failed to update others on city destruction") }
        
        give(victoryPoints: -2, to: who)
        
        cornerObjectInfo = "cornerData.\(who),\(column),\(row),\(cornerType.Settlement)"
        sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        print("BuildSettlement \(cornerObjectInfo)")
        
        if !sent { print ("Failed to update others on city destruction") }
        
        return true
    }
    
    func updateKnightGUI(row: Int, col: Int, player: Int, strength: Int, isActive: Bool) {
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[player].color.rawValue)Knight\(strength)\(isActive)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: col, row: row)
    }
    
    // function that rolls the dice
    func rollDice() {
        var values = dice.rollDice()
        if players[myPlayerIndex].progressCards.contains(.Alchemist) {
            let announcement = "Looks like you have The Alchemist card...would you like to use it?"
            let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
                let actionSheetRed = UIAlertController(title: nil, message: "Select a value for the red dice...", preferredStyle: .alert)
                let selectedOneRed = UIAlertAction(title: "ONE", style: .default) { action -> Void in
                    values[0] = 1
                    let actionSheetYellow = UIAlertController(title: nil, message: "Select a value for the yellow dice...", preferredStyle: .alert)
                    let selectedOneYellow = UIAlertAction(title: "ONE", style: .default) { action -> Void in
                        values[1] = 1
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedOneYellow)
                    let selectedTwoYellow = UIAlertAction(title: "TWO", style: .default) { action -> Void in
                        values[1] = 2
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedTwoYellow)
                    let selectedThreeYellow = UIAlertAction(title: "THREE", style: .default) { action -> Void in
                        values[1] = 3
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                            }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedThreeYellow)
                    let selectedFourYellow = UIAlertAction(title: "FOUR", style: .default) { action -> Void in
                        values[1] = 4
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFourYellow)
                    let selectedFiveYellow = UIAlertAction(title: "FIVE", style: .default) { action -> Void in
                        values[1] = 5
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFiveYellow)
                    let selectedSixYellow = UIAlertAction(title: "SIX", style: .default) { action -> Void in
                        values[1] = 6
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedSixYellow)
                    self.view?.window?.rootViewController?.present(actionSheetYellow, animated: true, completion: nil)
                }
                actionSheetRed.addAction(selectedOneRed)
                let selectedTwoRed = UIAlertAction(title: "TWO", style: .default) { action -> Void in
                    values[0] = 2
                    let actionSheetYellow = UIAlertController(title: nil, message: "Select a value for the yellow dice...", preferredStyle: .alert)
                    let selectedOneYellow = UIAlertAction(title: "ONE", style: .default) { action -> Void in
                        values[1] = 1
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedOneYellow)
                    let selectedTwoYellow = UIAlertAction(title: "TWO", style: .default) { action -> Void in
                        values[1] = 2
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedTwoYellow)
                    let selectedThreeYellow = UIAlertAction(title: "THREE", style: .default) { action -> Void in
                        values[1] = 3
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedThreeYellow)
                    let selectedFourYellow = UIAlertAction(title: "FOUR", style: .default) { action -> Void in
                        values[1] = 4
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFourYellow)
                    let selectedFiveYellow = UIAlertAction(title: "FIVE", style: .default) { action -> Void in
                        values[1] = 5
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFiveYellow)
                    let selectedSixYellow = UIAlertAction(title: "SIX", style: .default) { action -> Void in
                        values[1] = 6
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedSixYellow)
                    self.view?.window?.rootViewController?.present(actionSheetYellow, animated: true, completion: nil)
                }
                actionSheetRed.addAction(selectedTwoRed)
                let selectedThreeRed = UIAlertAction(title: "THREE", style: .default) { action -> Void in
                    values[0] = 3
                    let actionSheetYellow = UIAlertController(title: nil, message: "Select a value for the yellow dice...", preferredStyle: .alert)
                    let selectedOneYellow = UIAlertAction(title: "ONE", style: .default) { action -> Void in
                        values[1] = 1
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedOneYellow)
                    let selectedTwoYellow = UIAlertAction(title: "TWO", style: .default) { action -> Void in
                        values[1] = 2
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedTwoYellow)
                    let selectedThreeYellow = UIAlertAction(title: "THREE", style: .default) { action -> Void in
                        values[1] = 3
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedThreeYellow)
                    let selectedFourYellow = UIAlertAction(title: "FOUR", style: .default) { action -> Void in
                        values[1] = 4
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFourYellow)
                    let selectedFiveYellow = UIAlertAction(title: "FIVE", style: .default) { action -> Void in
                        values[1] = 5
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFiveYellow)
                    let selectedSixYellow = UIAlertAction(title: "SIX", style: .default) { action -> Void in
                        values[1] = 6
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedSixYellow)
                    self.view?.window?.rootViewController?.present(actionSheetYellow, animated: true, completion: nil)
                }
                actionSheetRed.addAction(selectedThreeRed)
                let selectedFourRed = UIAlertAction(title: "FOUR", style: .default) { action -> Void in
                    values[0] = 4
                    let actionSheetYellow = UIAlertController(title: nil, message: "Select a value for the yellow dice...", preferredStyle: .alert)
                    let selectedOneYellow = UIAlertAction(title: "ONE", style: .default) { action -> Void in
                        values[1] = 1
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedOneYellow)
                    let selectedTwoYellow = UIAlertAction(title: "TWO", style: .default) { action -> Void in
                        values[1] = 2
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedTwoYellow)
                    let selectedThreeYellow = UIAlertAction(title: "THREE", style: .default) { action -> Void in
                        values[1] = 3
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedThreeYellow)
                    let selectedFourYellow = UIAlertAction(title: "FOUR", style: .default) { action -> Void in
                        values[1] = 4
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFourYellow)
                    let selectedFiveYellow = UIAlertAction(title: "FIVE", style: .default) { action -> Void in
                        values[1] = 5
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFiveYellow)
                    let selectedSixYellow = UIAlertAction(title: "SIX", style: .default) { action -> Void in
                        values[1] = 6
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedSixYellow)
                    self.view?.window?.rootViewController?.present(actionSheetYellow, animated: true, completion: nil)
                }
                actionSheetRed.addAction(selectedFourRed)
                let selectedFiveRed = UIAlertAction(title: "FIVE", style: .default) { action -> Void in
                    values[0] = 5
                    let actionSheetYellow = UIAlertController(title: nil, message: "Select a value for the yellow dice...", preferredStyle: .alert)
                    let selectedOneYellow = UIAlertAction(title: "ONE", style: .default) { action -> Void in
                        values[1] = 1
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedOneYellow)
                    let selectedTwoYellow = UIAlertAction(title: "TWO", style: .default) { action -> Void in
                        values[1] = 2
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedTwoYellow)
                    let selectedThreeYellow = UIAlertAction(title: "THREE", style: .default) { action -> Void in
                        values[1] = 3
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedThreeYellow)
                    let selectedFourYellow = UIAlertAction(title: "FOUR", style: .default) { action -> Void in
                        values[1] = 4
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFourYellow)
                    let selectedFiveYellow = UIAlertAction(title: "FIVE", style: .default) { action -> Void in
                        values[1] = 5
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFiveYellow)
                    let selectedSixYellow = UIAlertAction(title: "SIX", style: .default) { action -> Void in
                        values[1] = 6
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedSixYellow)
                    self.view?.window?.rootViewController?.present(actionSheetYellow, animated: true, completion: nil)
                }
                actionSheetRed.addAction(selectedFiveRed)
                let selectedSixRed = UIAlertAction(title: "SIX", style: .default) { action -> Void in
                    values[0] = 6
                    let actionSheetYellow = UIAlertController(title: nil, message: "Select a value for the yellow dice...", preferredStyle: .alert)
                    let selectedOneYellow = UIAlertAction(title: "ONE", style: .default) { action -> Void in
                        values[1] = 1
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedOneYellow)
                    let selectedTwoYellow = UIAlertAction(title: "TWO", style: .default) { action -> Void in
                        values[1] = 2
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedTwoYellow)
                    let selectedThreeYellow = UIAlertAction(title: "THREE", style: .default) { action -> Void in
                        values[1] = 3
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedThreeYellow)
                    let selectedFourYellow = UIAlertAction(title: "FOUR", style: .default) { action -> Void in
                        values[1] = 4
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFourYellow)
                    let selectedFiveYellow = UIAlertAction(title: "FIVE", style: .default) { action -> Void in
                        values[1] = 5
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedFiveYellow)
                    let selectedSixYellow = UIAlertAction(title: "SIX", style: .default) { action -> Void in
                        values[1] = 6
                        for index in 0..<self.players[self.myPlayerIndex].progressCards.count {
                            if self.players[self.myPlayerIndex].progressCards[index] == .Alchemist {
                                self.players[self.myPlayerIndex].progressCards.remove(at: index)
                                break
                        }   }
                        self.continueDiceRoll(values)
                    }
                    actionSheetYellow.addAction(selectedSixYellow)
                    self.view?.window?.rootViewController?.present(actionSheetYellow, animated: true, completion: nil)
                }
                actionSheetRed.addAction(selectedSixRed)
                self.view?.window?.rootViewController?.present(actionSheetRed, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action) in self.continueDiceRoll(values) }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else { continueDiceRoll(values) }
    }
    
    func continueDiceRoll(_ values: [Int]) {
        updateDice(red: values[0], yellow: values[1], event: values[2])
        let diceData = "diceRoll.\(values[0]),\(values[1]),\(values[2])"
        
        // distribute resources on own device
        print(values[0] + values[1])
        if(values[0] + values[1] != 7) {
            distributeResources(dice: values[0] + values[1])
        } else {
            if !robberRemoved {
                let _ = appDelegate.networkManager.sendData(data: "robberDiscardScenario")
                checkIfCardsNeedDiscard()
        }   }
        
        // distribute resources on other players' devices
        let sent = appDelegate.networkManager.sendData(data: diceData)
        if (!sent) {
            print ("failed to distribute resources to all players")
        }
        else {
            print ("successfully distributed resources to all players")
        }
        
        let eventDieOutcome = EventDieSides.init(rawValue: values[2])!
        //  REQUIRES ANIMATIONS
        let notificationBanner = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
        notificationBanner.isOpaque = false
        notificationBanner.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.6)
        let notificationContent = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
        notificationContent.isOpaque = false
        notificationContent.font = UIFont(name: "Avenir-Roman", size: 14)
        notificationContent.textColor = UIColor.darkGray
        notificationContent.textAlignment = .center
        switch eventDieOutcome {
            case .BarbarianSideA:   fallthrough
            case .BarbarianSideB:   fallthrough
            case .BarbarianSideC:
                barbariansDistanceFromCatan -= 1
                let _ = appDelegate.networkManager.sendData(data: "barbariansDistanceUpdate.\(barbariansDistanceFromCatan)")
                alertAboutBarbarians()
            case .PoliticsSide:
                if players[myPlayerIndex].politicsImprovementLevel + 3 > values[0] {
                    let newCard = ProgressCardsType.getNextCardOfCategory(ProgressCardsCategory.Politics, fromDeck: &gameDeck)
                    let _ = appDelegate.networkManager.sendData(data: "drewProgressCard.POLITICS")
                    if let card = newCard {
                        notificationContent.text = "You have just received The \(card) Progress Card from the Politics Deck...congratulations!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                        })
                        if card == .Constitution {
                            players[myPlayerIndex].victoryPoints += 1
                            checkWinningConditions(who: myPlayerIndex)
                        } else { players[myPlayerIndex].progressCards.append(card) }
                    } else {
                        notificationContent.text = "Unfortunately, there is no Progress Card remaining from the Politics Deck...hurry up and finish the game!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                    })
                }   }
            case .SciencesSide:
                if players[myPlayerIndex].sciencesImprovementLevel + 3 > values[0] {
                    let _ = appDelegate.networkManager.sendData(data: "drewProgressCard.SCIENCES")
                    let newCard = ProgressCardsType.getNextCardOfCategory(ProgressCardsCategory.Sciences, fromDeck: &gameDeck)
                    if let card = newCard {
                        notificationContent.text = "You have just received The \(card) Progress Card from the Sciences Deck...congratulations!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                        })
                        if card == .Printer {
                            players[myPlayerIndex].victoryPoints += 1
                            checkWinningConditions(who: myPlayerIndex)
                        } else { players[myPlayerIndex].progressCards.append(card) }
                    } else {
                        notificationContent.text = "Unfortunately, there is no Progress Card remaining from the Sciences Deck...hurry up and finish the game!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                    })
                }   }
            case .TradesSide:
                if players[myPlayerIndex].tradesImprovementLevel + 3 > values[0] {
                    let newCard = ProgressCardsType.getNextCardOfCategory(ProgressCardsCategory.Trades, fromDeck: &gameDeck)
                    let _ = appDelegate.networkManager.sendData(data: "drewProgressCard.TRADES")
                    if let card = newCard {
                        notificationContent.text = "You have just received The \(card) Progress Card from the Trades Deck...congratulations!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                    })
                        players[myPlayerIndex].progressCards.append(card)
                    } else {
                        notificationContent.text = "Unfortunately, there is no Progress Card remaining from the Trades Deck...hurry up and finish the game!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                    })
    }   }       }   }
    
    func updateDice(red : Int, yellow: Int, event: Int) {
        DispatchQueue.main.async
            {
            self.redDiceUI.image = UIImage(named: "red\(red)")!
            self.yellowDiceUI.image = UIImage(named: "yellow\(yellow)")!
            self.eventDiceUI.image = UIImage(named: "event\(event)")!
        }
    }
    
    // function that will distribute resources to all players
    func distributeResources(dice: Int) {
        print ("Dice = \(dice)")
        var numberResources : Int = 0
        let producingCoords = handler.landHexDictionary[dice]
        for (col, row) in producingCoords! {
            for player in 0..<players.count { // for each player...
                for vertex in players[player].ownedCorners { // distribute resources if vertex touches hex
                    if (vertex.cornerObject?.type == cornerType.City) {
                        numberResources = 2
                    } else {
                        numberResources = 1
                    }
                    if (vertex.tile1.column == col && vertex.tile1.row == row) {
                        // Distribute resources of type tile1.type
                        switch vertex.tile1.type! {
                            case .wood:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    players[player].wood += 1; print("\(players[player].name) mined wood")
                                    players[player].paper += 1; print("\(players[player].name) produced paper")
                                }
                                else {
                                    players[player].wood += 1; print("\(players[player].name) mined wood")
                                }
                            case .wheat: players[player].wheat += numberResources; print("\(players[player].name) mined wheat")
                            case .stone:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    players[player].stone += 1; print("\(players[player].name) mined stone")
                                    players[player].coin += 1; print("\(players[player].name) produced coin")
                                }
                                else {
                                    players[player].stone += 1; print("\(players[player].name) mined stone")
                                }
                            case .sheep:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    players[player].sheep += 1; print("\(players[player].name) mined sheep")
                                    players[player].cloth += 1; print("\(players[player].name) produced cloth")
                                }
                                else {
                                    players[player].coin += 1; print("\(players[player].name) mined sheep")
                                }
                            case .brick: players[player].brick += numberResources; print("\(players[player].name) mined brick")
                            case .gold: players[player].gold += (numberResources*2); print("\(players[player].name) mined gold")
                            case .fish:
                                var newFish = drawFishCard()
                        
                                if (newFish == -1) { /* Deck is empty */ }
                                else if (newFish == 0) {
                                    receivedOldBoot(player: player)
                                }
                                else {
                                    players[player].fish += newFish
                                    if (vertex.cornerObject?.type == cornerType.City) {
                                        newFish = drawFishCard()
                                        if (newFish == -1) { /* Deck is empty */ }
                                        else if (newFish == 0) {
                                            receivedOldBoot(player: player)
                                        }
                                        else {
                                            players[player].fish += newFish
                                        }
                                    }
                                }
                            default: break
                        }
                    }
                    if (vertex.tile2 != nil && vertex.tile2!.column == col && vertex.tile2!.row == row) {
                        // Distribute resources of type tile2.type
                        switch vertex.tile2!.type! {
                            case .wood:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    players[player].wood += 1; print("\(players[player].name) mined wood")
                                    players[player].paper += 1; print("\(players[player].name) produced paper")
                                }
                                else {
                                    players[player].wood += 1; print("\(players[player].name) mined wood")
                                }
                            case .wheat: players[player].wheat += numberResources; print("\(players[player].name) mined wheat")
                            case .stone:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    players[player].stone += 1; print("\(players[player].name) mined stone")
                                    players[player].coin += 1; print("\(players[player].name) produced coin")
                                }
                                else {
                                    players[player].stone += 1; print("\(players[player].name) mined stone")
                                }
                            case .sheep:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    players[player].sheep += 1; print("\(players[player].name) mined sheep")
                                    players[player].cloth += 1; print("\(players[player].name) produced cloth")
                                }
                                else {
                                    players[player].coin += 1; print("\(players[player].name) mined sheep")
                                }
                            case .brick: players[player].brick += numberResources; print("\(players[player].name) mined brick")
                            case .gold: players[player].gold += (numberResources*2); print("\(players[player].name) mined gold")
                            case .fish:
                             var newFish = drawFishCard()
                             
                             if (newFish == -1) { /* Deck is empty */ }
                             else if (newFish == 0) {
                                receivedOldBoot(player: player)
                             }
                             else {
                                players[player].fish += newFish
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    newFish = drawFishCard()
                                    if (newFish == -1) { /* Deck is empty */ }
                                    else if (newFish == 0) {
                                        receivedOldBoot(player: player)
                                    }
                                    else {
                                        players[player].fish += newFish
                                    }
                                }
                             }
                            default: break
                        }
                    }
                    if (vertex.tile3 != nil && vertex.tile3!.column == col && vertex.tile3!.row == row) {
                        // Distribute resources of type tile1.type
                        switch vertex.tile3!.type! {
                            case .wood:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    players[player].wood += 1; print("\(players[player].name) mined wood")
                                    players[player].paper += 1; print("\(players[player].name) produced paper")
                                }
                                else {
                                    players[player].wood += 1; print("\(players[player].name) mined wood")
                                }
                            case .wheat: players[player].wheat += numberResources; print("\(players[player].name) mined wheat")
                            case .stone:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    players[player].stone += 1; print("\(players[player].name) mined stone")
                                    players[player].coin += 1; print("\(players[player].name) produced coin")
                                }
                                else {
                                    players[player].stone += 1; print("\(players[player].name) mined stone")
                                }
                            case .sheep:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    players[player].sheep += 1; print("\(players[player].name) mined sheep")
                                    players[player].cloth += 1; print("\(players[player].name) produced cloth")
                                }
                                else {
                                    players[player].coin += 1; print("\(players[player].name) mined sheep")
                                }
                            case .brick: players[player].brick += numberResources; print("\(players[player].name) mined brick")
                            case .gold: players[player].gold += (numberResources*2); print("\(players[player].name) mined gold")
                            case .fish:
                             var newFish = drawFishCard()
                             
                             if (newFish == -1) { /* Deck is empty */ }
                             else if (newFish == 0) {
                                receivedOldBoot(player: player)
                             }
                             else {
                                players[player].fish += newFish
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    newFish = drawFishCard()
                                    if (newFish == -1) { /* Deck is empty */ }
                                    else if (newFish  == 0) {
                                        receivedOldBoot(player: player)
                                    }
                                    else {
                                        players[player].fish += newFish
                                    }
                                }
                             }
                        default: break
                        }
                    }
                }
            }
        }
        print(players[myPlayerIndex].getPlayerText())
    }
    
    func receivedOldBoot(player: Int) {
        players[player].hasOldBoot = true
        
        let bootNofication = "oldBoot.\(player).true"
        let sentBoot = appDelegate.networkManager.sendData(data: bootNofication)
        if !sentBoot { print("failed to send boot") }
        
        if (player == myPlayerIndex) {
            self.view?.addSubview(oldBootButton)
        }
        
        let alert = UIAlertController(title: "You Have Received The Old Boot", message: "The old boot adds one victory point you need to win the game. You can give the boot to anyone who has more victory points, or the same number of victory points as you.", preferredStyle: UIAlertControllerStyle.alert)
        let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            // Do nothing
        }
        alert.addAction(okay)
        
        OperationQueue.main.addOperation { () -> Void in
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func bootFromMessage(player: Int, hasBoot: Bool) {
        players[player].hasOldBoot = hasBoot
        
        print("\(players[player].name) has received boot (\(hasBoot))")
        
        if (player == myPlayerIndex && hasBoot) {
            
            DispatchQueue.main.async {
                self.view?.addSubview(self.oldBootButton)
            }
            
            let alert = UIAlertController(title: "You Have Received The Old Boot", message: "The old boot adds one victory point you need to win the game. You can give the boot to anyone who has more or the same number of victory points as you.", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (alertAction) -> Void in
                // Do nothing
            }
            alert.addAction(okay)
            
            OperationQueue.main.addOperation { () -> Void in
                self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
        else if (player == myPlayerIndex) {
            DispatchQueue.main.async {
                self.oldBootButton.removeFromSuperview()
            }

        }
        else if (hasBoot) {
            let alert = UIAlertController(title: "Old Boot", message: "\(players[player].name) (\(players[player].color.rawValue)) now has the old boot", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (alertAction) -> Void in
                // Do nothing
            }
            alert.addAction(okay)
            
            OperationQueue.main.addOperation { () -> Void in
                self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func canGiveBoot(to: Int) -> Bool {
        if players[to].victoryPoints >= players[myPlayerIndex].victoryPoints {
            return true
        }
        return false
    }
    func giveOldBootAway(to: Int) {
        players[myPlayerIndex].hasOldBoot = false
        players[to].hasOldBoot = true
        
        var bootNofication = "oldBoot.\(myPlayerIndex).false"
        var sentBoot = appDelegate.networkManager.sendData(data: bootNofication)
        if !sentBoot { print("failed to send boot") }
        
        DispatchQueue.main.async {
            self.oldBootButton.removeFromSuperview()
        }
        
        bootNofication = "oldBoot.\(to).true"
        sentBoot = appDelegate.networkManager.sendData(data: bootNofication)
        if !sentBoot { print("failed to send boot") }

    }
    func showBootMenu() {
        //if (!players[myPlayerIndex].hasOldBoot || showingBootMenu) { return }
        
        showingBootMenu = true
        
        let alert = UIAlertController(title: "Send Old Boot", message: "Select a player to send the boot to.", preferredStyle: UIAlertControllerStyle.alert)
        
        let p1 = (myPlayerIndex + 1) % players.count
        var p2 = myPlayerIndex - 1; if (p2 == -1) {p2 = players.count - 1}
        
        let player1: UIAlertAction = UIAlertAction(title: "\(players[p1].color.rawValue) player", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.giveOldBootAway(to: p1)
            self.showingBootMenu = false
        }
        let player2 = UIAlertAction(title: "\(players[p2].color.rawValue) player", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.giveOldBootAway(to: p2)
            self.showingBootMenu = false
        }
        let noPlayer = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.showingBootMenu = false
        }

        var valid = 0
        if (canGiveBoot(to: p1)) {
            alert.addAction(player1)
            valid += 1
        }
        if (canGiveBoot(to: p2) && players.count > 2) {
            alert.addAction(player2)
            valid += 1
        }
        
        alert.addAction(noPlayer)
        
        OperationQueue.main.addOperation { () -> Void in
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func distributeResourcesOnSetup(vertex: LandHexVertex)
    {
        // Distribute resources of type tile1.type
        switch vertex.tile1.type! {
            case .wood: players[myPlayerIndex].wood += 1
            case .wheat: players[myPlayerIndex].wheat += 1
            case .stone: players[myPlayerIndex].stone += 1
            case .sheep: players[myPlayerIndex].sheep += 1
            case .brick: players[myPlayerIndex].brick += 1
            case .gold: players[myPlayerIndex].gold += 2
            default: break
        }
        if (vertex.tile2 != nil) {
            // Distribute resources of type tile1.type
            switch vertex.tile2!.type! {
            case .wood: players[myPlayerIndex].wood += 1
            case .wheat: players[myPlayerIndex].wheat += 1
            case .stone: players[myPlayerIndex].stone += 1
            case .sheep: players[myPlayerIndex].sheep += 1
            case .brick: players[myPlayerIndex].brick += 1
            case .gold: players[myPlayerIndex].gold += 2
            default: break
            }
        }
        if (vertex.tile3 != nil) {
            // Distribute resources of type tile1.type
            switch vertex.tile3!.type! {
            case .wood: players[myPlayerIndex].wood += 1
            case .wheat: players[myPlayerIndex].wheat += 1
            case .stone: players[myPlayerIndex].stone += 1
            case .sheep: players[myPlayerIndex].sheep += 1
            case .brick: players[myPlayerIndex].brick += 1
            case .gold: players[myPlayerIndex].gold += 2
            default: break
            }
        }
        
        sendPlayerData(player: myPlayerIndex)
        sendFishDeck()
    }
    
    // Encode's player's resources and sends to other players
    func sendPlayerData(player: Int) {
        var pData = "updatePlayerData.\(player),"
        pData.append("\(players[player].wood),")
        pData.append("\(players[player].wheat),")
        pData.append("\(players[player].stone),")
        pData.append("\(players[player].sheep),")
        pData.append("\(players[player].brick),")
        pData.append("\(players[player].gold),")
        pData.append("\(players[player].paper),")
        pData.append("\(players[player].cloth),")
        pData.append("\(players[player].coin),")
        pData.append("\(players[player].fish)")
        
        let sent = appDelegate.networkManager.sendData(data: pData)
        if (!sent) {
            print ("Failed to send player data")
        }

    }
    
    // Decodes and sets resources of a specific player
    func recievePlayerData(data: String) {
        let playerData = data.components(separatedBy: ",")
        
        let player = Int(playerData[0])!
        let wood = Int(playerData[1])!
        let wheat = Int(playerData[2])!
        let stone = Int(playerData[3])!
        let sheep = Int(playerData[4])!
        let brick = Int(playerData[5])!
        let gold = Int(playerData[6])!
        let paper = Int(playerData[7])!
        let cloth = Int(playerData[8])!
        let coin = Int(playerData[9])!
        let fish = Int(playerData[10])!
        
        players[player].wood = wood
        players[player].wheat = wheat
        players[player].stone = stone
        players[player].sheep = sheep
        players[player].brick = brick
        players[player].gold = gold
        players[player].paper = paper
        players[player].cloth = cloth
        players[player].coin = coin
        players[player].fish = fish
    }
    
    func sendFishDeck()
    {
        var data = "fishdeck."
        for card in fishDeck
        {
            data.append("\(card.value),")
        }
        let sent = appDelegate.networkManager.sendData(data: data)
        if (!sent)
        {
            print("Failed to send fish deck")
        }
    }
    
    func recievedFishDeck(encoding: String)
    {
        fishDeck.removeAll()
        let deckData = encoding.components(separatedBy: ",").dropLast()
        for fishCard in deckData
        {
            let fishValue = Int(fishCard)!
            fishDeck.append(FishToken(v: fishValue))
        }
    }
    
    func shuffleFish(deck: [FishToken])
    {
        var newDeck : [FishToken] = []
        while(fishDeck.count > 0)
        {
            let randIndex = arc4random_uniform(UInt32(fishDeck.count))
            let card = fishDeck.remove(at: Int(randIndex))
            newDeck.append(card)
        }
        fishDeck = newDeck
    }
    
    func drawFishCard() -> Int {
        if (fishDeck.count == 0) {
            return -1
        }
        
        let fish = fishDeck.remove(at: 0)
        if fish.value != 0 {
            fishDeck.append(fish);
        }
        sendFishDeck()
        return fish.value
    }
    
    func endTurn(player: Int) {
        players[player].merchantFleetSelect = nil
        players[player].nextAction = .WillDoNothing
        for knightCorner in players[player].ownedKnights {
            let knight = knightCorner.cornerObject
            knight?.hasBeenUpgradedThisTurn = false
            knight?.didActionThisTurn = false
        }
        
        for edge in players[player].ownedEdges {
            edge.edgeObject?.justBuilt = false
        }
        
        players[player].movedShipThisTurn = false
    }
    
    
    //function to handle pan gestures for camera movement
    func handlePanFrom(recognizer: UIPanGestureRecognizer) {
        if recognizer.state != .changed {
            return
        }
        
        //get translation amount
        let translation = recognizer.translation(in: recognizer.view!)
        
        //move cam
        cam.position.x -= translation.x
        cam.position.y += translation.y
        
        //reset tranlation
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
    }
    
    func handleRightEdgeSwipe(recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state != .changed { return }
            if !detailsStarted {
                detailsStarted = true
                let player = players[myPlayerIndex]
                let notificationBanner = UIView(frame: CGRect(x: 50.0, y: 50.0, width: self.view!.bounds.width - 100.0, height: self.view!.bounds.height - 100.0))
                notificationBanner.isOpaque = false
                notificationBanner.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.8)
                let notificationContent = UILabel(frame: CGRect(x: 50.0, y: 50.0, width: self.view!.bounds.width - 100.0, height: self.view!.bounds.height - 100.0))
                notificationContent.isOpaque = false
                notificationContent.font = UIFont(name: "Avenir-Roman", size: 11)
                notificationContent.textColor = UIColor.darkGray
                notificationContent.textAlignment = .center
                notificationContent.numberOfLines = 0
                notificationContent.text = "Current Holdings:\n~ Resources ~\nBrick: \(player.brick)\nGold: \(player.gold)\nSheep: \(player.sheep)\nStone: \(player.stone)\nWheat: \(player.wheat)\nWood: \(player.wood)\n\n~ Commodities ~\nCloth: \(player.cloth)\nCoin: \(player.coin)\nPaper: \(player.paper)\n\nFish: \(player.fish)"
                self.view?.addSubview(notificationBanner)
                self.view?.addSubview(notificationContent)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    notificationContent.removeFromSuperview()
                    notificationBanner.removeFromSuperview()
                    self.detailsStarted = false
                })
    }   }
    
    //function to handle pinch gestures for camera scaling
    func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if recognizer.state != .changed {
            return
        }
        
        //scale cam
        cam.xScale *= 1/recognizer.scale
        cam.yScale *= 1/recognizer.scale
        
        //clamp cam
        if (cam.xScale > 0.9) {cam.xScale = 0.9}
        if (cam.xScale < 0.35) {cam.xScale = 0.35}
        if (cam.yScale > 0.9) {cam.yScale = 0.9}
        if (cam.yScale < 0.35) {cam.yScale = 0.35}
        
        //reset scale
        recognizer.scale = 1
    }
    
    func alertAboutBarbarians() {
        let notificationBanner = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
        notificationBanner.isOpaque = false
        notificationBanner.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.6)
        let barbarianAlert = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
        barbarianAlert.isOpaque = false
        barbarianAlert.font = UIFont(name: "Avenir-Roman", size: 14)
        barbarianAlert.textColor = UIColor.darkGray
        barbarianAlert.textAlignment = .center
        switch barbariansDistanceFromCatan {
            case 0:
                barbarianAttack()
                barbariansDistanceFromCatan = 7
            break   //  PERFORM SCENARIO AND RESET DISTANCE TO 7 AND SEND NEW DATA TO OTHER PLAYERS
            case 1...2:
                barbarianAlert.text = "The Barbarians are \(barbariansDistanceFromCatan) roll" + (barbariansDistanceFromCatan == 2 ? "s" : "") + " away from Catan, and will be attacking shortly!"
                DispatchQueue.main.async {
                    self.view?.addSubview(notificationBanner)
                    self.view?.addSubview(barbarianAlert)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    barbarianAlert.removeFromSuperview()
                    notificationBanner.removeFromSuperview()
                })
            case 3...5:
                barbarianAlert.text = "The Barbarians are \(barbariansDistanceFromCatan) rolls away from Catan, and will be attacking soon!"
                DispatchQueue.main.async {
                    self.view?.addSubview(notificationBanner)
                    self.view?.addSubview(barbarianAlert)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    barbarianAlert.removeFromSuperview()
                    notificationBanner.removeFromSuperview()
                })
            case 6...7:
                barbarianAlert.text = "The Barbarians are \(barbariansDistanceFromCatan) rolls away from Catan, start preparing!"
                DispatchQueue.main.async {
                    self.view?.addSubview(notificationBanner)
                    self.view?.addSubview(barbarianAlert)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    barbarianAlert.removeFromSuperview()
                    notificationBanner.removeFromSuperview()
                })
            default: break
    }   }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if (touches.count > 1) { return }
        let targetLocation = touch.location(in: self)
        let targetLocationView = touch.location(in: self.view!)
        print (currGamePhase)
        
        if(currentPlayer == myPlayerIndex) { //only accept taps if it's your turn
            switch currGamePhase {
            case .placeFirstSettlement :
                if (placeCornerObject(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), type: cornerType.Settlement, setup:false)) {
                    currGamePhase = GamePhase.placeFirstRoad
                    gameText.text = "Place First Road"
                }
            case .placeFirstRoad :
                if (placeEdgeObject(column: handler.Edges.tileColumnIndex(fromPosition: targetLocation), row:  handler.Edges.tileRowIndex(fromPosition: targetLocation), type: edgeType.Road)) {
                    gameText.text = "Place Second Settlement"
                    
                    if(currentPlayer == players.count-1) {
                        currGamePhase = GamePhase.placeSecondSettlement
                    } else {
                        currGamePhase = GamePhase.wait
                        gameText.isHidden = true
                        currentPlayer = currentPlayer+1
                        sendNewCurrPlayer()
                    }
                }
            case .placeSecondSettlement :
                if (placeCornerObject(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row:  handler.Vertices.tileRowIndex(fromPosition: targetLocation), type: cornerType.City, setup:true)) {
                    currGamePhase = GamePhase.placeSecondRoad
                    gameText.text = "Place Second Road"
                }
            case .placeSecondRoad :
                if (placeEdgeObject(column: handler.Edges.tileColumnIndex(fromPosition: targetLocation), row:  handler.Edges.tileRowIndex(fromPosition: targetLocation), type: edgeType.Road)) {
                    currGamePhase = GamePhase.wait
                    if (currentPlayer == 0) {
                        currGamePhase = GamePhase.p1Turn
                        gameText.text = "P1 Turn"
                    } else {
                        currentPlayer = currentPlayer-1
                        sendNewCurrPlayer()
                        sendNewGamePhase(gamePhase : GamePhase.placeSecondSettlement)
                        gameText.isHidden = true
                    }
                }
            case .p1Turn :
                if (redDiceUI.frame.contains(targetLocationView) || yellowDiceUI.frame.contains(targetLocationView) || eventDiceUI.frame.contains(targetLocationView)) {
                    if(!rolled) {
                        rollDice()
                        rolled = true
                    }
                }
                if (cancelButton.frame.contains(targetLocationView) && players[myPlayerIndex].nextAction != .WillBuildMetropolis) {
                    if players[myPlayerIndex].nextAction == .WillRemoveOutlaw { players[myPlayerIndex].fish += 2 }
                    if players[myPlayerIndex].comingFromFishes {
                        players[myPlayerIndex].fish += 5
                        players[myPlayerIndex].comingFromFishes = false
                    }
                    if players[myPlayerIndex].nextAction == .WillBuildKnightForFree {
                        let corner = handler.landHexVertexArray.first(where: {$0.row == players[myPlayerIndex].movingKnightFromRow && $0.column == players[myPlayerIndex].movingKnightFromCol})
                        
                        corner!.cornerObject = cornerObject(cornerType : .Knight, owner: myPlayerIndex)
                        corner!.cornerObject!.strength = players[myPlayerIndex].movingKnightStrength
                        corner!.cornerObject!.hasBeenUpgradedThisTurn = players[myPlayerIndex].movingKnightUpgraded
                        corner!.cornerObject!.isActive = true
                        corner!.cornerObject!.didActionThisTurn = false
                        players[myPlayerIndex].ownedKnights.append(corner!)
                        
                        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[myPlayerIndex].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
                        handler.Vertices.setTileGroup(tileGroup, forColumn: corner!.column, row: corner!.row)
                        
                        let cornerObjectInfo = "cornerData.\(myPlayerIndex),\(corner!.column),\(corner!.row),\(corner!.cornerObject!.type.rawValue),\(corner!.cornerObject!.strength),\(corner!.cornerObject!.isActive),\(corner!.cornerObject!.hasBeenUpgradedThisTurn),\(corner!.cornerObject!.didActionThisTurn)"
                        
                        // Send player info to other players
                        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
                        if (!sent) {
                            print ("failed to sync cornerObject")
                        }
                    }

                    players[myPlayerIndex].nextAction = .WillDoNothing
                    cancelButton.backgroundColor = UIColor.gray
                }
                if (oldBootButton.frame.contains(targetLocationView)) {
                    if (!showingBootMenu && players[myPlayerIndex].hasOldBoot) {
                        showBootMenu()
                    }
                }
                if (self.gameButton.frame.contains(targetLocationView)) {
                    var ready = true
                    for p in players {
                        if p.nextAction != .WillDoNothing {ready = false; break}
                    }
                    if (rolled && ready && !showingBootMenu) {
                        endTurn(player: currentPlayer)
                        currentPlayer = currentPlayer + 1
                        currGamePhase = GamePhase.p2Turn
                        sendNewCurrPlayer()
                        sendNewGamePhase(gamePhase: currGamePhase)
                        rolled = false
                        DispatchQueue.main.async {
                            self.gameButton.backgroundColor = UIColor.gray
                        }
                    }
                }
                handleButtonTouches(targetLocationView: targetLocationView, targetLocation: targetLocation)
                
            case .p2Turn :
                if (redDiceUI.frame.contains(targetLocationView) || yellowDiceUI.frame.contains(targetLocationView) || eventDiceUI.frame.contains(targetLocationView)) {
                    if(!rolled) {
                        rollDice()
                        rolled = true
                    }
                }
                if (cancelButton.frame.contains(targetLocationView) && players[myPlayerIndex].nextAction != .WillBuildMetropolis) {
                    if players[myPlayerIndex].nextAction == .WillRemoveOutlaw { players[myPlayerIndex].fish += 2 }
                    if players[myPlayerIndex].comingFromFishes {
                        players[myPlayerIndex].fish += 5
                        players[myPlayerIndex].comingFromFishes = false
                    }
                    if players[myPlayerIndex].nextAction == .WillBuildKnightForFree {
                        let corner = handler.landHexVertexArray.first(where: {$0.row == players[myPlayerIndex].movingKnightFromRow && $0.column == players[myPlayerIndex].movingKnightFromCol})
                        
                        corner!.cornerObject = cornerObject(cornerType : .Knight, owner: myPlayerIndex)
                        corner!.cornerObject!.strength = players[myPlayerIndex].movingKnightStrength
                        corner!.cornerObject!.hasBeenUpgradedThisTurn = players[myPlayerIndex].movingKnightUpgraded
                        corner!.cornerObject!.isActive = true
                        corner!.cornerObject!.didActionThisTurn = false
                        players[myPlayerIndex].ownedKnights.append(corner!)
                        
                        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[myPlayerIndex].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
                        handler.Vertices.setTileGroup(tileGroup, forColumn: corner!.column, row: corner!.row)
                        
                        let cornerObjectInfo = "cornerData.\(myPlayerIndex),\(corner!.column),\(corner!.row),\(corner!.cornerObject!.type.rawValue),\(corner!.cornerObject!.strength),\(corner!.cornerObject!.isActive),\(corner!.cornerObject!.hasBeenUpgradedThisTurn),\(corner!.cornerObject!.didActionThisTurn)"
                        
                        // Send player info to other players
                        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
                        if (!sent) {
                            print ("failed to sync cornerObject")
                        }
                    }

                    players[myPlayerIndex].nextAction = .WillDoNothing
                    cancelButton.backgroundColor = UIColor.gray
                }
                if (oldBootButton.frame.contains(targetLocationView)) {
                    if (!showingBootMenu && players[myPlayerIndex].hasOldBoot) {
                        showBootMenu()
                    }
                }
                if (self.gameButton.frame.contains(targetLocationView)) {
                    var ready = true
                    for p in players {
                        if p.nextAction != .WillDoNothing {ready = false; break}
                    }
                    if (rolled && ready && !showingBootMenu) {
                        endTurn(player: currentPlayer)
                        currentPlayer = (currentPlayer + 1) % players.count
                        if (currentPlayer == 2) {
                            currGamePhase = GamePhase.p3Turn
                        } else {
                            currGamePhase = GamePhase.p1Turn
                        }
                        sendNewCurrPlayer()
                        sendNewGamePhase(gamePhase: currGamePhase)
                        rolled = false
                        DispatchQueue.main.async {
                            self.gameButton.backgroundColor = UIColor.gray
                        }
                    }
                }
                handleButtonTouches(targetLocationView: targetLocationView, targetLocation: targetLocation)
                
            case .p3Turn :
                if (redDiceUI.frame.contains(targetLocationView) || yellowDiceUI.frame.contains(targetLocationView) || eventDiceUI.frame.contains(targetLocationView)) {
                    if(!rolled) {
                        rollDice()
                        rolled = true
                    }
                }
                if (cancelButton.frame.contains(targetLocationView) && players[myPlayerIndex].nextAction != .WillBuildMetropolis) {
                    if players[myPlayerIndex].nextAction == .WillRemoveOutlaw { players[myPlayerIndex].fish += 2 }
                    if players[myPlayerIndex].comingFromFishes {
                        players[myPlayerIndex].fish += 5
                        players[myPlayerIndex].comingFromFishes = false
                    }
                    if players[myPlayerIndex].nextAction == .WillBuildKnightForFree {
                        let corner = handler.landHexVertexArray.first(where: {$0.row == players[myPlayerIndex].movingKnightFromRow && $0.column == players[myPlayerIndex].movingKnightFromCol})
                        
                        corner!.cornerObject = cornerObject(cornerType : .Knight, owner: myPlayerIndex)
                        corner!.cornerObject!.strength = players[myPlayerIndex].movingKnightStrength
                        corner!.cornerObject!.hasBeenUpgradedThisTurn = players[myPlayerIndex].movingKnightUpgraded
                        corner!.cornerObject!.isActive = true
                        corner!.cornerObject!.didActionThisTurn = false
                        players[myPlayerIndex].ownedKnights.append(corner!)
                        
                        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[myPlayerIndex].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
                        handler.Vertices.setTileGroup(tileGroup, forColumn: corner!.column, row: corner!.row)
                        
                        let cornerObjectInfo = "cornerData.\(myPlayerIndex),\(corner!.column),\(corner!.row),\(corner!.cornerObject!.type.rawValue),\(corner!.cornerObject!.strength),\(corner!.cornerObject!.isActive),\(corner!.cornerObject!.hasBeenUpgradedThisTurn),\(corner!.cornerObject!.didActionThisTurn)"
                        
                        // Send player info to other players
                        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
                        if (!sent) {
                            print ("failed to sync cornerObject")
                        }
                    }
                    players[myPlayerIndex].nextAction = .WillDoNothing
                    cancelButton.backgroundColor = UIColor.gray
                }
                if (oldBootButton.frame.contains(targetLocationView)) {
                    if (!showingBootMenu && players[myPlayerIndex].hasOldBoot) {
                        showBootMenu()
                    }
                }
                if (self.gameButton.frame.contains(targetLocationView)) {
                    var ready = true
                    for p in players {
                        if p.nextAction != .WillDoNothing {ready = false; break}
                    }
                    if (rolled && ready && !showingBootMenu) {
                        endTurn(player: currentPlayer)
                        currentPlayer = 0
                        currGamePhase = GamePhase.p1Turn
                        sendNewCurrPlayer()
                        sendNewGamePhase(gamePhase: currGamePhase)
                        rolled = false
                        DispatchQueue.main.async {
                            self.gameButton.backgroundColor = UIColor.gray
                        }
                    }
                }
                handleButtonTouches(targetLocationView: targetLocationView, targetLocation: targetLocation)
                
            default : break
            }
        }
        else {
            handleButtonTouches(targetLocationView: targetLocationView, targetLocation: targetLocation)
        }
    }
    
    func handleButtonTouches(targetLocationView: CGPoint, targetLocation: CGPoint) {
        
        //  TEMPORARY TEST CODE FOR REWIRING FLIP CHART FUNCTIONALITIES TO BUTTON HANDLING CODE (RESET INTENTIONS AFTERWARDS)
        
        if (currGamePhase == .p1Turn || currGamePhase == .p2Turn || currGamePhase == .p3Turn) && currentPlayer == myPlayerIndex {
            
            switch players[myPlayerIndex].nextAction {
                case .WillDoNothing: break
                case .WillBuildRoad:
                    let roadHasBeenBuilt = buildRoad(column: handler.Edges.tileColumnIndex(fromPosition: targetLocation), row: handler.Edges.tileRowIndex(fromPosition: targetLocation), type: edgeType.Road, valid:rolled)
                    if roadHasBeenBuilt { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillBuildRoadForFree:
                    let roadHasBeenBuilt = buildRoad(column: handler.Edges.tileColumnIndex(fromPosition: targetLocation), row: handler.Edges.tileRowIndex(fromPosition: targetLocation), type: edgeType.Road, valid:rolled)
                    if roadHasBeenBuilt { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillBuildShip:
                    let shipHasBeenBuilt = buildShip(column: handler.Edges.tileColumnIndex(fromPosition: targetLocation), row: handler.Edges.tileRowIndex(fromPosition: targetLocation), type: edgeType.Boat, valid:rolled)
                    if shipHasBeenBuilt { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillBuildShipForFree:
                    let shipHasBeenBuilt = buildShip(column: handler.Edges.tileColumnIndex(fromPosition: targetLocation), row: handler.Edges.tileRowIndex(fromPosition: targetLocation), type: edgeType.Boat, valid:rolled)
                    if shipHasBeenBuilt { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillBuildSettlement:
                    let settlementHasBeenBuilt = buildSettlement(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if settlementHasBeenBuilt { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillBuildCity:
                    let cityHasBeenBuilt = upgradeSettlement(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if cityHasBeenBuilt { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillBuildWall:
                    let built = buildCityWall(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if built { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillBuildKnight:
                    let built = buildKnight(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if (built) { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillPromoteKnight:
                    let upgraded = upgradeKnight(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if (upgraded) { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillActivateKnight:
                    let activated = activateKnight(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if (activated) { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillBuildMetropolis:
                    let built = buildMetropolis(col: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if built {
                        players[myPlayerIndex].nextAction = .WillDoNothing
                        let message = "intentToBuildMetropolis.\(myPlayerIndex).false"
                        let sentM = appDelegate.networkManager.sendData(data: message)
                        if !sentM { print("unable to sync message") }
                        players[myPlayerIndex].canBuildMetropolis -= 1
                    }
                case .WillRemoveMetropolis:
                    let removed = reduceMetropolis(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if removed {players[myPlayerIndex].nextAction = .WillDoNothing}
                case .WillRemoveOutlaw: return;   //  NOT IMPLEMENTED, FISHES ALREADY REMOVED BEFOREHAND
                case .WillMoveShip: let movedShip = moveShip(column: handler.Edges.tileColumnIndex(fromPosition: targetLocation), row: handler.Edges.tileRowIndex(fromPosition: targetLocation), valid: rolled)
                if !movedShip { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillMoveKnight:
                    let movedKnight = moveKnight(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid: rolled)
                    if (movedKnight) { players[currentPlayer].nextAction = .WillBuildKnightForFree }
                case .WillMoveOutlaw: return;   //  NOT IMPLEMENTED
                case .WillBuildKnightForFree:
                    let movedKnight = placeKnightForFree(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid: rolled, displacable: true)
                    if movedKnight { players[currentPlayer].nextAction = .WillDoNothing }
                case .WillDisplaceKnight:
                    let movedKnight = placeKnightForFree(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid: true, displacable: false)
                    if movedKnight {
                        players[currentPlayer].nextAction = .WillDoNothing
                    }
                case .WillDestroyCity:
                    let destroyedCity = destroyCity(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), who: currentPlayer)
                    if destroyedCity {players[currentPlayer].nextAction = .WillDoNothing }
                case .WillMovePirate:
                    let pirateMoved = movePirate(column: handler.landBackground.tileColumnIndex(fromPosition: targetLocation), row: handler.landBackground.tileRowIndex(fromPosition: targetLocation), valid: rolled)
                    if(pirateMoved) {
                        let playersToStealFrom = getPlayersToStealFrom(column: handler.landBackground.tileColumnIndex(fromPosition: targetLocation), row: handler.landBackground.tileRowIndex(fromPosition: targetLocation))
                        
                        for targetIndex in playersToStealFrom { stealFromPlayer(targetIndex) }
                        
                        players[currentPlayer].nextAction = .WillDoNothing
                    }
                case .WillMoveRobber:
                    let robberMoved = moveRobber(column: handler.landBackground.tileColumnIndex(fromPosition: targetLocation), row: handler.landBackground.tileRowIndex(fromPosition: targetLocation), valid: rolled)
                    if(robberMoved) {
                        let playersToStealFrom = getPlayersToStealFrom(column: handler.landBackground.tileColumnIndex(fromPosition: targetLocation), row: handler.landBackground.tileRowIndex(fromPosition: targetLocation))
                        
                        for targetIndex in playersToStealFrom { stealFromPlayer(targetIndex) }
                        
                        players[currentPlayer].nextAction = .WillDoNothing
                    }
           }
            
        }
        else if (currGamePhase == .p1Turn || currGamePhase == .p2Turn || currGamePhase == .p3Turn) {
            // If it's not your turn but an action is still required
            switch players[myPlayerIndex].nextAction {
                case .WillDisplaceKnight:
                    let movedKnight = placeKnightForFree(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid: true, displacable: false)
                    if movedKnight {
                        players[myPlayerIndex].nextAction = .WillDoNothing
                        let sent = self.appDelegate.networkManager.sendData(data: "intentions.\(myPlayerIndex).WillDoNothing")
                        if !sent {print("failed to send player intentions")}
                    }
                case .WillDestroyCity:
                    let destroyedCity = destroyCity(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), who: myPlayerIndex)
                    if destroyedCity {
                        players[myPlayerIndex].nextAction = .WillDoNothing
                        let sent = self.appDelegate.networkManager.sendData(data: "intentions.\(myPlayerIndex).WillDoNothing")
                        if !sent {print("failed to send player intentions")}
                    }
                case .WillRemoveMetropolis:
                    let removed = reduceMetropolis(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if removed {
                        players[myPlayerIndex].nextAction = .WillDoNothing
                        players[myPlayerIndex].nextAction = .WillDoNothing
                        let sent = self.appDelegate.networkManager.sendData(data: "intentions.\(myPlayerIndex).WillDoNothing")
                        if !sent {print("failed to send player intentions")}
                }
                default: break
            }
        }
        
        if players[myPlayerIndex].nextAction == .WillDoNothing {
            cancelButton.backgroundColor = UIColor.gray
        }
    }
    
    func checkWinningConditions(who: Int) {
        var reqVP = requiredVictoryPoints
        if (players[who].hasOldBoot) { reqVP += 1 }
        if reqVP <= players[who].victoryPoints {
            let announcement = "\(players[who].name) (\(players[who].color.rawValue)) has conquered Catan!"
            let alert = UIAlertController(title: "Game Over", message: announcement, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "CONTINUE", style: .default, handler: { (action) in
                //  END GAME AND RETURN TO MAIN MENU

            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func give(victoryPoints: Int, to: Int) {
        players[to].victoryPoints += victoryPoints
        let message = "victoryPoints.\(to).\(players[to].victoryPoints)"
        let sentVP = appDelegate.networkManager.sendData(data: message)
        if !sentVP { print("failed to sync victory points") }
        
        checkWinningConditions(who: to)
    }
    
    func saveGame(filename: String) {
        var gameState = "GAMEBOARD|"
        for hex in handler.landHexArray {
            var value = 0
            searching: for j in 2...12 {
                let positions = handler.landHexDictionary[j]
                if (positions == nil) { continue }
                for (col, rw) in positions! {
                    if (col == hex.column && rw == hex.row) {
                        value = j
                        break searching
                    }
                }
            }
            var type: Int!
            switch hex.type! {
            case .wood: type = 0
            case .wheat: type = 1
            case .stone: type = 2
            case .sheep: type = 3
            case .brick: type = 4
            case .gold: type = 5
            case .fish: type = 7
            default: type = 6
            }
            gameState.append("\(hex.column),\(hex.row),\(type!),\(value);")
        }
        
        //  updates other player's progress cards data
        players[myPlayerIndex].receivedPeersCards = false
        let _ = appDelegate.networkManager.sendData(data: "broadcastProgressCards.\((myPlayerIndex + 1) % 3)")
        while !players[myPlayerIndex].receivedPeersCards { }
        players[myPlayerIndex].receivedPeersCards = false
        let _ = appDelegate.networkManager.sendData(data: "broadcastProgressCards.\((myPlayerIndex + 2) % 3)")
        while !players[myPlayerIndex].receivedPeersCards { }
        players[myPlayerIndex].dataReceived = false
        let _ = appDelegate.networkManager.sendData(data: "getMiscellaneousData.\((myPlayerIndex + 1) % 3)")
        while !players[myPlayerIndex].dataReceived { }
        players[myPlayerIndex].dataReceived = false
        let _ = appDelegate.networkManager.sendData(data: "getMiscellaneousData.\((myPlayerIndex + 2) % 3)")
        while !players[myPlayerIndex].dataReceived { }
        
        for index in 0..<players.count {
            let player = players[index]
            gameState.append(".PLAYER|\(player.name)|\(index)|\(player.color.rawValue)|\(player.brick)|\(player.brickTradeRatio)|\(player.wheat)|\(player.wheatTradeRatio)|\(player.wood)|\(player.woodTradeRatio)|\(player.sheep)|\(player.sheepTradeRatio)|\(player.stone)|\(player.stoneTradeRatio)|\(player.gold)|\(player.goldTradeRatio)|\(player.paper)|\(player.paperTradeRatio)|\(player.coin)|\(player.coinTradeRatio)|\(player.cloth)|\(player.clothTradeRatio)|\(player.fish)|\(player.victoryPoints)|\(player.hasOldBoot)|\(player.politicsImprovementLevel)|\(player.tradesImprovementLevel)|\(player.sciencesImprovementLevel)|\(player.holdsTradesMetropolis)|\(player.holdsPoliticsMetropolis)|\(player.holdsSciencesMetropolis)|\(player.nextAction.rawValue)|\(player.longestRoad)|\(player.movingKnightStrength)|\(player.movingKnightFromCol)|\(player.movingKnightFromRow)|\(player.movingKnightUpgraded)|\(player.movedShipThisTurn)")
            
            gameState.append(".PLAYERCORNERS|\(index)")
            for corner in player.ownedCorners {
                gameState.append("|\(corner.row),\(corner.column),\(corner.cornerObject!.type.rawValue),\(corner.cornerObject!.hasCityWall),\(corner.isHarbour),\(corner.harbourType?.rawValue ?? harbourType.General.rawValue)")
            }
            gameState.append(".PLAYEREDGES|\(index)")
            for edge in player.ownedEdges {
                gameState.append("|\(edge.row),\(edge.column),\(edge.edgeObject!.type.rawValue),\(edge.edgeObject!.justBuilt)")
            }
            gameState.append(".PLAYERKNIGHTS|\(index)")
            for knight in player.ownedKnights {
                gameState.append("|\(knight.row),\(knight.column),\(knight.cornerObject!.strength),\(knight.cornerObject!.isActive),\(knight.cornerObject!.hasBeenUpgradedThisTurn),\(knight.cornerObject!.didActionThisTurn)")
            }
            gameState.append(".PLAYERPROGRESSCARDS|\(index)")
            for card in player.progressCards {
                gameState.append("|\(card.rawValue)")
            }
        }
        gameState.append(".GAMEPROGRESSCARDS")
        for card in gameDeck {
            gameState.append("|\(card!.rawValue)")
        }
        gameState.append(".GAMEFISHDECK")
        for fish in fishDeck {
            gameState.append("|\(fish.value)")
        }
        gameState.append(".GAMEDATA|\(currGamePhase.rawValue)|\(dice.redValue)|\(dice.yellowValue)|\(dice.eventValue)|\(currentPlayer)|\(rolled)|\(politicsMetropolisPlaced)|\(sciencesMetropolisPlaced)|\(tradesMetropolisPlaced)|\(maximaPoliticsImprovementReached)|\(maximaSciencesImprovementReached)|\(maximaTradesImprovementReached)|\(pirateRemoved)|\(robberRemoved)|\(barbariansDistanceFromCatan)")
        
        
        // SAVE gameState to file
        print ("SAVING FILE - \(filename)")
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        //let fileURL = DocumentDirURL.appendingPathComponent("settlersofswift/\(filename)")
        let fileURL = DocumentDirURL.appendingPathComponent(filename)
        
        do {
            try gameState.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        }
        catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: \(error.localizedDescription)")
        }
    }
    
    func loadGame() {
        let gameState = appDelegate.networkManager.loadData
        appDelegate.networkManager.loadData = "nil"
        
        let unitData = gameState.components(separatedBy: ".")
        for unit in unitData {
            let data = unit.components(separatedBy: "|")
            let identifier = data[0]
            switch identifier {
                case "GAMEBOARD":
                    setBoardLayout(encoding: data[1])
                    handler.updateGUI()
                case "PLAYER":
                    extractPlayerInfo(data)
                case "PLAYERCORNERS":
                    extractCorners(data)
                case "PLAYEREDGES":
                    extractEdges(data)
                case "PLAYERKNIGHTS":
                    extractKnights(data)
                case "PLAYERPROGRESSCARDS":
                    extractPlayerCards(data)
                case "GAMEPROGRESSCARDS":
                    extractGameCards(data)
                case "GAMEFISHDECK":
                    extractGameFish(data)
                case "GAMEDATA":
                    extractGameData(data)
                default:
                    print("Unrecognized Data Unit")
            }
        }
    }
    func extractPlayerInfo(_ data: [String]) {
        let name = data[1]
        let index = Int(data[2])!
        if name == appDelegate.networkManager.getName() {
            myPlayerIndex = index
        }
        while players.count-1 < index {
            players.append(Player(name: name, playerNumber: index))
        }
        if players.count-1 >= index {
            self.players[index] = Player(name: name, playerNumber: index)
        }
        let p = players[index]
        p.brick = Int(data[4])!
        p.brickTradeRatio = Int(data[5])!
        p.wheat = Int(data[6])!
        p.wheatTradeRatio = Int(data[7])!
        p.wood = Int(data[8])!
        p.woodTradeRatio = Int(data[9])!
        p.sheep = Int(data[10])!
        p.sheepTradeRatio = Int(data[11])!
        p.stone = Int(data[12])!
        p.stoneTradeRatio = Int(data[13])!
        p.gold = Int(data[14])!
        p.goldTradeRatio = Int(data[15])!
        p.paper = Int(data[16])!
        p.paperTradeRatio = Int(data[17])!
        p.coin = Int(data[18])!
        p.coinTradeRatio = Int(data[19])!
        p.cloth = Int(data[20])!
        p.clothTradeRatio = Int(data[21])!
        p.fish = Int(data[22])!
        p.victoryPoints = Int(data[23])!
        p.hasOldBoot = Bool(data[24])!
        p.politicsImprovementLevel = Int(data[25])!
        p.tradesImprovementLevel = Int(data[26])!
        p.sciencesImprovementLevel = Int(data[27])!
        p.holdsTradesMetropolis = Bool(data[28])!
        p.holdsPoliticsMetropolis = Bool(data[29])!
        p.holdsSciencesMetropolis = Bool(data[30])!
        p.nextAction = PlayerIntentions(rawValue: data[31])!
        p.longestRoad = Int(data[32])!
        p.movingKnightStrength = Int(data[33])!
        p.movingKnightFromCol = Int(data[34])!
        p.movingKnightFromRow = Int(data[35])!
        p.movingKnightUpgraded = Bool(data[36])!
        p.movedShipThisTurn = Bool(data[37])!
        
        if (myPlayerIndex >= 0 && myPlayerIndex < players.count && players[myPlayerIndex].hasOldBoot) {
            DispatchQueue.main.async {
                self.view?.addSubview(self.oldBootButton)
            }
        }
    }
    func extractCorners(_ data: [String]) {
        let player = Int(data[1])!
        for i in 2..<data.count {
            let specs = data[i].components(separatedBy: ",")
            let row = Int(specs[0])!
            let column = Int(specs[1])!
            let type = cornerType(rawValue: specs[2])!
            let hasCityWall = Bool(specs[3])!
            let isHarbor = Bool(specs[4])!
            let harborType = harbourType(rawValue: specs[5])!
            
            let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
            corner?.isHarbour = isHarbor
            corner?.harbourType = harborType
            corner!.cornerObject = cornerObject(cornerType : type, owner: player)
            corner!.cornerObject?.hasCityWall = hasCityWall
            players[player].ownedCorners.append(corner!)
            
            var tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[player].color.rawValue)\(corner!.cornerObject!.type.rawValue)"})
            if type == .City || type == .Metropolis {
                tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[player].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.hasCityWall)"})
            }
            handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        }
    }
    func extractEdges(_ data: [String]) {
        let player = Int(data[1])!
        for i in 2..<data.count {
            let specs = data[i].components(separatedBy: ",")
            let row = Int(specs[0])!
            let column = Int(specs[1])!
            let type = edgeType(rawValue: specs[2])!
            let justBuilt = Bool(specs[3])!
            
            let edge = handler.landHexEdgeArray.first(where: {$0.column == column && $0.row == row})
        
            edge!.edgeObject = edgeObject(edgeType : type, owner: player)
            edge!.edgeObject?.justBuilt = justBuilt
            players[player].ownedEdges.append(edge!)
            
            let tileGroup = handler.edgesTiles.tileGroups.first(where: {$0.name == "\(edge!.direction.rawValue)\(players[player].color.rawValue)\(edge!.edgeObject!.type.rawValue)"})
            handler.Edges.setTileGroup(tileGroup, forColumn: column, row: row)
        }
    }
    func extractKnights(_ data: [String]) {
        let player = Int(data[1])!
        for i in 2..<data.count {
            let specs = data[i].components(separatedBy: ",")
            let row = Int(specs[0])!
            let column = Int(specs[1])!
            let strength = Int(specs[2])!
            let isActive = Bool(specs[3])!
            let hasBeenUpgradedThisTurn = Bool(specs[4])!
            let didAction = Bool(specs[5])!
            
            let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
            corner!.cornerObject = cornerObject(cornerType : .Knight, owner: player)
            corner!.cornerObject?.strength = strength
            corner!.cornerObject?.isActive = isActive
            corner!.cornerObject?.hasBeenUpgradedThisTurn = hasBeenUpgradedThisTurn
            corner!.cornerObject?.didActionThisTurn = didAction
            players[player].ownedKnights.append(corner!)
            let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[player].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
            handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        }
    }
    func extractPlayerCards(_ data: [String]) {
        let player = Int(data[1])!
        for i in 2..<data.count {
            let card = ProgressCardsType(rawValue: data[i])!
            players[player].progressCards.append(card)
            print ("Player \(players[player].name) has \(card.rawValue)")
        }
    }
    func extractGameCards(_ data: [String]) {
        for i in 1..<data.count {
            let card = ProgressCardsType(rawValue: data[i])!
            gameDeck.append(card)
        }
    }
    func extractGameFish(_ data: [String]) {
        for i in 1..<data.count {
            let value = Int(data[i])!
            let card = FishToken(v: value)
            fishDeck.append(card)
        }
    }
    func extractGameData(_ data: [String]) {
        currGamePhase = GamePhase(rawValue: data[1])!
        
        dice.redValue = Int(data[2])!
        dice.yellowValue = Int(data[3])!
        dice.eventValue = Int(data[4])!
        updateDice(red: dice.redValue, yellow: dice.yellowValue, event: dice.eventValue)
        
        currentPlayer = Int(data[5])!
        rolled = Bool(data[6])!
        politicsMetropolisPlaced = Bool(data[7])!
        sciencesMetropolisPlaced = Bool(data[8])!
        tradesMetropolisPlaced = Bool(data[9])!
        maximaPoliticsImprovementReached = Bool(data[10])!
        maximaSciencesImprovementReached = Bool(data[11])!
        maximaTradesImprovementReached = Bool(data[12])!
        pirateRemoved = Bool(data[13])!
        robberRemoved = Bool(data[14])!
        barbariansDistanceFromCatan = Int(data[15])!
        
        if (currentPlayer == myPlayerIndex) {
            DispatchQueue.main.async {
                self.gameButton.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
            }
            if players[myPlayerIndex].nextAction != .WillDoNothing {
                DispatchQueue.main.async {
                    self.cancelButton.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }

            }
        }
    }

    func weddingCardDiscard(amount: Int = 2, receiverIndex: Int) {
        if amount == 2 {
            let alert = UIAlertController(title: "Wedding Card", message: "Someone has played The Wedding Progress Card on you!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "CONTINUE", style: .default, handler: { action -> Void in
                self.weddingCardDiscard(amount: 1, receiverIndex: receiverIndex)
            })
            alert.addAction(alertAction)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            var invalidCounter = 0
            let actionSheet = UIAlertController(title: nil, message: "Please select " + (amount == 0 ? "another " : "a ") + "resource or " + (amount == 0 ? "another " : "a ") + "commodity to discard...", preferredStyle: .actionSheet)
            if players[myPlayerIndex].brick > 0 {
                let brickAction = UIAlertAction(title: "BRICK", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].brick -= 1
                    let _ = self.appDelegate.networkManager.sendData(data: "sendCommodityOrResource.BRICK.\(receiverIndex)")
                    if amount == 1 { self.weddingCardDiscard(amount: 0, receiverIndex: receiverIndex) } else { return }
                })
                actionSheet.addAction(brickAction)
            } else { invalidCounter += 1 }
            if players[myPlayerIndex].gold > 0 {
                let goldAction = UIAlertAction(title: "GOLD", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].gold -= 1
                    let _ = self.appDelegate.networkManager.sendData(data: "sendCommodityOrResource.GOLD.\(receiverIndex)")
                    if amount == 1 { self.weddingCardDiscard(amount: 0, receiverIndex: receiverIndex) } else { return }
                })
                actionSheet.addAction(goldAction)
            } else { invalidCounter += 1 }
            if players[myPlayerIndex].sheep > 0 {
                let sheepAction = UIAlertAction(title: "SHEEP", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].sheep -= 1
                    let _ = self.appDelegate.networkManager.sendData(data: "sendCommodityOrResource.SHEEP.\(receiverIndex)")
                    if amount == 1 { self.weddingCardDiscard(amount: 0, receiverIndex: receiverIndex) } else { return }
                })
                actionSheet.addAction(sheepAction)
            } else { invalidCounter += 1 }
            if players[myPlayerIndex].stone > 0 {
                let stoneAction = UIAlertAction(title: "STONE", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].stone -= 1
                    let _ = self.appDelegate.networkManager.sendData(data: "sendCommodityOrResource.STONE.\(receiverIndex)")
                    if amount == 1 { self.weddingCardDiscard(amount: 0, receiverIndex: receiverIndex) } else { return }
                })
                actionSheet.addAction(stoneAction)
            } else { invalidCounter += 1 }
            if players[myPlayerIndex].wheat > 0 {
                let wheatAction = UIAlertAction(title: "WHEAT", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].wheat -= 1
                    let _ = self.appDelegate.networkManager.sendData(data: "sendCommodityOrResource.WHEAT.\(receiverIndex)")
                    if amount == 1 { self.weddingCardDiscard(amount: 0, receiverIndex: receiverIndex) } else { return }
                })
                actionSheet.addAction(wheatAction)
            } else { invalidCounter += 1 }
            if players[myPlayerIndex].wood > 0 {
                let woodAction = UIAlertAction(title: "WOOD", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].wood -= 1
                    let _ = self.appDelegate.networkManager.sendData(data: "sendCommodityOrResource.WOOD.\(receiverIndex)")
                    if amount == 1 { self.weddingCardDiscard(amount: 0, receiverIndex: receiverIndex) } else { return }
                })
                actionSheet.addAction(woodAction)
            } else { invalidCounter += 1 }
            if players[myPlayerIndex].coin > 0 {
                let coinAction = UIAlertAction(title: "COIN", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].coin -= 1
                    let _ = self.appDelegate.networkManager.sendData(data: "sendCommodityOrResource.COIN.\(receiverIndex)")
                    if amount == 1 { self.weddingCardDiscard(amount: 0, receiverIndex: receiverIndex) } else { return }
                })
                actionSheet.addAction(coinAction)
            } else { invalidCounter += 1 }
            if players[myPlayerIndex].paper > 0 {
                let paperAction = UIAlertAction(title: "PAPER", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].paper -= 1
                    let _ = self.appDelegate.networkManager.sendData(data: "sendCommodityOrResource.PAPER.\(receiverIndex)")
                    if amount == 1 { self.weddingCardDiscard(amount: 0, receiverIndex: receiverIndex) } else { return }
                })
                actionSheet.addAction(paperAction)
            } else { invalidCounter += 1 }
            if players[myPlayerIndex].cloth > 0 {
                let clothAction = UIAlertAction(title: "CLOTH", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].cloth -= 1
                    let _ = self.appDelegate.networkManager.sendData(data: "sendCommodityOrResource.CLOTH.\(receiverIndex)")
                    if amount == 1 { self.weddingCardDiscard(amount: 0, receiverIndex: receiverIndex) } else { return }
                })
                actionSheet.addAction(clothAction)
            } else { invalidCounter += 1 }
            if invalidCounter == 9 { return } else { self.view?.window?.rootViewController?.present(actionSheet, animated: true, completion: nil) }
        }
    }
    
    func robberCardDiscard(originalAmount: Int, amount: Int) {
        if originalAmount == amount {
            let alert = UIAlertController(title: "Robber Roll", message: "You have more than 7 resources or commodities cards on you! Let's discard half of them!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "CONTINUE", style: .default, handler: { action -> Void in
                self.robberCardDiscard(originalAmount: originalAmount, amount: amount - 1)
            })
            alert.addAction(alertAction)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            let actionSheet = UIAlertController(title: nil, message: "Please select " + (amount == (originalAmount - 1) ? "a " : "another ") + "resource or " + (amount == (originalAmount - 1) ? "a " : "another ") + "commodity to discard...", preferredStyle: .actionSheet)
            if players[myPlayerIndex].brick > 0 {
                let brickAction = UIAlertAction(title: "BRICK", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].brick -= 1
                    if amount != 0 { self.robberCardDiscard(originalAmount: originalAmount, amount: amount - 1) } else { return }
                })
                actionSheet.addAction(brickAction)
            }
            if players[myPlayerIndex].gold > 0 {
                let goldAction = UIAlertAction(title: "GOLD", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].gold -= 1
                    if amount != 0 { self.robberCardDiscard(originalAmount: originalAmount, amount: amount - 1) } else { return }
                })
                actionSheet.addAction(goldAction)
            }
            if players[myPlayerIndex].sheep > 0 {
                let sheepAction = UIAlertAction(title: "SHEEP", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].sheep -= 1
                    if amount != 0 { self.robberCardDiscard(originalAmount: originalAmount, amount: amount - 1) } else { return }
                })
                actionSheet.addAction(sheepAction)
            }
            if players[myPlayerIndex].stone > 0 {
                let stoneAction = UIAlertAction(title: "STONE", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].stone -= 1
                    if amount != 0 { self.robberCardDiscard(originalAmount: originalAmount, amount: amount - 1) } else { return }
                })
                actionSheet.addAction(stoneAction)
            }
            if players[myPlayerIndex].wheat > 0 {
                let wheatAction = UIAlertAction(title: "WHEAT", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].wheat -= 1
                    if amount != 0 { self.robberCardDiscard(originalAmount: originalAmount, amount: amount - 1) } else { return }
                })
                actionSheet.addAction(wheatAction)
            }
            if players[myPlayerIndex].wood > 0 {
                let woodAction = UIAlertAction(title: "WOOD", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].wood -= 1
                    if amount != 0 { self.robberCardDiscard(originalAmount: originalAmount, amount: amount - 1) } else { return }
                })
                actionSheet.addAction(woodAction)
            }
            if players[myPlayerIndex].coin > 0 {
                let coinAction = UIAlertAction(title: "COIN", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].coin -= 1
                    if amount != 0 { self.robberCardDiscard(originalAmount: originalAmount, amount: amount - 1) } else { return }
                })
                actionSheet.addAction(coinAction)
            }
            if players[myPlayerIndex].paper > 0 {
                let paperAction = UIAlertAction(title: "PAPER", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].paper -= 1
                    if amount != 0 { self.robberCardDiscard(originalAmount: originalAmount, amount: amount - 1) } else { return }
                })
                actionSheet.addAction(paperAction)
            }
            if players[myPlayerIndex].cloth > 0 {
                let clothAction = UIAlertAction(title: "CLOTH", style: .default, handler: { action -> Void in
                    self.players[self.myPlayerIndex].cloth -= 1
                    if amount != 0 { self.robberCardDiscard(originalAmount: originalAmount, amount: amount - 1) } else { return }
                })
                actionSheet.addAction(clothAction)
            }
            self.view?.window?.rootViewController?.present(actionSheet, animated: true, completion: nil)
    }   }
    
    func checkIfCardsNeedDiscard() {
        let discardCount = players[myPlayerIndex].mustRemoveHalfOfHand()
        if discardCount != 0 { robberCardDiscard(originalAmount: discardCount, amount: discardCount) }
    }
    
    func stealFromPlayer(_ index: Int) {
        players[myPlayerIndex].fetchedTargetData = false
        let message = "getTradeResources.\(index)"
        let _ = appDelegate.networkManager.sendData(data: message)
        while players[myPlayerIndex].fetchedTargetData == false { }
        var invalidCounter = 0
        let newSheet = UIAlertController(title: "", message: "Select a resource or a commodity to steal...", preferredStyle: .actionSheet)
        if players[index].brick > 0 {
            let commodity = UIAlertAction(title: "Brick", style: .default) { action -> Void in
                let _ = self.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\(index).BRICK")
                self.players[index].brick -= 1
                self.players[self.myPlayerIndex].brick += 1
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if self.players[index].gold > 0 {
            let commodity = UIAlertAction(title: "Gold", style: .default) { action -> Void in
                let _ = self.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\(index).GOLD")
                self.players[index].gold -= 1
                self.players[self.myPlayerIndex].gold += 1
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if players[index].sheep > 0 {
            let commodity = UIAlertAction(title: "Sheep", style: .default) { action -> Void in
                let _ = self.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\(index).SHEEP")
                self.players[index].sheep -= 1
                self.players[self.myPlayerIndex].sheep += 1
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if self.players[index].stone > 0 {
            let commodity = UIAlertAction(title: "Stone", style: .default) { action -> Void in
                let _ = self.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\(index).STONE")
                self.players[index].stone -= 1
                self.players[self.myPlayerIndex].stone += 1
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if players[index].wheat > 0 {
            let commodity = UIAlertAction(title: "Wheat", style: .default) { action -> Void in
                let _ = self.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\(index).WHEAT")
                self.players[index].wheat -= 1
                self.players[self.myPlayerIndex].wheat += 1
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if players[index].wood > 0 {
            let commodity = UIAlertAction(title: "Wood", style: .default) { action -> Void in
                let _ = self.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\(index).WOOD")
                self.players[index].wood -= 1
                self.players[self.myPlayerIndex].wood += 1
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if players[index].coin > 0 {
            let commodity = UIAlertAction(title: "Coin", style: .default) { action -> Void in
                let _ = self.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\(index).COIN")
                self.players[index].coin -= 1
                self.players[self.myPlayerIndex].coin += 1
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if players[index].paper > 0 {
            let commodity = UIAlertAction(title: "Paper", style: .default) { action -> Void in
                let _ = self.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\(index).PAPER")
                self.players[index].paper -= 1
                self.players[self.myPlayerIndex].paper += 1
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if players[index].cloth > 0 {
            let commodity = UIAlertAction(title: "Cloth", style: .default) { action -> Void in
                let _ = self.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\(index).CLOTH")
                self.players[index].cloth -= 1
                self.players[self.myPlayerIndex].cloth += 1
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if invalidCounter == 9 {
            let newAlert = UIAlertController(title: nil, message: "Sorry, but looks like the player you chose is broke!", preferredStyle: .alert)
            newAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.view?.window?.rootViewController?.present(newAlert, animated: true, completion: nil)
        } else { self.view?.window?.rootViewController?.present(newSheet, animated: true, completion: nil) }
    }
    
    
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        targetLocation = touch.location(in: self)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        targetLocation = touch.location(in: self)
//    }
//    
//    override func update(_ currentTime: TimeInterval) {
//    }  

}
