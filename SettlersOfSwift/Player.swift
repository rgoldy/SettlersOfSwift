//
//  Player.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-03-01.
//  Copyright © 2017 Comp361. All rights reserved.
//

//color enum
enum playerColor:String {
    case Red
    case Blue
    case Orange
}

//class which represents each player and it's respective attributes
class Player {
    var wood = 0
    var woodTradeRatio = 4
    var wheat = 0
    var wheatTradeRatio = 4
    var stone = 0
    var stoneTradeRatio = 4
    var sheep = 0
    var sheepTradeRatio = 4
    var brick = 0
    var brickTradeRatio = 4
    var gold = 2
    var goldTradeRatio = 2
    
    var progressCards = [ProgressCardsType]()
    var receivedPeersCards = false
    
    var politicsImprovementLevel = -1
    var sciencesImprovementLevel = -1
    var tradesImprovementLevel = -1
    
    var holdsPoliticsMetropolis = false
    var holdsSciencesMetropolis = false
    var holdsTradesMetropolis = false
    
    var canBuildMetropolis = 0
    
    var nextAction: PlayerIntentions = .WillDoNothing
    
    var paper = 0
    var paperTradeRatio = 4
    var cloth = 0
    var clothTradeRatio = 4
    var coin = 0
    var coinTradeRatio = 4
    
    var fish = 0
    var hasOldBoot = false
    
    var tradeAccepted: Bool? = nil
    var fetchedTargetData = false
    
    var victoryPoints = 0
    
    var name : String
    var longestRoad = 0
    var ownedCorners : [LandHexVertex] = []
    var ownedEdges : [LandHexEdge] = []
    var ownedKnights : [LandHexVertex] = []
    var color : playerColor
    
    var movingKnightStrength: Int = 0
    var movingKnightUpgraded: Bool = false
    var movingKnightFromRow: Int = 0
    var movingKnightFromCol: Int = 0
    
    var movedShipThisTurn : Bool = false
    
    var comingFromFishes = false
    
    var dataReceived = false
    
    init(name : String, playerNumber : Int) {
        self.name = name
        switch playerNumber {
        case 1:
            color = playerColor.Blue
        case 2:
            color = playerColor.Orange
        default:
            color = playerColor.Red
        }
    }
    
    //  CALL THIS WHEN REMOVING METROPOLIS FROM A PLAYER
    
    func willLoseMetropolisFor(_ type: ChartTypes) {
        switch type {
            case .Politics: break
            case .Sciences: break
            case .Trades: break
        }
    }
    
    // Returns the number of cards the player must remove from their hand
    // when a 7 is rolled
    func mustRemoveHalfOfHand() -> Int {
        var numWalls = 0
        for cityCorner in ownedCorners {
            let city = cityCorner.cornerObject!
            if city.hasCityWall { numWalls += 1 }
        }
        
        let numCards = wood + wheat + stone + sheep + brick + paper + coin + cloth
        let boundary = 7 + 2*numWalls
        if (numCards > boundary) {
            return Int(numCards / 2)
        }
        return 0
    }
    
    func getPlayerText() -> String {
        return "\(name) : Wood = \(wood), Wheat = \(wheat), Stone = \(stone), Sheep = \(sheep), Brick = \(brick), Gold = \(gold), Paper = \(paper), Cloth = \(cloth), Coin = \(coin)"
    }
}
