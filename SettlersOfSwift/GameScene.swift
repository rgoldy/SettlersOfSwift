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

class GameScene: SKScene {
    
    //init scene nodes
    var cam:SKCameraNode!
    var currGamePhase = GamePhase.Setup
    let dice = Dice()
    var players: [Player] = []
    var currentPlayer = 0
    var myPlayerIndex = -1
    let gameButton = UITextField()
    let gameText = UITextField()
    let playerInfo = UITextField()
    let redDiceUI = UIImageView()
    let yellowDiceUI = UIImageView()
    var rolled : Bool = false
    
    //init tile handler
    var handler : tileHandler!
    
    // Access to network manager
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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

        //init UI
//        gameText.font = UIFont(name: "Arial", size: 13)
//        gameText.frame = CGRect(x: self.view!.bounds.width/2 - (self.view!.bounds.width/6), y: self.view!.bounds.height/8, width: self.view!.bounds.width/3, height: self.view!.bounds.height/12)
//        gameText.text = "Test"
//        gameText.textAlignment = NSTextAlignment.center
//        gameText.isHidden = true
//        gameText.backgroundColor = UIColor.gray
//        gameText.borderStyle = UITextBorderStyle.roundedRect
//        gameText.isUserInteractionEnabled = false
//        self.view?.addSubview(gameText)
        
        playerInfo.font = UIFont(name: "Arial", size: 13)
        playerInfo.frame = CGRect(x: 0, y: 0, width: self.view!.bounds.width, height: self.view!.bounds.height/16)
        playerInfo.center = CGPoint(x:self.view!.center.x, y:self.view!.bounds.height/32)
        playerInfo.text = players.first(where: {$0.name == appDelegate.networkManager.getName()})?.getPlayerText()
        playerInfo.backgroundColor = UIColor.gray
        playerInfo.textAlignment = NSTextAlignment.center
        playerInfo.isUserInteractionEnabled = false
        self.view?.addSubview(playerInfo)
        
        gameButton.frame = CGRect(x: self.view!.bounds.width/12 * 10.5, y: self.view!.bounds.height/14.5, width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        gameButton.text = "End Turn"
        gameButton.font = UIFont(name: "Arial", size: 13)
        gameButton.backgroundColor = UIColor.gray
        gameButton.borderStyle = UITextBorderStyle.roundedRect
        gameButton.isUserInteractionEnabled = false
        gameButton.textAlignment = NSTextAlignment.center
        self.view?.addSubview(gameButton)
        
        redDiceUI.frame = CGRect(x: 0, y: self.view!.bounds.height - self.view!.bounds.width/12, width: self.view!.bounds.width/12, height: self.view!.bounds.width/12)
        redDiceUI.image = UIImage(named: "red1")
        self.view?.addSubview(redDiceUI)
        
        yellowDiceUI.frame = CGRect(x: self.view!.bounds.width/11, y: self.view!.bounds.height - self.view!.bounds.width/12, width: self.view!.bounds.width/12, height: self.view!.bounds.width/12)
        yellowDiceUI.image = UIImage(named: "yellow1")
        self.view?.addSubview(yellowDiceUI)
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
                default: type = .wood
            }
            
            // Set hex types and values
            for hex in handler.landHexArray {
                if (hex.row == row && hex.column == column) {
                    hex.type = type
                    
                    if(handler.landHexDictionary[value] == nil) { handler.landHexDictionary[value] = [] }
                    handler.landHexDictionary[value]!.append((column!, row!))
                    break
                }
            }
        }
    }
    
    func initPlayers() {
        let p1 = Player(name: appDelegate.networkManager.getName(), playerNumber: 0)
        players.append(p1)
        var playerInfo = "playerData.\(appDelegate.networkManager.getName()),\(0);"
        myPlayerIndex = 0
        
        for i in 0...appDelegate.networkManager.session.connectedPeers.count-1 {
            let p = Player(name: appDelegate.networkManager.session.connectedPeers[i].displayName, playerNumber: i+1)
            players.append(p)
            playerInfo.append("\(appDelegate.networkManager.session.connectedPeers[i].displayName),\(i+1);")
        }
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: playerInfo)
        if (!sent) {
            print ("failed to sync player info")
        }
        else {
            print ("successful sync player info")
        }
        
        self.playerInfo.text = players.first(where: {$0.name == appDelegate.networkManager.getName()})?.getPlayerText()
        currGamePhase = GamePhase.placeFirstSettlement
        gameText.text = "Place First Settlement"
        gameText.isHidden = false
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
        
        self.playerInfo.text = players.first(where: {$0.name == appDelegate.networkManager.getName()})?.getPlayerText()
        currGamePhase = GamePhase.placeFirstSettlement
        gameText.text = "Place First Settlement"
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if (touches.count > 1) { return }
        let targetLocation = touch.location(in: self)
        let targetLocationView = touch.location(in: self.view!)
        print (currGamePhase)
        
        if(currentPlayer == myPlayerIndex) { //only accept taps if it's your turn
            switch currGamePhase {
            case .placeFirstSettlement :
                if (placeCornerObject(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), type: cornerType.Settlement)) {
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
                if (placeCornerObject(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row:  handler.Vertices.tileRowIndex(fromPosition: targetLocation), type: cornerType.Settlement)) {
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
                if (redDiceUI.frame.contains(targetLocationView) || yellowDiceUI.frame.contains(targetLocationView)) {
                    if(!rolled) {
                        rollDice()
                        rolled = true
                    }
                }
                if (self.gameButton.frame.contains(targetLocationView)) {
                    if (rolled) {
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
            case .p2Turn :
                if (redDiceUI.frame.contains(targetLocationView) || yellowDiceUI.frame.contains(targetLocationView)) {
                    if(!rolled) {
                        rollDice()
                        rolled = true
                    }
                }
                if (self.gameButton.frame.contains(targetLocationView)) {
                    if (rolled) {
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
            case .p3Turn :
                if (redDiceUI.frame.contains(targetLocationView) || yellowDiceUI.frame.contains(targetLocationView)) {
                    if(!rolled) {
                        rollDice()
                        rolled = true
                    }
                }
                if (self.gameButton.frame.contains(targetLocationView)) {
                    if (rolled) {
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
            default : break
            }
        }
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
    func placeCornerObject(column : Int, row : Int, type : cornerType) -> Bool {
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false }
        if (corner?.cornerObject != nil) { return false }
        if (canPlaceCorner(corner: corner!) == false) { return false }

        corner!.cornerObject = cornerObject(cornerType : type)
        players[currentPlayer].ownedCorners.append(corner!)
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        distributeResourcesOnSetup(vertex: corner!)
        
        let cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),\(type.rawValue)"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        else {
            print ("successful sync cornerObject")
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
        return true
    }
    
    //function that will read a recieved message and set the corner object
    func setCornerObjectFromMessage(info:String) {
        let cornerInfo = info.components(separatedBy: ",")
        let currPlayerNumber = Int(cornerInfo[0])!
        let column = Int(cornerInfo[1])!
        let row = Int(cornerInfo[2])!
        let type = cornerType(rawValue: cornerInfo[3])
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        corner?.cornerObject = cornerObject(cornerType : type!)
        players[currPlayerNumber].ownedCorners.append(corner!)
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
    }
    
    //function that will place an edge object and set its owner then send info to other players
    func placeEdgeObject(column : Int, row : Int, type : edgeType) -> Bool {
        let edge = handler.landHexEdgeArray.first(where: {$0.column == column && $0.row == row})
        if (edge == nil) { return false }
        if (edge?.edgeObject != nil) { return false }
        if (canPlaceEdge(edge: edge!) == false) { return false }
        
        edge!.edgeObject = edgeObject(edgeType : type)
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
        let type = edgeType(rawValue: edgeInfo[3])
        let edge = handler.landHexEdgeArray.first(where: {$0.column == column && $0.row == row})
        edge?.edgeObject = edgeObject(edgeType : type!)
        players[currPlayerNumber].ownedEdges.append(edge!)
        let tileGroup = handler.edgesTiles.tileGroups.first(where: {$0.name == "\(edge!.direction.rawValue)\(players[currPlayerNumber].color.rawValue)\(edge!.edgeObject!.type.rawValue)"})
        handler.Edges.setTileGroup(tileGroup, forColumn: column, row: row)
    }
    
    // function that rolls the dice
    func rollDice() {
        let values = dice.rollDice()
        updateDice(red: values[0], yellow: values[1])
        let diceData = "diceRoll.\(values[0]),\(values[1])"
        
        // distribute resources on own device
        print(values[0] + values[1])
        if(values[0] + values[1] != 7) {
            distributeResources(dice: values[0] + values[1])
        }
        
        // distribute resources on other players' devices
        let sent = appDelegate.networkManager.sendData(data: diceData)
        if (!sent) {
            print ("failed to distribute resources to all players")
        }
        else {
            print ("successfully distributed resources to all players")
        }
    }
    
    func updateDice(red : Int, yellow: Int) {
        DispatchQueue.main.async
            {
            self.redDiceUI.image = UIImage(named: "red\(red)")!
            self.yellowDiceUI.image = UIImage(named: "yellow\(yellow)")!
        }
    }
    
    // function that will distribute resources to all players
    func distributeResources(dice: Int) {
        print ("Dice = \(dice)")
        let producingCoords = handler.landHexDictionary[dice]
        for (col, row) in producingCoords! {
            for player in players { // for each player...
                for vertex in player.ownedCorners { // distribute resources if vertex touches hex
                    if (vertex.tile1.column == col && vertex.tile1.row == row) {
                        // Distribute resources of type tile1.type
                        switch vertex.tile1.type! {
                            case .wood: player.wood += 1; print("\(player.name) mined wood")
                            case .wheat: player.wheat += 1; print("\(player.name) mined wheat")
                            case .stone: player.stone += 1; print("\(player.name) mined stone")
                            case .sheep: player.sheep += 1; print("\(player.name) mined sheep")
                            case .brick: player.brick += 1; print("\(player.name) mined brick")
                            case .gold: player.gold += 1; print("\(player.name) mined gold")
                        }
                    }
                    if (vertex.tile2 != nil && vertex.tile2!.column == col && vertex.tile2!.row == row) {
                        // Distribute resources of type tile1.type
                        switch vertex.tile2!.type! {
                            case .wood: player.wood += 1; print("\(player.name) mined wood")
                            case .wheat: player.wheat += 1; print("\(player.name) mined wheat")
                            case .stone: player.stone += 1; print("\(player.name) mined stone")
                            case .sheep: player.sheep += 1; print("\(player.name) mined sheep")
                            case .brick: player.brick += 1; print("\(player.name) mined brick")
                            case .gold: player.gold += 1; print("\(player.name) mined gold")
                        }
                    }
                    if (vertex.tile3 != nil && vertex.tile3!.column == col && vertex.tile3!.row == row) {
                        // Distribute resources of type tile1.type
                        switch vertex.tile3!.type! {
                            case .wood: player.wood += 1; print("\(player.name) mined wood")
                            case .wheat: player.wheat += 1; print("\(player.name) mined wheat")
                            case .stone: player.stone += 1; print("\(player.name) mined stone")
                            case .sheep: player.sheep += 1; print("\(player.name) mined sheep")
                            case .brick: player.brick += 1; print("\(player.name) mined brick")
                            case .gold: player.gold += 1; print("\(player.name) mined gold")
                        }
                    }
                }
            }
        }
        print(players[myPlayerIndex].getPlayerText())
        DispatchQueue.main.async {
            self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
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
            case .gold: players[myPlayerIndex].gold += 1
        }
        if (vertex.tile2 != nil) {
            // Distribute resources of type tile1.type
            switch vertex.tile2!.type! {
            case .wood: players[myPlayerIndex].wood += 1
            case .wheat: players[myPlayerIndex].wheat += 1
            case .stone: players[myPlayerIndex].stone += 1
            case .sheep: players[myPlayerIndex].sheep += 1
            case .brick: players[myPlayerIndex].brick += 1
            case .gold: players[myPlayerIndex].gold += 1
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
            case .gold: players[myPlayerIndex].gold += 1
            }
        }
        
        sendPlayerData(player: myPlayerIndex)
        DispatchQueue.main.async {
            self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
        }
    }
    
    // Encode's player's resources and sends to other players
    func sendPlayerData(player: Int) {
        var pData = "updatePlayerData.\(player),"
        pData.append("\(players[player].wood),")
        pData.append("\(players[player].wheat),")
        pData.append("\(players[player].stone),")
        pData.append("\(players[player].sheep),")
        pData.append("\(players[player].brick),")
        pData.append("\(players[player].gold)")
        
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
        
        players[player].wood = wood
        players[player].wheat = wheat
        players[player].stone = stone
        players[player].sheep = sheep
        players[player].brick = brick
        players[player].gold = gold
    }
    
//
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
