//
//  InGameFlipChartsViewController.swift
//  SettlersOfSwift
//
//  Created by YIFFY on 3/31/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

//  RETURNED STRINGS ARE PLACEHOLDERS

enum ChartTypes: Int {
    case Politics = 0
    case Sciences = 1
    case Trades = 2
    static func getDescription(_ chart: ChartTypes) -> String {
        switch chart {
            case .Politics: return "POLITICS"
            case .Sciences: return "SCIENCES"
            case .Trades: return "TRADES"
    }   }
    static func getChartDice(_ chart: ChartTypes) -> String {
        switch chart {
            case .Politics: return "💙"
            case .Sciences: return "💚"
            case .Trades: return "💛"
    }   }
    static func getDicesCount(_ level: Int) -> String {
        switch level {
            case 0: return "{ 1️⃣ , 2️⃣ }"
            case 1: return "{ 1️⃣ , 2️⃣ , 3️⃣ }"
            case 2: return "{ 1️⃣ , 2️⃣ , 3️⃣ , 4️⃣ }"
            case 3: return "{ 1️⃣ , 2️⃣ , 3️⃣ , 4️⃣ , 5️⃣ }"
            case 4: return "{ 1️⃣ , 2️⃣ , 3️⃣ , 4️⃣ , 5️⃣ , 6️⃣ }"
            default: return "{ 1️⃣ }"
    }   }
    static func getCardType(_ chart: ChartTypes) -> String {
        switch chart {
            case .Politics: return "📘"
            case .Sciences: return "📗"
            case .Trades: return "📒"
    }   }
    static func getImprovementDescription(_ level: Int, chart: ChartTypes) -> String {
        switch level {
            case 0:
                switch chart {
                    case .Politics: return "TOWN HALL"
                    case .Sciences: return "ABBEY"
                    case .Trades: return "MARKET"
                }
            case 1:
                switch chart {
                    case .Politics: return "CHURCH"
                    case .Sciences: return "LIBRARY"
                    case .Trades: return "TRADING HOUSE"
                }
            case 2:
                switch chart {
                    case .Politics: return "FORTRESS"
                    case .Sciences: return "AQUEDUCT"
                    case .Trades: return "MERCHANT GUILD"
                }
            case 3:
                switch chart {
                    case .Politics: return "CATHEDRAL"
                    case .Sciences: return "THEATER"
                    case .Trades: return "BANK"
                }
            case 4:
                switch chart {
                    case .Politics: return "HIGH ASSEMBLY"
                    case .Sciences: return "UNIVERSITY"
                    case .Trades: return "GREAT EXCHANGE"
                }
            default: return "NOTHING"
    }   }
}

class InGameFlipChartsViewController: UIViewController {
    
    @IBOutlet weak var previousChartPreview: UIImageView!
    @IBOutlet weak var nextChartPreview: UIImageView!
    @IBOutlet weak var currentChartTitle: UILabel!
    @IBOutlet weak var currentChartSubtitle: UILabel!
    @IBOutlet weak var currentPageIndicator: UIPageControl!
    
    @IBOutlet weak var firstImprovement: UIImageView!
    @IBOutlet weak var secondImprovement: UIImageView!
    @IBOutlet weak var thirdImprovement: UIImageView!
    @IBOutlet weak var fourthImprovement: UIImageView!
    @IBOutlet weak var lastImprovement: UIImageView!
    
    @IBOutlet weak var firstItemButton: UIButton!
    @IBOutlet weak var firstItemRequirementA: UIImageView!
    @IBOutlet weak var firstItemRequirementB: UIImageView!
    @IBOutlet weak var firstItemRequirementC: UIImageView!
    @IBOutlet weak var firstItemRequirementD: UIImageView!
    @IBOutlet weak var firstItemRequirementE: UIImageView!
    
    @IBOutlet weak var secondItemButton: UIButton!
    @IBOutlet weak var secondItemRequirementA: UIImageView!
    @IBOutlet weak var secondItemRequirementB: UIImageView!
    @IBOutlet weak var secondItemRequirementC: UIImageView!
    @IBOutlet weak var secondItemRequirementD: UIImageView!
    @IBOutlet weak var secondItemRequirementE: UIImageView!
    
    @IBOutlet weak var thirdItemButton: UIButton!
    @IBOutlet weak var thirdItemRequirementA: UIImageView!
    @IBOutlet weak var thirdItemRequirementB: UIImageView!
    @IBOutlet weak var thirdItemRequirementC: UIImageView!
    @IBOutlet weak var thirdItemRequirementD: UIImageView!
    @IBOutlet weak var thirdItemRequirementE: UIImageView!
    
    @IBOutlet weak var fourthItemButton: UIButton!
    @IBOutlet weak var fourthItemRequirementA: UIImageView!
    @IBOutlet weak var fourthItemRequirementB: UIImageView!
    @IBOutlet weak var fourthItemRequirementC: UIImageView!
    @IBOutlet weak var fourthItemRequirementD: UIImageView!
    @IBOutlet weak var fourthItemRequirementE: UIImageView!
    
    var chartsSceneIndex = 0    //  indicates which chart is currently displayed
    var gameDataReference: GameViewController!
    
    //  update chart details to previous chart
    
    @IBAction func playerDidSwipeRight(_ sender: Any) {
        chartsSceneIndex += 2
        if chartsSceneIndex > 2 { chartsSceneIndex %= 3 }
        if currentPageIndicator.currentPage == 0 { currentPageIndicator.currentPage = 2 } else { currentPageIndicator.currentPage -= 1 }
        drawCurrentChartScene()
    }
    
    //  update to details to next chart
    
    @IBAction func playerDidSwipeLeft(_ sender: Any) {
        chartsSceneIndex += 1
        if chartsSceneIndex > 2 { chartsSceneIndex %= 3 }
        if currentPageIndicator.currentPage == 2 { currentPageIndicator.currentPage = 0 } else { currentPageIndicator.currentPage += 1 }
        drawCurrentChartScene()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  MIGHT HAVE TO MODIFY BELOW CODE TO viewWillAppear(Bool) METHOD TO BE COMPATIBLE WITH SAVE LOADING
        gameDataReference = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! GameViewController
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "menuBackground")!)
        chartsSceneIndex = 0
        drawCurrentChartScene()
        gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].nextAction = .WillDoNothing
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawCurrentChartScene() {
        let playerReference = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        
        var level = -1
        if chartsSceneIndex == 0 { level = playerReference.politicsImprovementLevel }
        if chartsSceneIndex == 1 { level = playerReference.sciencesImprovementLevel }
        if chartsSceneIndex == 2 { level = playerReference.tradesImprovementLevel }
        currentChartTitle.text = "BUILDING / " + ChartTypes.getDescription(ChartTypes.init(rawValue: chartsSceneIndex)!) + " - THE " + ChartTypes.getImprovementDescription(level, chart: ChartTypes.init(rawValue: chartsSceneIndex)!)
        if level > 1 {
            switch chartsSceneIndex {   //  TO IMPLEMENT EFFECTS
                case 0: currentChartSubtitle.text = "You may promote strong knights to mighty knights!"
                case 1: currentChartSubtitle.text = "You will always be able to receive resources given that 7 isn't rolled!"
                case 2: currentChartSubtitle.text = "You may trade any commodity at a two-for-one rate!"
                default: break
            }
        } else {
            currentChartSubtitle.text = "Upgrade to THE " + ChartTypes.getImprovementDescription(2, chart: ChartTypes.init(rawValue: chartsSceneIndex)!) + " to unlock new benefits!"
        }
        previousChartPreview.image = UIImage(named: "leftOf_" + ChartTypes.getDescription(ChartTypes.init(rawValue: chartsSceneIndex)!))
        nextChartPreview.image = UIImage(named: "rightOf_" + ChartTypes.getDescription(ChartTypes.init(rawValue: chartsSceneIndex)!))
        switch chartsSceneIndex {
            case 0:
                firstImprovement.image = UIImage.init(named: "POLITICS_1")
                if playerReference.politicsImprovementLevel < 0 { firstImprovement.alpha = 0.4 } else { firstImprovement.alpha = 1.0 }
                secondImprovement.image = UIImage.init(named: "POLITICS_2")
                if playerReference.politicsImprovementLevel < 1 { secondImprovement.alpha = 0.4 } else { secondImprovement.alpha = 1.0 }
                thirdImprovement.image = UIImage.init(named: "POLITICS_3")
                if playerReference.politicsImprovementLevel < 2 { thirdImprovement.alpha = 0.4 } else { thirdImprovement.alpha = 1.0 }
                fourthImprovement.image = UIImage.init(named: "POLITICS_4")
                if playerReference.politicsImprovementLevel < 3 { fourthImprovement.alpha = 0.4 } else { fourthImprovement.alpha = 1.0 }
                lastImprovement.image = UIImage.init(named: "POLITICS_5")
                if playerReference.politicsImprovementLevel < 4 { lastImprovement.alpha = 0.4 } else { lastImprovement.alpha = 1.0 }
                firstItemButton.setTitle("BUILD CITY", for: UIControlState.normal)
                firstItemButton.setTitle("BUILD CITY", for: UIControlState.disabled)
                firstItemRequirementA.image = UIImage(named: "STONE_REQ")
                firstItemRequirementB.image = UIImage(named: "STONE_REQ")
                firstItemRequirementC.image = UIImage(named: "STONE_REQ")
                firstItemRequirementD.image = UIImage(named: "WHEAT_REQ")
                firstItemRequirementE.image = UIImage(named: "WHEAT_REQ")
                if playerReference.stone < 3 || playerReference.wheat < 2 { firstItemButton.isEnabled = false } else { firstItemButton.isEnabled = true }
                secondItemButton.setTitle("BUILD WALL", for: UIControlState.normal)
                secondItemButton.setTitle("BUILD WALL", for: UIControlState.disabled)
                secondItemRequirementA.image = UIImage(named: "BRICK_REQ")
                secondItemRequirementB.image = UIImage(named: "BRICK_REQ")
                secondItemRequirementC.image = nil
                secondItemRequirementD.image = nil
                secondItemRequirementE.image = nil
                if playerReference.brick < 2 { secondItemButton.isEnabled = false } else { secondItemButton.isEnabled = true }
                thirdItemButton.setTitle("", for: UIControlState.normal)
                thirdItemButton.setTitle("", for: UIControlState.disabled)
                thirdItemRequirementA.image = nil
                thirdItemRequirementB.image = nil
                thirdItemRequirementC.image = nil
                thirdItemRequirementD.image = nil
                thirdItemRequirementE.image = nil
                thirdItemButton.isEnabled = false
                if playerReference.politicsImprovementLevel == 4 {
                    fourthItemButton.setTitle("", for: UIControlState.normal)
                    fourthItemButton.setTitle("", for: UIControlState.disabled)
                    fourthItemRequirementA.image = nil
                    fourthItemRequirementB.image = nil
                    fourthItemRequirementC.image = nil
                    fourthItemRequirementD.image = nil
                    fourthItemRequirementE.image = nil
                    fourthItemButton.isEnabled = false
                } else {
                    fourthItemButton.setTitle("UPGRADE TO " + ChartTypes.getImprovementDescription(playerReference.politicsImprovementLevel + 1, chart: ChartTypes.init(rawValue: 0)!), for: UIControlState.normal)
                    fourthItemButton.setTitle("UPGRADE TO " + ChartTypes.getImprovementDescription(playerReference.politicsImprovementLevel + 1, chart: ChartTypes.init(rawValue: 0)!), for: UIControlState.disabled)
                    fourthItemRequirementA.image = playerReference.politicsImprovementLevel > -2 ? UIImage(named: "COIN_REQ") : nil
                    fourthItemRequirementB.image = playerReference.politicsImprovementLevel > -1 ? UIImage(named: "COIN_REQ") : nil
                    fourthItemRequirementC.image = playerReference.politicsImprovementLevel > +0 ? UIImage(named: "COIN_REQ") : nil
                    fourthItemRequirementD.image = playerReference.politicsImprovementLevel > +1 ? UIImage(named: "COIN_REQ") : nil
                    fourthItemRequirementE.image = playerReference.politicsImprovementLevel > +2 ? UIImage(named: "COIN_REQ") : nil
                    if playerReference.coin < playerReference.politicsImprovementLevel + 2 || (playerReference.coin < playerReference.politicsImprovementLevel + 1 && playerReference.progressCards.contains(.Crane)) { fourthItemButton.isEnabled = false } else { fourthItemButton.isEnabled = true }
                }
            case 1:
                firstImprovement.image = UIImage.init(named: "SCIENCES_1")
                if playerReference.sciencesImprovementLevel < 0 { firstImprovement.alpha = 0.4 } else { firstImprovement.alpha = 1.0 }
                secondImprovement.image = UIImage.init(named: "SCIENCES_2")
                if playerReference.sciencesImprovementLevel < 1 { secondImprovement.alpha = 0.4 } else { secondImprovement.alpha = 1.0 }
                thirdImprovement.image = UIImage.init(named: "SCIENCES_3")
                if playerReference.sciencesImprovementLevel < 2 { thirdImprovement.alpha = 0.4 } else { thirdImprovement.alpha = 1.0 }
                fourthImprovement.image = UIImage.init(named: "SCIENCES_4")
                if playerReference.sciencesImprovementLevel < 3 { fourthImprovement.alpha = 0.4 } else { fourthImprovement.alpha = 1.0 }
                lastImprovement.image = UIImage.init(named: "SCIENCES_5")
                if playerReference.sciencesImprovementLevel < 4 { lastImprovement.alpha = 0.4 } else { lastImprovement.alpha = 1.0 }
                firstItemButton.setTitle("BUILD KNIGHT", for: UIControlState.normal)
                firstItemButton.setTitle("BUILD KNIGHT", for: UIControlState.disabled)
                firstItemRequirementA.image = UIImage(named: "STONE_REQ")
                firstItemRequirementB.image = UIImage(named: "SHEEP_REQ")
                firstItemRequirementC.image = nil
                firstItemRequirementD.image = nil
                firstItemRequirementE.image = nil
                if playerReference.stone < 1 || playerReference.sheep < 1 { firstItemButton.isEnabled = false }
                else { firstItemButton.isEnabled = true }
                secondItemButton.setTitle("PROMOTE KNIGHT", for: UIControlState.normal)
                secondItemButton.setTitle("PROMOTE KNIGHT", for: UIControlState.disabled)
                secondItemRequirementA.image = UIImage(named: "STONE_REQ")
                secondItemRequirementB.image = UIImage(named: "SHEEP_REQ")
                secondItemRequirementC.image = nil
                secondItemRequirementD.image = nil
                secondItemRequirementE.image = nil
                var canUpgradeKnight = false
                for knight in playerReference.ownedKnights {
                    if ((knight.cornerObject?.strength)! == 1) { canUpgradeKnight = true; break }
                    else if (knight.cornerObject?.strength == 2 && playerReference.politicsImprovementLevel >= 2) { canUpgradeKnight = true; break }
                }
                if playerReference.stone < 1 || playerReference.sheep < 1 || !canUpgradeKnight { secondItemButton.isEnabled = false }
                else { secondItemButton.isEnabled = true }
                thirdItemButton.setTitle("ACTIVATE KNIGHT", for: UIControlState.normal)
                thirdItemButton.setTitle("ACTIVATE KNIGHT", for: UIControlState.disabled)
                thirdItemRequirementA.image = UIImage(named: "WHEAT_REQ")
                thirdItemRequirementB.image = nil
                thirdItemRequirementC.image = nil
                thirdItemRequirementD.image = nil
                thirdItemRequirementE.image = nil
                var canActivateKnight = false
                for knight in playerReference.ownedKnights {
                    if (!(knight.cornerObject?.isActive)!) { canActivateKnight = true; break }
                }
                if playerReference.wheat < 1 || !canActivateKnight { thirdItemButton.isEnabled = false } else { thirdItemButton.isEnabled = true }
                if playerReference.sciencesImprovementLevel == 4 {
                    fourthItemButton.setTitle("", for: UIControlState.normal)
                    fourthItemButton.setTitle("", for: UIControlState.disabled)
                    fourthItemRequirementA.image = nil
                    fourthItemRequirementB.image = nil
                    fourthItemRequirementC.image = nil
                    fourthItemRequirementD.image = nil
                    fourthItemRequirementE.image = nil
                    fourthItemButton.isEnabled = false
                } else {
                    fourthItemButton.setTitle("UPGRADE TO " + ChartTypes.getImprovementDescription(playerReference.sciencesImprovementLevel + 1, chart: ChartTypes.init(rawValue: 1)!), for: UIControlState.normal)
                    fourthItemButton.setTitle("UPGRADE TO " + ChartTypes.getImprovementDescription(playerReference.sciencesImprovementLevel + 1, chart: ChartTypes.init(rawValue: 1)!), for: UIControlState.disabled)
                    fourthItemRequirementA.image = playerReference.sciencesImprovementLevel > -2 ? UIImage(named: "PAPER_REQ") : nil
                    fourthItemRequirementB.image = playerReference.sciencesImprovementLevel > -1 ? UIImage(named: "PAPER_REQ") : nil
                    fourthItemRequirementC.image = playerReference.sciencesImprovementLevel > +0 ? UIImage(named: "PAPER_REQ") : nil
                    fourthItemRequirementD.image = playerReference.sciencesImprovementLevel > +1 ? UIImage(named: "PAPER_REQ") : nil
                    fourthItemRequirementE.image = playerReference.sciencesImprovementLevel > +2 ? UIImage(named: "PAPER_REQ") : nil
                    if playerReference.paper < playerReference.sciencesImprovementLevel + 2 || (playerReference.paper < playerReference.sciencesImprovementLevel + 1 && playerReference.progressCards.contains(.Crane)) { fourthItemButton.isEnabled = false } else { fourthItemButton.isEnabled = true }
                }
            case 2:
                firstImprovement.image = UIImage.init(named: "TRADES_1")
                if playerReference.tradesImprovementLevel < 0 { firstImprovement.alpha = 0.4 } else { firstImprovement.alpha = 1.0 }
                secondImprovement.image = UIImage.init(named: "TRADES_2")
                if playerReference.tradesImprovementLevel < 1 { secondImprovement.alpha = 0.4 } else { secondImprovement.alpha = 1.0 }
                thirdImprovement.image = UIImage.init(named: "TRADES_3")
                if playerReference.tradesImprovementLevel < 2 { thirdImprovement.alpha = 0.4 } else { thirdImprovement.alpha = 1.0 }
                fourthImprovement.image = UIImage.init(named: "TRADES_4")
                if playerReference.tradesImprovementLevel < 3 { fourthImprovement.alpha = 0.4 } else { fourthImprovement.alpha = 1.0 }
                lastImprovement.image = UIImage.init(named: "TRADES_5")
                if playerReference.tradesImprovementLevel < 4 { lastImprovement.alpha = 0.4 } else { lastImprovement.alpha = 1.0 }
                firstItemButton.setTitle("BUILD ROAD", for: UIControlState.normal)
                firstItemButton.setTitle("BUILD ROAD", for: UIControlState.disabled)
                firstItemRequirementA.image = UIImage(named: "BRICK_REQ")
                firstItemRequirementB.image = UIImage(named: "WOOD_REQ")
                firstItemRequirementC.image = nil
                firstItemRequirementD.image = nil
                firstItemRequirementE.image = nil
                if playerReference.wood < 1 || playerReference.brick < 1 { firstItemButton.isEnabled = false } else { firstItemButton.isEnabled = true }
                secondItemButton.setTitle("BUILD SHIP", for: UIControlState.normal)
                secondItemButton.setTitle("BUILD SHIP", for: UIControlState.disabled)
                secondItemRequirementA.image = UIImage(named: "SHEEP_REQ")
                secondItemRequirementB.image = UIImage(named: "WOOD_REQ")
                secondItemRequirementC.image = nil
                secondItemRequirementD.image = nil
                secondItemRequirementE.image = nil
                if playerReference.wood < 1 || playerReference.sheep < 1 { secondItemButton.isEnabled = false } else { secondItemButton.isEnabled = true }
                thirdItemButton.setTitle("BUILD SETTLEMENT", for: UIControlState.normal)
                thirdItemButton.setTitle("BUILD SETTLEMENT", for: UIControlState.disabled)
                thirdItemRequirementA.image = UIImage(named: "SHEEP_REQ")
                thirdItemRequirementB.image = UIImage(named: "WHEAT_REQ")
                thirdItemRequirementC.image = UIImage(named: "BRICK_REQ")
                thirdItemRequirementD.image = UIImage(named: "WOOD_REQ")
                thirdItemRequirementE.image = nil
                if playerReference.wood < 1 || playerReference.sheep < 1 || playerReference.brick < 1 || playerReference.wheat < 1 { thirdItemButton.isEnabled = false } else { thirdItemButton.isEnabled = true }
                if playerReference.tradesImprovementLevel == 4 {
                    fourthItemButton.setTitle("", for: UIControlState.normal)
                    fourthItemButton.setTitle("", for: UIControlState.disabled)
                    fourthItemRequirementA.image = nil
                    fourthItemRequirementB.image = nil
                    fourthItemRequirementC.image = nil
                    fourthItemRequirementD.image = nil
                    fourthItemRequirementE.image = nil
                    fourthItemButton.isEnabled = false
                } else {
                    fourthItemButton.setTitle("UPGRADE TO " + ChartTypes.getImprovementDescription(playerReference.tradesImprovementLevel + 1, chart: ChartTypes.init(rawValue: 2)!), for: UIControlState.normal)
                    fourthItemButton.setTitle("UPGRADE TO " + ChartTypes.getImprovementDescription(playerReference.tradesImprovementLevel + 1, chart: ChartTypes.init(rawValue: 2)!), for: UIControlState.disabled)
                    fourthItemRequirementA.image = playerReference.tradesImprovementLevel > -2 ? UIImage(named: "CLOTH_REQ") : nil
                    fourthItemRequirementB.image = playerReference.tradesImprovementLevel > -1 ? UIImage(named: "CLOTH_REQ") : nil
                    fourthItemRequirementC.image = playerReference.tradesImprovementLevel > +0 ? UIImage(named: "CLOTH_REQ") : nil
                    fourthItemRequirementD.image = playerReference.tradesImprovementLevel > +1 ? UIImage(named: "CLOTH_REQ") : nil
                    fourthItemRequirementE.image = playerReference.tradesImprovementLevel > +2 ? UIImage(named: "CLOTH_REQ") : nil
                    if playerReference.cloth < playerReference.tradesImprovementLevel + 2 || (playerReference.cloth < playerReference.tradesImprovementLevel + 1 && playerReference.progressCards.contains(.Crane)) { fourthItemButton.isEnabled = false } else { fourthItemButton.isEnabled = true }
                }
            default: break;
        }
    }
    
    @IBAction func buildItemA(_ sender: Any) {
        let playerReference = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        switch chartsSceneIndex {
            case 0: playerReference.nextAction = .WillBuildCity
            case 1: playerReference.nextAction = .WillBuildKnight
            case 2: playerReference.nextAction = .WillBuildRoad
            default: break;
        }
        self.tabBarController?.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buildItemB(_ sender: Any) {
        let playerReference = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        switch chartsSceneIndex {
            case 0: playerReference.nextAction = .WillBuildWall
            case 1: playerReference.nextAction = .WillPromoteKnight
            case 2: playerReference.nextAction = .WillBuildShip
            default: break;
        }
        self.tabBarController?.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buildItemC(_ sender: Any) {
        let playerReference = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        switch chartsSceneIndex {
            case 1: playerReference.nextAction = .WillActivateKnight
            case 2: playerReference.nextAction = .WillBuildSettlement
            default: break;
        }
        self.tabBarController?.navigationController?.popViewController(animated: true)
    }
    
    //  DO METROPOLIS CHECKS
    
    @IBAction func improveCurrentChart(_ sender: Any) {
        let playerReference = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        if playerReference.progressCards.contains(.Crane) {
            let announcement = "Looks like you have The Crane card...would you like to use it?"
            let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
                self.continueImprovingCharts(self.chartsSceneIndex, offset: 1)
                for index in 0..<playerReference.progressCards.count {
                    if playerReference.progressCards[index] == .Crane {
                        playerReference.progressCards.remove(at: index)
                        break
                }   }
            }))
            alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action) in
                switch self.chartsSceneIndex {
                    case 0: playerReference.coin < playerReference.politicsImprovementLevel + 2 ? self.blockImprovement() : self.continueImprovingCharts(self.chartsSceneIndex, offset: 0)
                    case 1: playerReference.paper < playerReference.sciencesImprovementLevel + 2 ? self.blockImprovement() : self.continueImprovingCharts(self.chartsSceneIndex, offset: 0)
                    case 2: playerReference.cloth < playerReference.tradesImprovementLevel + 2 ? self.blockImprovement() : self.continueImprovingCharts(self.chartsSceneIndex, offset: 0)
                    default: break
                }
            }))
            self.present(alert, animated: true, completion: nil)
        } else { continueImprovingCharts(chartsSceneIndex, offset: 0) }
        drawCurrentChartScene()
    }
    
    func blockImprovement() {
        
    }
    
    func continueImprovingCharts(_ index: Int, offset: Int) {
        let playerReference = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        switch index {
            case 0:
                playerReference.coin -= playerReference.politicsImprovementLevel + 2 - offset
                playerReference.politicsImprovementLevel += 1
                //  TO WORK ON: IF PLAYER DOES NOT HAVE CITY TO PLACE METROPOLIS ON OR DOES NOT WANT TO, INSERT A BUTTON THAT ALLOWS PLAYER TO DO SO IN SUBSEQUENT TIME
                if playerReference.politicsImprovementLevel == 3 && !gameDataReference.scenePort.politicsMetropolisPlaced {
                    //  CHECK IF PLAYER HAS A CITY WITH NO METROPOLIS FOR WHICH HE OR SHE CAN PLACE A METROPOLIS ON
                    //  SET .WillBuildMetropolis TO nextAction PROPERTY OF PLAYER AND HANDLE BUILD IN handleButtonTouches(...)
                    //  SET gameDataReference.scenePort.politicsMetropolisPlaced TO TRUE
                    //  SET PLAYER PROPERTY holdsPoliticsMetropolis TO TRUE
                }
                if playerReference.politicsImprovementLevel == 4 && !gameDataReference.scenePort.maximaPoliticsImprovementReached && !playerReference.holdsPoliticsMetropolis {
                    //  CHECK IF PLAYER HAS A CITY WITH NO METROPOLIS FOR WHICH HE OR SHE CAN PLACE A METROPOLIS ON
                    //  SET .WillBuildMetropolis TO nextAction PROPERTY OF PLAYER AND HANDLE BUILD IN handleButtonTouches(...)
                    //  SET gameDataReference.scenePort.maximaPoliticsImprovementReached and gameDataReference.scenePort.politicsMetropolisPlaced TO TRUE
                    //  FOR EACH PLAYER CHECK WHETHER holdsPoliticsMetropolis IS TRUE
                    //  IF IT IS TRUE THEN CALL willLoseMetropolisFor(.Politics) ON THAT PLAYER (NOT YET IMPLEMENTED) WHICH WILL ALSO SET holdsPoliticsMetropolis TO FALSE
                    //  SET PLAYER PROPERTY holdsPoliticsMetropolis TO TRUE
                }
            case 1:
                playerReference.paper -= playerReference.sciencesImprovementLevel + 2 - offset
                playerReference.sciencesImprovementLevel += 1
                //  TO WORK ON: IF PLAYER DOES NOT HAVE CITY TO PLACE METROPOLIS ON OR DOES NOT WANT TO, INSERT A BUTTON THAT ALLOWS PLAYER TO DO SO IN SUBSEQUENT TIME
                if playerReference.sciencesImprovementLevel == 3 && !gameDataReference.scenePort.sciencesMetropolisPlaced {
                    //  CHECK IF PLAYER HAS A CITY WITH NO METROPOLIS FOR WHICH HE OR SHE CAN PLACE A METROPOLIS ON
                    //  SET .WillBuildMetropolis TO nextAction PROPERTY OF PLAYER AND HANDLE BUILD IN handleButtonTouches(...)
                    //  SET gameDataReference.scenePort.politicsMetropolisPlaced TO TRUE
                    //  SET PLAYER PROPERTY holdsPoliticsMetropolis TO TRUE
                }
                if playerReference.sciencesImprovementLevel == 4 && !gameDataReference.scenePort.maximaSciencesImprovementReached && !playerReference.holdsSciencesMetropolis {
                    //  CHECK IF PLAYER HAS A CITY WITH NO METROPOLIS FOR WHICH HE OR SHE CAN PLACE A METROPOLIS ON
                    //  SET .WillBuildMetropolis TO nextAction PROPERTY OF PLAYER AND HANDLE BUILD IN handleButtonTouches(...)
                    //  SET gameDataReference.scenePort.maximaPoliticsImprovementReached and gameDataReference.scenePort.politicsMetropolisPlaced TO TRUE
                    //  FOR EACH PLAYER CHECK WHETHER holdsPoliticsMetropolis IS TRUE
                    //  IF IT IS TRUE THEN CALL willLoseMetropolisFor(.Politics) ON THAT PLAYER (NOT YET IMPLEMENTED) WHICH WILL ALSO SET holdsPoliticsMetropolis TO FALSE
                    //  SET PLAYER PROPERTY holdsPoliticsMetropolis TO TRUE
                }
            case 2:
                playerReference.cloth -= playerReference.tradesImprovementLevel + 2 - offset
                playerReference.tradesImprovementLevel += 1
                //  TO WORK ON: IF PLAYER DOES NOT HAVE CITY TO PLACE METROPOLIS ON OR DOES NOT WANT TO, INSERT A BUTTON THAT ALLOWS PLAYER TO DO SO IN SUBSEQUENT TIME
                if playerReference.tradesImprovementLevel == 3 && !gameDataReference.scenePort.tradesMetropolisPlaced {
                    //  CHECK IF PLAYER HAS A CITY WITH NO METROPOLIS FOR WHICH HE OR SHE CAN PLACE A METROPOLIS ON
                    //  SET .WillBuildMetropolis TO nextAction PROPERTY OF PLAYER AND HANDLE BUILD IN handleButtonTouches(...)
                    //  SET gameDataReference.scenePort.politicsMetropolisPlaced TO TRUE
                    //  SET PLAYER PROPERTY holdsPoliticsMetropolis TO TRUE
                }
                if playerReference.tradesImprovementLevel == 4 && !gameDataReference.scenePort.maximaTradesImprovementReached && !playerReference.holdsTradesMetropolis {
                    //  CHECK IF PLAYER HAS A CITY WITH NO METROPOLIS FOR WHICH HE OR SHE CAN PLACE A METROPOLIS ON
                    //  SET .WillBuildMetropolis TO nextAction PROPERTY OF PLAYER AND HANDLE BUILD IN handleButtonTouches(...)
                    //  SET gameDataReference.scenePort.maximaPoliticsImprovementReached and gameDataReference.scenePort.politicsMetropolisPlaced TO TRUE
                    //  FOR EACH PLAYER CHECK WHETHER holdsPoliticsMetropolis IS TRUE
                    //  IF IT IS TRUE THEN CALL willLoseMetropolisFor(.Politics) ON THAT PLAYER (NOT YET IMPLEMENTED) WHICH WILL ALSO SET holdsPoliticsMetropolis TO FALSE
                    //  SET PLAYER PROPERTY holdsPoliticsMetropolis TO TRUE
                }
                if playerReference.tradesImprovementLevel >= 2 {
                    playerReference.coinTradeRatio = 2
                    playerReference.paperTradeRatio = 2
                    playerReference.clothTradeRatio = 2
                }
            default: break
    }   }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
