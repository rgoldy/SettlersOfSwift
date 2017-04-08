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
    var gameDeck = ProgressCardsType.generateNewGameDeck()
    
    let gameButton = UITextField()
    let cancelButton = UITextField()
    let buildUpgradeButton = UITextField()
    let buildRoadButton = UITextField()
    let buildShipButton = UITextField()
    let gameText = UITextField()
    let playerInfo = UITextField()
    let redDiceUI = UIImageView()
    let yellowDiceUI = UIImageView()
    let eventDiceUI = UIImageView()
    
    var rolled : Bool = false
    var buildSettlement : Bool = false
    var buildRoad : Bool = false
    var buildShip: Bool = false
    
    let tradeBackground = UITextField()
    let lWood = UITextField()
    let lSheep = UITextField()
    let lWheat = UITextField()
    let lBrick = UITextField()
    let lStone = UITextField()
    let lGold = UITextField()
    
    let rWood = UITextField()
    let rSheep = UITextField()
    let rWheat = UITextField()
    let rBrick = UITextField()
    let rStone = UITextField()
    
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
    
    //  END OF SEND TO ALL PLAYERS
    
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
        
//        buildUpgradeButton.frame = CGRect(x: self.view!.bounds.width/12 * 10.5 - self.view!.bounds.width/10, y: self.view!.bounds.height/14.5 + self.view!.bounds.height/13.5 , width: self.view!.bounds.width/5, height: self.view!.bounds.height/14)
//        buildUpgradeButton.text = "Build/Upgrade Settlement"
//        buildUpgradeButton.font = UIFont(name: "Arial", size: 10)
//        buildUpgradeButton.backgroundColor = UIColor.gray
//        buildUpgradeButton.borderStyle = UITextBorderStyle.roundedRect
//        buildUpgradeButton.isUserInteractionEnabled = false
//        buildUpgradeButton.textAlignment = NSTextAlignment.center
//        self.view?.addSubview(buildUpgradeButton)
//        
//        buildRoadButton.frame = CGRect(x: self.view!.bounds.width/12 * 10.5, y: self.view!.bounds.height/14.5 + (self.view!.bounds.height/13.5 * 2), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
//        buildRoadButton.text = "Build Road"
//        buildRoadButton.font = UIFont(name: "Arial", size: 10)
//        buildRoadButton.backgroundColor = UIColor.gray
//        buildRoadButton.borderStyle = UITextBorderStyle.roundedRect
//        buildRoadButton.isUserInteractionEnabled = false
//        buildRoadButton.textAlignment = NSTextAlignment.center
//        self.view?.addSubview(buildRoadButton)
//        
//        buildShipButton.frame = CGRect(x: self.view!.bounds.width/12 * 10.5, y: self.view!.bounds.height/14.5 + (self.view!.bounds.height/13.5 * 3), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
//        buildShipButton.text = "Build Ship"
//        buildShipButton.font = UIFont(name: "Arial", size: 10)
//        buildShipButton.backgroundColor = UIColor.gray
//        buildShipButton.borderStyle = UITextBorderStyle.roundedRect
//        buildShipButton.isUserInteractionEnabled = false
//        buildShipButton.textAlignment = NSTextAlignment.center
//        self.view?.addSubview(buildShipButton)
        
        cancelButton.frame = CGRect(x: self.view!.bounds.width * 0.025, y: self.view!.bounds.height/14.5, width: self.view!.bounds.width/5, height: self.view!.bounds.height/14)
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
            case .fish: type = 6
            default: type = 7
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
        
        DispatchQueue.main.async {
            self.playerInfo.text = self.players.first(where: {$0.name == self.appDelegate.networkManager.getName()})?.getPlayerText()
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
        
        DispatchQueue.main.async {
            self.playerInfo.text = self.players.first(where: {$0.name == self.appDelegate.networkManager.getName()})?.getPlayerText()
        }
        currGamePhase = GamePhase.placeFirstSettlement
        gameText.text = "Place First Settlement"
    }
    
    //funciton that inits the trade menu
    func presentTradeMenu() {
        tradeOpen = true
        
        tradeBackground.frame = CGRect(x: self.view!.bounds.width * 0.3, y: self.view!.bounds.height/4, width: self.view!.bounds.width/2.5, height: self.view!.bounds.height/2)
        tradeBackground.backgroundColor = UIColor.lightGray
        tradeBackground.borderStyle = UITextBorderStyle.roundedRect
        tradeBackground.isUserInteractionEnabled = false
        tradeBackground.textAlignment = NSTextAlignment.center
        tradeBackground.text = "Maritime Trade"
        tradeBackground.font = UIFont(name: "Arial", size: 13)
        self.view?.addSubview(tradeBackground)
        
        lWood.frame = CGRect(x: self.view!.bounds.width/3, y: self.view!.bounds.height/2 - (self.view!.bounds.height/13.5 * 3), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        lWood.text = "Wood"
        lWood.font = UIFont(name: "Arial", size: 13)
        lWood.backgroundColor = UIColor.gray
        lWood.borderStyle = UITextBorderStyle.roundedRect
        lWood.isUserInteractionEnabled = false
        lWood.textAlignment = NSTextAlignment.center
        self.view?.addSubview(lWood)
        
        lSheep.frame = CGRect(x: self.view!.bounds.width/3, y: self.view!.bounds.height/2 - (self.view!.bounds.height/13.5 * 2), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        lSheep.text = "Sheep"
        lSheep.font = UIFont(name: "Arial", size: 13)
        lSheep.backgroundColor = UIColor.gray
        lSheep.borderStyle = UITextBorderStyle.roundedRect
        lSheep.isUserInteractionEnabled = false
        lSheep.textAlignment = NSTextAlignment.center
        self.view?.addSubview(lSheep)
        
        lWheat.frame = CGRect(x: self.view!.bounds.width/3, y: self.view!.bounds.height/2 - (self.view!.bounds.height/13.5), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        lWheat.text = "Wheat"
        lWheat.font = UIFont(name: "Arial", size: 13)
        lWheat.backgroundColor = UIColor.gray
        lWheat.borderStyle = UITextBorderStyle.roundedRect
        lWheat.isUserInteractionEnabled = false
        lWheat.textAlignment = NSTextAlignment.center
        self.view?.addSubview(lWheat)
        
        lBrick.frame = CGRect(x: self.view!.bounds.width/3, y: self.view!.bounds.height/2, width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        lBrick.text = "Brick"
        lBrick.font = UIFont(name: "Arial", size: 13)
        lBrick.backgroundColor = UIColor.gray
        lBrick.borderStyle = UITextBorderStyle.roundedRect
        lBrick.isUserInteractionEnabled = false
        lBrick.textAlignment = NSTextAlignment.center
        self.view?.addSubview(lBrick)
        
        lStone.frame = CGRect(x: self.view!.bounds.width/3, y: self.view!.bounds.height/2 + (self.view!.bounds.height/13.5), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        lStone.text = "Stone"
        lStone.font = UIFont(name: "Arial", size: 13)
        lStone.backgroundColor = UIColor.gray
        lStone.borderStyle = UITextBorderStyle.roundedRect
        lStone.isUserInteractionEnabled = false
        lStone.textAlignment = NSTextAlignment.center
        self.view?.addSubview(lStone)
        
        lGold.frame = CGRect(x: self.view!.bounds.width/3, y: self.view!.bounds.height/2 + (self.view!.bounds.height/13.5 * 2), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        lGold.text = "Gold"
        lGold.font = UIFont(name: "Arial", size: 13)
        lGold.backgroundColor = UIColor.gray
        lGold.borderStyle = UITextBorderStyle.roundedRect
        lGold.isUserInteractionEnabled = false
        lGold.textAlignment = NSTextAlignment.center
        self.view?.addSubview(lGold)
        
        rWood.frame = CGRect(x: self.view!.bounds.width/3 * 2 - self.view!.bounds.width/10, y: self.view!.bounds.height/2 - (self.view!.bounds.height/13.5 * 3), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        rWood.text = "Wood"
        rWood.font = UIFont(name: "Arial", size: 13)
        rWood.backgroundColor = UIColor.gray
        rWood.borderStyle = UITextBorderStyle.roundedRect
        rWood.isUserInteractionEnabled = false
        rWood.textAlignment = NSTextAlignment.center
        self.view?.addSubview(rWood)
        
        rSheep.frame = CGRect(x: self.view!.bounds.width/3 * 2 - self.view!.bounds.width/10, y: self.view!.bounds.height/2 - (self.view!.bounds.height/13.5 * 2), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        rSheep.text = "Sheep"
        rSheep.font = UIFont(name: "Arial", size: 13)
        rSheep.backgroundColor = UIColor.gray
        rSheep.borderStyle = UITextBorderStyle.roundedRect
        rSheep.isUserInteractionEnabled = false
        rSheep.textAlignment = NSTextAlignment.center
        self.view?.addSubview(rSheep)
        
        rWheat.frame = CGRect(x: self.view!.bounds.width/3 * 2 - self.view!.bounds.width/10, y: self.view!.bounds.height/2 - (self.view!.bounds.height/13.5), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        rWheat.text = "Wheat"
        rWheat.font = UIFont(name: "Arial", size: 13)
        rWheat.backgroundColor = UIColor.gray
        rWheat.borderStyle = UITextBorderStyle.roundedRect
        rWheat.isUserInteractionEnabled = false
        rWheat.textAlignment = NSTextAlignment.center
        self.view?.addSubview(rWheat)
        
        rBrick.frame = CGRect(x: self.view!.bounds.width/3 * 2 - self.view!.bounds.width/10, y: self.view!.bounds.height/2, width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        rBrick.text = "Brick"
        rBrick.font = UIFont(name: "Arial", size: 13)
        rBrick.backgroundColor = UIColor.gray
        rBrick.borderStyle = UITextBorderStyle.roundedRect
        rBrick.isUserInteractionEnabled = false
        rBrick.textAlignment = NSTextAlignment.center
        self.view?.addSubview(rBrick)
        
        rStone.frame = CGRect(x: self.view!.bounds.width/3 * 2 - self.view!.bounds.width/10, y: self.view!.bounds.height/2 + (self.view!.bounds.height/13.5), width: self.view!.bounds.width/10, height: self.view!.bounds.height/14)
        rStone.text = "Stone"
        rStone.font = UIFont(name: "Arial", size: 13)
        rStone.backgroundColor = UIColor.gray
        rStone.borderStyle = UITextBorderStyle.roundedRect
        rStone.isUserInteractionEnabled = false
        rStone.textAlignment = NSTextAlignment.center
        self.view?.addSubview(rStone)
    }
    
    //function that removes all trademenu ui elements
    func closeTradeMenu() {
        tradeOpen = false
        lWood.removeFromSuperview()
        lSheep.removeFromSuperview()
        lWheat.removeFromSuperview()
        lBrick.removeFromSuperview()
        lStone.removeFromSuperview()
        lGold.removeFromSuperview()
        rWood.removeFromSuperview()
        rSheep.removeFromSuperview()
        rWheat.removeFromSuperview()
        rBrick.removeFromSuperview()
        rStone.removeFromSuperview()
        tradeBackground.removeFromSuperview()
    }
    
    //function that will handle touches when trade menu is open
    func tradeMenuTouches(target : CGPoint) {
        
        if (leftTradeItem == nil) {
            if (self.lWood.frame.contains(target) && players[myPlayerIndex].wood >= 4) {
                DispatchQueue.main.async {
                    self.lWood.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                leftTradeItem = hexType.wood
            }
            if (self.lSheep.frame.contains(target) && players[myPlayerIndex].sheep >= 4) {
                DispatchQueue.main.async {
                    self.lSheep.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                leftTradeItem = hexType.sheep
            }
            if (self.lBrick.frame.contains(target) && players[myPlayerIndex].brick >= 4) {
                DispatchQueue.main.async {
                    self.lBrick.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                leftTradeItem = hexType.brick
            }
            if (self.lStone.frame.contains(target) && players[myPlayerIndex].stone >= 4) {
                DispatchQueue.main.async {
                    self.lStone.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                leftTradeItem = hexType.stone
            }
            if (self.lWheat.frame.contains(target) && players[myPlayerIndex].wheat >= 4) {
                DispatchQueue.main.async {
                    self.lWheat.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                leftTradeItem = hexType.wheat
            }
            if (self.lGold.frame.contains(target) && players[myPlayerIndex].gold >= 2) {
                DispatchQueue.main.async {
                    self.lGold.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                leftTradeItem = hexType.gold
            }
        }
        
        if (rightTradeItem == nil) {
            if (self.rWood.frame.contains(target)) {
                DispatchQueue.main.async {
                    self.rWood.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                rightTradeItem = hexType.wood
            }
            if (self.rSheep.frame.contains(target)) {
                DispatchQueue.main.async {
                    self.rSheep.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                rightTradeItem = hexType.sheep
            }
            if (self.rBrick.frame.contains(target)) {
                DispatchQueue.main.async {
                    self.rBrick.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                rightTradeItem = hexType.brick
            }
            if (self.rStone.frame.contains(target)) {
                DispatchQueue.main.async {
                    self.rStone.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                rightTradeItem = hexType.stone
            }
            if (self.rWheat.frame.contains(target)) {
                DispatchQueue.main.async {
                    self.rWheat.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
                }
                rightTradeItem = hexType.wheat
            }
        }
        
        
        if (leftTradeItem != nil && rightTradeItem != nil) {
            switch leftTradeItem! {
            case .wood : players[myPlayerIndex].wood -= 4
            case .wheat : players[myPlayerIndex].wheat -= 4
            case .brick : players[myPlayerIndex].brick -= 4
            case .stone : players[myPlayerIndex].stone -= 4
            case .sheep : players[myPlayerIndex].sheep -= 4
            case .gold : players[myPlayerIndex].gold -= 2
            default: break
            }
            
            switch rightTradeItem! {
            case .wood : players[myPlayerIndex].wood += 1
            case .wheat : players[myPlayerIndex].wheat += 1
            case .brick : players[myPlayerIndex].brick += 1
            case .stone : players[myPlayerIndex].stone += 1
            case .sheep : players[myPlayerIndex].sheep += 1
            default : break
            }
            
            leftTradeItem = nil
            rightTradeItem = nil
            
            sendPlayerData(player: myPlayerIndex)
            DispatchQueue.main.async {
                self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
            }
            
            closeTradeMenu()
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
        if (type == .Knight && !canPlaceKnight(corner: corner!)) { return false }
        if (corner!.tile1.onMainIsland == false) { return false }


        corner!.cornerObject = cornerObject(cornerType : type, owner: myPlayerIndex)
        if type == .Knight {
            players[currentPlayer].ownedKnights.append(corner!)
        }
        else {
            players[currentPlayer].ownedCorners.append(corner!)
        }
        
        var tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)"})
        
        if type == .Knight {
            tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(String(describing: corner?.cornerObject!.isActive))"})
        }
        
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        let cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),\(type.rawValue),\(corner!.cornerObject!.strength),\(String(describing: corner?.cornerObject!.isActive)),\(String(describing: corner?.cornerObject!.hasBeenUpgradedThisTurn)),\(String(describing: corner?.cornerObject!.didActionThisTurn))"
        
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
        DispatchQueue.main.async {
            self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
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
        
        return true
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
        
        DispatchQueue.main.async {
            self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
        }
        
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
        
        DispatchQueue.main.async {
            self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
        }
        
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
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        // Inform other players of resource change
        sendPlayerData(player: myPlayerIndex)
        
        DispatchQueue.main.async {
            self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
        }
        
        let cornerObjectInfo = "cornerData.\(myPlayerIndex),\(column),\(row),\(cornerType.City.rawValue)"
        
        // Send object info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        else {
            print ("successful sync cornerObject")
        }

        return true
    }
    
    func buildKnight(column : Int, row : Int, valid: Bool) -> Bool {
        if (!valid) { return false }
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false}
        if (corner?.cornerObject != nil) { return false }
        if (!canPlaceKnight(corner: corner!)) { return false }
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
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(String(describing: corner?.cornerObject!.isActive))"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        let cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),\(corner!.cornerObject!.type.rawValue),\(corner!.cornerObject!.strength),\(String(describing: corner?.cornerObject!.isActive)),\(String(describing: corner?.cornerObject!.hasBeenUpgradedThisTurn)),\(String(describing: corner?.cornerObject!.didActionThisTurn))"
        
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
        DispatchQueue.main.async {
            self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
        }
        
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
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(String(describing: corner?.cornerObject!.isActive))"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        // Inform other players of resource change
        sendPlayerData(player: myPlayerIndex)
        
        DispatchQueue.main.async {
            self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
        }
        
        // Inform other players of knight change
        let cornerObjectInfo = "cornerData.\(myPlayerIndex),\(column),\(row),\(cornerType.Knight.rawValue),\(corner?.cornerObject?.strength ?? 1),\(corner?.cornerObject?.isActive ?? false),\(corner?.cornerObject?.hasBeenUpgradedThisTurn ?? false),\(corner?.cornerObject?.didActionThisTurn ?? true)"
        
        // Send object info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
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
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(String(describing: corner?.cornerObject!.isActive))"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        // Inform other players of resource change
        sendPlayerData(player: myPlayerIndex)
        
        DispatchQueue.main.async {
            self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
        }
        
        let cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),\(corner!.cornerObject!.type.rawValue),\(corner!.cornerObject!.strength),true,\(String(describing: corner?.cornerObject!.hasBeenUpgradedThisTurn)),true)"
        
        // Send object info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }
        
        return true
    }
    
    func moveKnight(column: Int, row: Int, valid:Bool) -> Bool {
        if (!valid) { return false }
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false }
        if (corner!.cornerObject == nil) { return false }
        if (corner!.cornerObject!.type != .Knight) { return false }
        if (corner!.cornerObject!.didActionThisTurn) { return false }
        
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
    
    func placeKnightForFree(column: Int, row: Int, valid:Bool, displacable: Bool) -> Bool {
        if (!valid) { return false }
        let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
        if (corner == nil) { return false}
        if (!canPlaceKnight(corner: corner!)) { return false }
        
        if (corner?.cornerObject != nil && !displacable) { return false }
        else if (corner?.cornerObject != nil) {
            let displace = corner!.cornerObject!
            if (displace.type != .Knight) { return false }
            if (displace.owner == myPlayerIndex) { return false }
            if (displace.strength >= players[myPlayerIndex].movingKnightStrength) { return false }
            
            let index = players[displace.owner].ownedKnights.index(where: {$0.column == column && $0.row == row})
            players[displace.owner].ownedKnights.remove(at: index!)
            
            corner?.cornerObject = nil
            
            let displaceInfo = "cornerData.\(currentPlayer),\(column),\(row),nil"
            let sent = appDelegate.networkManager.sendData(data: displaceInfo)
            if (!sent) {
                print ("failed to sync cornerObject")
            }
            sendDisplaceRequest(player: displace.owner, column: column, row: row, strength: displace.strength, active: displace.isActive)
        }
        
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
        
        corner!.cornerObject = cornerObject(cornerType : .Knight, owner: myPlayerIndex)
        corner!.cornerObject!.strength = players[myPlayerIndex].movingKnightStrength
        corner!.cornerObject!.hasBeenUpgradedThisTurn = players[myPlayerIndex].movingKnightUpgraded
        players[currentPlayer].ownedKnights.append(corner!)
        
        let tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(String(describing: corner?.cornerObject!.isActive))"})
        handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        
        let cornerObjectInfo = "cornerData.\(currentPlayer),\(column),\(row),\(corner!.cornerObject!.type.rawValue),\(corner!.cornerObject!.strength),\(String(describing: corner?.cornerObject!.isActive)),\(String(describing: corner?.cornerObject!.hasBeenUpgradedThisTurn)),\(String(describing: corner?.cornerObject!.didActionThisTurn))"
        
        // Send player info to other players
        let sent = appDelegate.networkManager.sendData(data: cornerObjectInfo)
        if (!sent) {
            print ("failed to sync cornerObject")
        }

        DispatchQueue.main.async {
            self.playerInfo.text = self.players[self.myPlayerIndex].getPlayerText()
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
        
        if !replacementExists(row: row, col: col) { return }
        
        players[player].movingKnightFromCol = col
        players[player].movingKnightFromRow = row
        players[player].movingKnightStrength = strength
        players[player].movingKnightUpgraded = active
        players[player].nextAction = .WillDisplaceKnight
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
                    if (v1?.row == v.row && v1?.column == v.column) {
                        queue.append(v2!)
                    }
                    else {
                        queue.append(v1!)
                    }
                }

            }
            if (has3 == nil && e3 != nil && e3?.edgeObject?.owner == myPlayerIndex) {
                let v1 = e3?.neighbourVertex1
                let v2 = e3?.neighbourVertex2
                visited.append(e3!)
                if (v1?.cornerObject == nil || v1?.cornerObject?.owner == myPlayerIndex) {
                    if (v1?.row == v.row && v1?.column == v.column) {
                        queue.append(v2!)
                    }
                    else {
                        queue.append(v1!)
                    }
                }
            }
        }
        
        return false
    }
    
    func replacementExists(row: Int, col: Int) -> Bool {
        let start = players[myPlayerIndex].ownedKnights.first(where:{$0.row == row && $0.column == col})
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
                    if (v1?.row == v.row && v1?.column == v.column) {
                        queue.append(v2!)
                    }
                    else {
                        queue.append(v1!)
                    }
                }
                
            }
            if (has3 == nil && e3 != nil && e3?.edgeObject?.owner == myPlayerIndex) {
                let v1 = e3?.neighbourVertex1
                let v2 = e3?.neighbourVertex2
                visited.append(e3!)
                if (v1?.cornerObject == nil || v1?.cornerObject?.owner == myPlayerIndex) {
                    if (v1?.row == v.row && v1?.column == v.column) {
                        queue.append(v2!)
                    }
                    else {
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
    
    //function that will read a recieved message and set the corner object
    func setCornerObjectFromMessage(info:String) {
        let cornerInfo = info.components(separatedBy: ",")
        let currPlayerNumber = Int(cornerInfo[0])!
        let column = Int(cornerInfo[1])!
        let row = Int(cornerInfo[2])!
        if(cornerInfo[3] != "nil") {
            let type = cornerType(rawValue: cornerInfo[3])
            
            let corner = handler.landHexVertexArray.first(where: {$0.column == column && $0.row == row})
            
            corner?.cornerObject = cornerObject(cornerType : type!, owner: currPlayerNumber)
            
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
                let used = Bool(cornerInfo[6])
                if (used == nil) {
                    corner?.cornerObject?.didActionThisTurn = true
                }
                else {
                    corner?.cornerObject?.didActionThisTurn = used!
                }
                
                players[currPlayerNumber].ownedKnights.append(corner!)
            }
            else {
                players[currPlayerNumber].ownedCorners.append(corner!)
            }
            
            var tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)"})
            
            if type == .Knight {
                tileGroup = handler.verticesTiles.tileGroups.first(where: {$0.name == "\(players[currentPlayer].color.rawValue)\(corner!.cornerObject!.type.rawValue)\(corner!.cornerObject!.strength)\(corner!.cornerObject!.isActive)"})
            }
            
            handler.Vertices.setTileGroup(tileGroup, forColumn: column, row: row)
        }
        else {
            var isKnight = false
            var index = players[currPlayerNumber].ownedCorners.index(where: {$0.column == column && $0.row == row})
            
            if (index == nil) {
                index = players[currPlayerNumber].ownedKnights.index(where: {$0.column == column && $0.row == row})
                isKnight = true
            }
            
            if (isKnight) {
                players[currPlayerNumber].ownedKnights.remove(at: index!)
            }
            else {
                players[currPlayerNumber].ownedCorners.remove(at: index!)
            }
            
            handler.Edges.setTileGroup(nil, forColumn: column, row: row)
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
    
    // function that rolls the dice
    func rollDice() {
        let values = dice.rollDice()
        updateDice(red: values[0], yellow: values[1], event: values[2])
        let diceData = "diceRoll.\(values[0]),\(values[1]),\(values[2])"
        
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
                switch barbariansDistanceFromCatan {
                    case 0:
                        notificationContent.text = "The Barbarians have arrived, and are attacking...brace yourselves!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                        })
                        barbariansDistanceFromCatan = 7
                        break   //  PERFORM SCENARIO AND RESET DISTANCE TO 7 AND SEND NEW DATA TO OTHER PLAYERS
                    case 1...2:
                        notificationContent.text = "The Barbarians are \(barbariansDistanceFromCatan) roll" + (barbariansDistanceFromCatan == 2 ? "s" : "") + " away from Catan, and will be attacking shortly!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                        })
                    case 3...5:
                        notificationContent.text = "The Barbarians are \(barbariansDistanceFromCatan) rolls away from Catan, and will be attacking soon!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                        })
                    case 6...7:
                        notificationContent.text = "The Barbarians are \(barbariansDistanceFromCatan) rolls away from Catan, start preparing!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                        })
                    default: break
                }
            case .PoliticsSide:
                if players[myPlayerIndex].politicsImprovementLevel + 3 > values[0] {
                    let newCard = ProgressCardsType.getNextCardOfCategory(ProgressCardsCategory.Politics, fromDeck: &gameDeck)
                    if let card = newCard {
                        notificationContent.text = "You have just received The \(card) Progress Card from the Politics Deck...congratulations!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                        })
                        players[myPlayerIndex].progressCards.append(card)
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
                    let newCard = ProgressCardsType.getNextCardOfCategory(ProgressCardsCategory.Sciences, fromDeck: &gameDeck)
                    if let card = newCard {
                        notificationContent.text = "You have just received The \(card) Progress Card from the Sciences Deck...congratulations!"
                        self.view?.addSubview(notificationBanner)
                        self.view?.addSubview(notificationContent)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            notificationContent.removeFromSuperview()
                            notificationBanner.removeFromSuperview()
                        })
                        players[myPlayerIndex].progressCards.append(card)
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
            for player in players { // for each player...
                for vertex in player.ownedCorners { // distribute resources if vertex touches hex
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
                                    player.wood += 1; print("\(player.name) mined wood")
                                    player.paper += 1; print("\(player.name) produced paper")
                                }
                                else {
                                    player.wood += 1; print("\(player.name) mined wood")
                                }
                            case .wheat: player.wheat += numberResources; print("\(player.name) mined wheat")
                            case .stone:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    player.stone += 1; print("\(player.name) mined stone")
                                    player.coin += 1; print("\(player.name) produced coin")
                                }
                                else {
                                    player.stone += 1; print("\(player.name) mined stone")
                                }
                            case .sheep:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    player.sheep += 1; print("\(player.name) mined sheep")
                                    player.cloth += 1; print("\(player.name) produced cloth")
                                }
                                else {
                                    player.coin += 1; print("\(player.name) mined sheep")
                                }
                            case .brick: player.brick += numberResources; print("\(player.name) mined brick")
                            case .gold: player.gold += (numberResources*2); print("\(player.name) mined gold")
                            case .fish:
                                var newFish = drawFishCard()
                        
                                if (newFish == -1) { /* Deck is empty */ }
                                else if (newFish == 0) {
                                   player.hasOldBoot = true
                                }
                                else {
                                    player.fish += newFish
                                    if (vertex.cornerObject?.type == cornerType.City) {
                                        newFish = drawFishCard()
                                        if (newFish == -1) { /* Deck is empty */ }
                                        else if (newFish == 0) {
                                            player.hasOldBoot = true
                                        }
                                        else {
                                            player.fish += newFish
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
                                    player.wood += 1; print("\(player.name) mined wood")
                                    player.paper += 1; print("\(player.name) produced paper")
                                }
                                else {
                                    player.wood += 1; print("\(player.name) mined wood")
                                }
                            case .wheat: player.wheat += numberResources; print("\(player.name) mined wheat")
                            case .stone:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    player.stone += 1; print("\(player.name) mined stone")
                                    player.coin += 1; print("\(player.name) produced coin")
                                }
                                else {
                                    player.stone += 1; print("\(player.name) mined stone")
                                }
                            case .sheep:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    player.sheep += 1; print("\(player.name) mined sheep")
                                    player.cloth += 1; print("\(player.name) produced cloth")
                                }
                                else {
                                    player.coin += 1; print("\(player.name) mined sheep")
                                }
                            case .brick: player.brick += numberResources; print("\(player.name) mined brick")
                            case .gold: player.gold += (numberResources*2); print("\(player.name) mined gold")
                            case .fish:
                             var newFish = drawFishCard()
                             
                             if (newFish == -1) { /* Deck is empty */ }
                             else if (newFish == 0) {
                                player.hasOldBoot = true
                             }
                             else {
                                player.fish += newFish
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    newFish = drawFishCard()
                                    if (newFish == -1) { /* Deck is empty */ }
                                    else if (newFish == 0) {
                                        player.hasOldBoot = true
                                    }
                                    else {
                                        player.fish += newFish
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
                                    player.wood += 1; print("\(player.name) mined wood")
                                    player.paper += 1; print("\(player.name) produced paper")
                                }
                                else {
                                    player.wood += 1; print("\(player.name) mined wood")
                                }
                            case .wheat: player.wheat += numberResources; print("\(player.name) mined wheat")
                            case .stone:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    player.stone += 1; print("\(player.name) mined stone")
                                    player.coin += 1; print("\(player.name) produced coin")
                                }
                                else {
                                    player.stone += 1; print("\(player.name) mined stone")
                                }
                            case .sheep:
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    player.sheep += 1; print("\(player.name) mined sheep")
                                    player.cloth += 1; print("\(player.name) produced cloth")
                                }
                                else {
                                    player.coin += 1; print("\(player.name) mined sheep")
                                }
                            case .brick: player.brick += numberResources; print("\(player.name) mined brick")
                            case .gold: player.gold += (numberResources*2); print("\(player.name) mined gold")
                            case .fish:
                             var newFish = drawFishCard()
                             
                             if (newFish == -1) { /* Deck is empty */ }
                             else if (newFish == 0) {
                                player.hasOldBoot = true
                             }
                             else {
                                player.fish += newFish
                                if (vertex.cornerObject?.type == cornerType.City) {
                                    newFish = drawFishCard()
                                    if (newFish == -1) { /* Deck is empty */ }
                                    else if (newFish  == 0) {
                                        player.hasOldBoot = true
                                    }
                                    else {
                                        player.fish += newFish
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
                if (redDiceUI.frame.contains(targetLocationView) || yellowDiceUI.frame.contains(targetLocationView)) {
                    if(!rolled) {
                        rollDice()
                        rolled = true
                    }
                }
                if (cancelButton.frame.contains(targetLocationView)) {
                    players[myPlayerIndex].nextAction = .WillDoNothing
                    cancelButton.backgroundColor = UIColor.gray
                }
                if (self.gameButton.frame.contains(targetLocationView)) {
                    if (rolled && players[myPlayerIndex].nextAction == .WillDoNothing) {
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
                if (redDiceUI.frame.contains(targetLocationView) || yellowDiceUI.frame.contains(targetLocationView)) {
                    if(!rolled) {
                        rollDice()
                        rolled = true
                    }
                }
                if (cancelButton.frame.contains(targetLocationView)) {
                    players[myPlayerIndex].nextAction = .WillDoNothing
                    cancelButton.backgroundColor = UIColor.gray
                }
                if (self.gameButton.frame.contains(targetLocationView)) {
                    if (rolled && players[myPlayerIndex].nextAction == .WillDoNothing) {
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
                if (redDiceUI.frame.contains(targetLocationView) || yellowDiceUI.frame.contains(targetLocationView)) {
                    if(!rolled) {
                        rollDice()
                        rolled = true
                    }
                }
                if (cancelButton.frame.contains(targetLocationView)) {
                    players[myPlayerIndex].nextAction = .WillDoNothing
                    cancelButton.backgroundColor = UIColor.gray
                }
                if (self.gameButton.frame.contains(targetLocationView)) {
                    if (rolled && players[myPlayerIndex].nextAction == .WillDoNothing) {
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
                case .WillBuildWall: return;   //  NOT IMPLEMENTED
                case .WillBuildKnight:
                    let built = buildKnight(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if (built) { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillPromoteKnight:
                    let upgraded = upgradeKnight(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if (upgraded) { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillActivateKnight:
                    let activated = activateKnight(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
                    if (activated) { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillBuildMetropolis: return;   //  NOT IMPLEMENTED
                case .WillRemoveOutlaw: return;   //  NOT IMPLEMENTED
                case .WillMoveShip: let movedShip = moveShip(column: handler.Edges.tileColumnIndex(fromPosition: targetLocation), row: handler.Edges.tileRowIndex(fromPosition: targetLocation), valid: rolled)
                if !movedShip { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillMoveKnight:
                    let movedKnight = moveKnight(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid: rolled)
                    if (movedKnight) { players[myPlayerIndex].nextAction = .WillBuildKnightForFree }
                case .WillMoveOutlaw: return;   //  NOT IMPLEMENTED
                case .WillBuildKnightForFree:
                    let movedKnight = placeKnightForFree(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid: rolled, displacable: true)
                    if movedKnight { players[myPlayerIndex].nextAction = .WillDoNothing }
                case .WillDisplaceKnight:
                    let movedKnight = placeKnightForFree(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid: true, displacable: false)
                    if movedKnight {
                        players[myPlayerIndex].nextAction = .WillDoNothing
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
                    }
                default: break
            }
        }

        
        
//        if (self.tradeButton.frame.contains(targetLocationView) && rolled && !buildRoad && !buildSettlement && !buildShip) {
//            if (tradeOpen) {
//                closeTradeMenu()
//            } else {
//                presentTradeMenu()
//            }
//        }
//        if(tradeOpen) {
//            tradeMenuTouches(target: targetLocationView)
//        }
//        if (self.buildUpgradeButton.frame.contains(targetLocationView) && rolled && (hasResourcesForNewSettlement() || hasResourcesToUpgradeSettlement()) && !tradeOpen && !buildRoad && !buildShip) {
//            if(buildSettlement) {
//                buildSettlement = false
//                DispatchQueue.main.async {
//                    self.buildUpgradeButton.backgroundColor = UIColor.gray
//                }
//            } else {
//                buildSettlement = true
//                DispatchQueue.main.async {
//                    self.buildUpgradeButton.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
//                }
//            }
//        }
//        if (self.buildRoadButton.frame.contains(targetLocationView) && rolled && hasResourcesForNewRoad() && !tradeOpen && !buildSettlement && !buildShip
//            ) {
//            if (buildRoad) {
//                buildRoad = false
//                DispatchQueue.main.async {
//                    self.buildRoadButton.backgroundColor = UIColor.gray
//                }
//            } else {
//                buildRoad = true
//                DispatchQueue.main.async {
//                    self.buildRoadButton.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
//                }
//            }
//        }
//        if (self.buildShipButton.frame.contains(targetLocationView) && rolled && hasResourcesForNewShip() && !tradeOpen && !buildSettlement && !buildRoad
//            ) {
//            if (buildShip) {
//                buildShip = false
//                DispatchQueue.main.async {
//                    self.buildShipButton.backgroundColor = UIColor.gray
//                }
//            } else {
//                buildShip = true
//                DispatchQueue.main.async {
//                    self.buildShipButton.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
//                }
//            }
//        }
//        if (buildSettlement) {
//            let settlementBuilt = buildSettlement(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row: handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
//            
//            if (settlementBuilt) {
//                print ("Settlement Built")
//                buildSettlement = false
//                DispatchQueue.main.async {
//                    self.buildUpgradeButton.backgroundColor = UIColor.gray
//                }
//            } else {
//                let settlementUpgraded = upgradeSettlement(column: handler.Vertices.tileColumnIndex(fromPosition: targetLocation) - 2, row:  handler.Vertices.tileRowIndex(fromPosition: targetLocation), valid:rolled)
//                if (settlementUpgraded) {
//                    print ("Settlement Upgraded")
//                    buildSettlement = false
//                    DispatchQueue.main.async {
//                        self.buildUpgradeButton.backgroundColor = UIColor.gray
//                    }
//                }
//            }
//        }
//        if (buildRoad) {
//            let roadBuilt = buildRoad(column: handler.Edges.tileColumnIndex(fromPosition: targetLocation), row:  handler.Edges.tileRowIndex(fromPosition: targetLocation), type: edgeType.Road, valid:rolled)
//            if (roadBuilt) {
//                print("Road Built")
//                buildRoad = false
//                DispatchQueue.main.async {
//                    self.buildRoadButton.backgroundColor = UIColor.gray
//                }
//            }
//        }
//        if (buildShip) {
//            let shipBuilt = buildShip(column: handler.Edges.tileColumnIndex(fromPosition: targetLocation), row:  handler.Edges.tileRowIndex(fromPosition: targetLocation), type: edgeType.Boat, valid:rolled)
//            if (shipBuilt) {
//                print("Ship Built")
//                buildShip = false
//                DispatchQueue.main.async {
//                    self.buildShipButton.backgroundColor = UIColor.gray
//                }
//            }
//        }
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
