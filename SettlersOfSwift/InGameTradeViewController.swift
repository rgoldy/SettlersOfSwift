//
//  InGameTradeViewController.swift
//  SettlersOfSwift
//
//  Created by YIFFY on 3/31/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

enum SelectedItem: String {
    case None = ""
    case Brick = "BRICK"
    case Gold = "GOLD"
    case Sheep = "SHEEP"
    case Stone = "STONE"
    case Wheat = "WHEAT"
    case Wood = "WOOD"
    case Coin = "COIN"
    case Paper = "PAPER"
    case Cloth = "CLOTH"
}

class InGameTradeViewController: UIViewController {

    @IBOutlet weak var segmentSelector: UISegmentedControl!
    
    @IBOutlet weak var ratioSelector: UIButton!
    
    @IBOutlet weak var sourceBrick: UIButton!
    @IBOutlet weak var sourceGold: UIButton!
    @IBOutlet weak var sourceSheep: UIButton!
    @IBOutlet weak var sourceStone: UIButton!
    @IBOutlet weak var sourceWheat: UIButton!
    @IBOutlet weak var sourceWood: UIButton!
    @IBOutlet weak var sourceCoin: UIButton!
    @IBOutlet weak var sourcePaper: UIButton!
    @IBOutlet weak var sourceCloth: UIButton!
    @IBOutlet weak var targetBrick: UIButton!
    @IBOutlet weak var targetGold: UIButton!
    @IBOutlet weak var targetSheep: UIButton!
    @IBOutlet weak var targetStone: UIButton!
    @IBOutlet weak var targetWheat: UIButton!
    @IBOutlet weak var targetWood: UIButton!
    @IBOutlet weak var targetCoin: UIButton!
    @IBOutlet weak var targetPaper: UIButton!
    @IBOutlet weak var targetCloth: UIButton!
    
    @IBOutlet weak var performTrade: UIButton!
    
    var selectedSource = SelectedItem.None
    var selectedTarget = SelectedItem.None
    
    var gameDataReference: GameViewController!
    
    var currentRatio = 1
        
    override func viewDidLoad() {
        super.viewDidLoad()
        //  MIGHT HAVE TO MODIFY BELOW CODE TO viewWillAppear(Bool) METHOD TO BE COMPATIBLE WITH SAVE LOADING
        gameDataReference = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! GameViewController
        // Do any additional setup after loading the view.
        
        var previousPlayer = gameDataReference.scenePort.myPlayerIndex - 1
        if previousPlayer < 0 {previousPlayer = gameDataReference.scenePort.players.count - 1}
        let nextPlayer = (gameDataReference.scenePort.myPlayerIndex + 1) % gameDataReference.scenePort.players.count
        
        let previousColor = gameDataReference.scenePort.players[previousPlayer].color.rawValue
        let nextColor = gameDataReference.scenePort.players[nextPlayer].color.rawValue

        segmentSelector.setTitle("\(previousColor) Player", forSegmentAt: 1)
        segmentSelector.setTitle("\(nextColor) Player", forSegmentAt: 2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "menuBackground")!)
        segmentSelector.selectedSegmentIndex = 0
        updateOptions()
        ratioSelector.setTitle("* : 1", for: UIControlState.disabled)
        ratioSelector.isEnabled = false
    }
    
    @IBAction func didChangeRatio(_ sender: Any) {
        currentRatio += 1
        if currentRatio > 4 { currentRatio = 1 }
        updateOptions()
    }
    
    @IBAction func performTrade(_ sender: Any) {
        let myPlayerIndex = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        if segmentSelector.selectedSegmentIndex == 0 {
            if selectedSource != .None, selectedTarget != .None {
                switch selectedSource {
                    case .Brick: myPlayerIndex.brick -= myPlayerIndex.merchantFleetSelect == .Brick ? 2 : myPlayerIndex.brickTradeRatio
                    case .Gold: myPlayerIndex.gold -= myPlayerIndex.merchantFleetSelect == .Gold ? 2 : myPlayerIndex.goldTradeRatio
                    case .Sheep: myPlayerIndex.sheep -= myPlayerIndex.merchantFleetSelect == .Sheep ? 2 : myPlayerIndex.sheepTradeRatio
                    case.Stone: myPlayerIndex.stone -= myPlayerIndex.merchantFleetSelect == .Stone ? 2 : myPlayerIndex.stoneTradeRatio
                    case .Wheat: myPlayerIndex.wheat -= myPlayerIndex.merchantFleetSelect == .Wheat ? 2 : myPlayerIndex.wheatTradeRatio
                    case .Wood: myPlayerIndex.wood -= myPlayerIndex.merchantFleetSelect == .Wood ? 2 : myPlayerIndex.woodTradeRatio
                    case .Coin: myPlayerIndex.coin -= myPlayerIndex.merchantFleetSelect == .Coin ? 2 : myPlayerIndex.coinTradeRatio
                    case .Paper: myPlayerIndex.paper -= myPlayerIndex.merchantFleetSelect == .Paper ? 2 : myPlayerIndex.paperTradeRatio
                    case .Cloth: myPlayerIndex.cloth -= myPlayerIndex.merchantFleetSelect == .Cloth ? 2 : myPlayerIndex.clothTradeRatio
                    case .None: break;
                }
                switch selectedTarget {
                    case .Brick: myPlayerIndex.brick += 1
                    case .Gold: myPlayerIndex.gold += 1
                    case .Sheep: myPlayerIndex.sheep += 1
                    case.Stone: myPlayerIndex.stone += 1
                    case .Wheat: myPlayerIndex.wheat += 1
                    case .Wood: myPlayerIndex.wood += 1
                    case .Coin: myPlayerIndex.coin += 1
                    case .Paper: myPlayerIndex.paper += 1
                    case .Cloth: myPlayerIndex.cloth += 1
                    case .None: break;
                }
            } else {
                let alert = UIAlertController(title: "Alert", message: "Please pick a source and a target resource prior to performing trade...", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            if selectedSource != .None, selectedTarget != .None {
                let myIndex = gameDataReference.scenePort.myPlayerIndex
                let otherPlayerIndex = (gameDataReference.scenePort.myPlayerIndex + (segmentSelector.selectedSegmentIndex == 1 ? 2 : 1)) % 3
                myPlayerIndex.tradeAccepted = nil
                let message = "playerTradeRequest.\(otherPlayerIndex).\(myIndex).\(currentRatio).\(selectedSource.rawValue).\(selectedTarget.rawValue)"
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: message)
                let loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
                loadingView.color = UIColor.gray
                loadingView.startAnimating()
                self.view.addSubview(loadingView)
                while myPlayerIndex.tradeAccepted == nil { }
                loadingView.removeFromSuperview()
                if myPlayerIndex.tradeAccepted! {
                    let notificationBanner = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                    notificationBanner.isOpaque = false
                    notificationBanner.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.6)
                    let notificationContent = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                    notificationContent.isOpaque = false
                    notificationContent.font = UIFont(name: "Avenir-Roman", size: 14)
                    notificationContent.textColor = UIColor.lightGray
                    notificationContent.textAlignment = .center
                    notificationContent.text = "The other player has accepted your request for a trade!"
                    self.view?.addSubview(notificationBanner)
                    self.view?.addSubview(notificationContent)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        notificationContent.removeFromSuperview()
                        notificationBanner.removeFromSuperview()
                    })
                    switch selectedSource {
                        case .Brick: myPlayerIndex.brick -= currentRatio
                        case .Gold: myPlayerIndex.gold -= currentRatio
                        case .Sheep: myPlayerIndex.sheep -= currentRatio
                        case.Stone: myPlayerIndex.stone -= currentRatio
                        case .Wheat: myPlayerIndex.wheat -= currentRatio
                        case .Wood: myPlayerIndex.wood -= currentRatio
                        case .Coin: myPlayerIndex.coin -= currentRatio
                        case .Paper: myPlayerIndex.paper -= currentRatio
                        case .Cloth: myPlayerIndex.cloth -= currentRatio
                        case .None: break;
                    }
                    switch selectedTarget {
                        case .Brick: myPlayerIndex.brick += 1
                        case .Gold: myPlayerIndex.gold += 1
                        case .Sheep: myPlayerIndex.sheep += 1
                        case.Stone: myPlayerIndex.stone += 1
                        case .Wheat: myPlayerIndex.wheat += 1
                        case .Wood: myPlayerIndex.wood += 1
                        case .Coin: myPlayerIndex.coin += 1
                        case .Paper: myPlayerIndex.paper += 1
                        case .Cloth: myPlayerIndex.cloth += 1
                        case .None: break;
                    }
                } else {
                    let notificationBanner = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                    notificationBanner.isOpaque = false
                    notificationBanner.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.6)
                    let notificationContent = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                    notificationContent.isOpaque = false
                    notificationContent.font = UIFont(name: "Avenir-Roman", size: 14)
                    notificationContent.textColor = UIColor.lightGray
                    notificationContent.textAlignment = .center
                    notificationContent.text = "The other player has refused your request for a trade..."
                    self.view?.addSubview(notificationBanner)
                    self.view?.addSubview(notificationContent)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        notificationContent.removeFromSuperview()
                        notificationBanner.removeFromSuperview()
                    })
        }   }   }
        didChangeRatio(self)
    }
    
    @IBAction func selectedSourceAsBrick(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood, sourceCoin, sourcePaper, sourceCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceBrick.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Brick
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect == .Brick ? 2 : gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].brickTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsGold(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood, sourceCoin, sourcePaper, sourceCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceGold.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Gold
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect == .Gold ? 2 : gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].goldTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsSheep(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood, sourceCoin, sourcePaper, sourceCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceSheep.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Sheep
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect == .Sheep ? 2 : gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].sheepTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsStone(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood, sourceCoin, sourcePaper, sourceCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceStone.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Stone
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect == .Stone ? 2 : gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].stoneTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsWheat(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood, sourceCoin, sourcePaper, sourceCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceWheat.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Wheat
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect == .Wheat ? 2 : gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].wheatTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsWood(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood, sourceCoin, sourcePaper, sourceCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceWood.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Wood
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect == .Wood ? 2 : gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].woodTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsCoin(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood, sourceCoin, sourcePaper, sourceCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceCoin.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Coin
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect == .Coin ? 2 : gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].coinTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsPaper(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood, sourceCoin, sourcePaper, sourceCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourcePaper.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Paper
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect == .Paper ? 2 : gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].paperTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsCloth(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood, sourceCoin, sourcePaper, sourceCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceCloth.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Cloth
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect == .Cloth ? 2 : gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].clothTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedTargetAsBrick(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood, targetCoin, targetPaper, targetCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetBrick.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Brick
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
    }
    
    @IBAction func selectedTargetAsGold(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood, targetCoin, targetPaper, targetCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetGold.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Gold
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
    }
    
    @IBAction func selectedTargetAsSheep(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood, targetCoin, targetPaper, targetCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetSheep.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Sheep
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
    }
    
    @IBAction func selectedTargetAsStone(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood, targetCoin, targetPaper, targetCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetStone.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Stone
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
    }
    
    @IBAction func selectedTargetAsWheat(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood, targetCoin, targetPaper, targetCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetWheat.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Wheat
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
    }
    
    @IBAction func selectedTargetAsWood(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood, targetCoin, targetPaper, targetCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetWood.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Wood
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
    }
    
    @IBAction func selectedTargetAsCoin(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood, targetCoin, targetPaper, targetCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetCoin.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Coin
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
    }
    
    @IBAction func selectedTargetAsPaper(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood, targetCoin, targetPaper, targetCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetPaper.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Paper
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
    }
    
    @IBAction func selectedTargetAsCloth(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood, targetCoin, targetPaper, targetCloth]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetCloth.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Cloth
        performTrade.isEnabled = selectedSource != .None && selectedTarget != .None
    }
    
    func updateOptions() {
        selectedSource = .None
        selectedTarget = .None
        performTrade.setTitleColor(UIColor.blue, for: UIControlState.normal)
        performTrade.isEnabled = false
        let buttonsCollection: [UIButton] = [sourceBrick, targetBrick,
                                              sourceGold, targetGold,
                                             sourceSheep, targetSheep,
                                             sourceStone, targetStone,
                                             sourceWheat, targetWheat,
                                              sourceWood, targetWood,
                                              sourceCoin, targetCoin,
                                             sourcePaper, targetPaper,
                                             sourceCloth, targetCloth]
        for item in buttonsCollection { item.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        let myPlayerIndex = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        if segmentSelector.selectedSegmentIndex == 0 {
            if myPlayerIndex.brick < (myPlayerIndex.merchantFleetSelect == .Brick ? 2 : myPlayerIndex.brickTradeRatio) { sourceBrick.isEnabled = false } else { sourceBrick.isEnabled = true }
            if myPlayerIndex.gold < (myPlayerIndex.merchantFleetSelect == .Gold ? 2 : myPlayerIndex.goldTradeRatio) { sourceGold.isEnabled = false } else { sourceGold.isEnabled = true }
            if myPlayerIndex.sheep < (myPlayerIndex.merchantFleetSelect == .Sheep ? 2 : myPlayerIndex.sheepTradeRatio) { sourceSheep.isEnabled = false } else { sourceSheep.isEnabled = true }
            if myPlayerIndex.stone < (myPlayerIndex.merchantFleetSelect == .Stone ? 2 : myPlayerIndex.stoneTradeRatio) { sourceStone.isEnabled = false } else { sourceStone.isEnabled = true }
            if myPlayerIndex.wheat < (myPlayerIndex.merchantFleetSelect == .Wheat ? 2 : myPlayerIndex.wheatTradeRatio) { sourceWheat.isEnabled = false } else { sourceWheat.isEnabled = true }
            if myPlayerIndex.wood < (myPlayerIndex.merchantFleetSelect == .Wood ? 2 : myPlayerIndex.woodTradeRatio) { sourceWood.isEnabled = false } else { sourceWood.isEnabled = true }
            if myPlayerIndex.coin < (myPlayerIndex.merchantFleetSelect == .Coin ? 2 : myPlayerIndex.coinTradeRatio) { sourceCoin.isEnabled = false } else { sourceCoin.isEnabled = true }
            if myPlayerIndex.paper < (myPlayerIndex.merchantFleetSelect == .Paper ? 2 : myPlayerIndex.paperTradeRatio) { sourcePaper.isEnabled = false } else { sourcePaper.isEnabled = true }
            if myPlayerIndex.cloth < (myPlayerIndex.merchantFleetSelect == .Cloth ? 2 : myPlayerIndex.clothTradeRatio) { sourceCloth.isEnabled = false } else { sourceCloth.isEnabled = true }
            targetBrick.isEnabled = true
            targetGold.isEnabled = true
            targetSheep.isEnabled = true
            targetStone.isEnabled = true
            targetWheat.isEnabled = true
            targetWood.isEnabled = true
            targetCoin.isEnabled = true
            targetPaper.isEnabled = true
            targetCloth.isEnabled = true
            ratioSelector.setTitle("* : 1", for: UIControlState.disabled)
            ratioSelector.isEnabled = false
        } else {
            ratioSelector.setTitle("\(currentRatio) : 1", for: UIControlState.normal)
            ratioSelector.isEnabled = true
            let otherPlayer: Player
            if segmentSelector.selectedSegmentIndex == 1 {
                otherPlayer = gameDataReference.scenePort.players[(gameDataReference.scenePort.myPlayerIndex + 2) % 3]
            } else {
                otherPlayer = gameDataReference.scenePort.players[(gameDataReference.scenePort.myPlayerIndex + 1) % 3]
            }
            if myPlayerIndex.brick < currentRatio { sourceBrick.isEnabled = false } else { sourceBrick.isEnabled = true }
            if myPlayerIndex.gold < currentRatio { sourceGold.isEnabled = false } else { sourceGold.isEnabled = true }
            if myPlayerIndex.sheep < currentRatio { sourceSheep.isEnabled = false } else { sourceSheep.isEnabled = true }
            if myPlayerIndex.stone < currentRatio { sourceStone.isEnabled = false } else { sourceStone.isEnabled = true }
            if myPlayerIndex.wheat < currentRatio { sourceWheat.isEnabled = false } else { sourceWheat.isEnabled = true }
            if myPlayerIndex.wood < currentRatio { sourceWood.isEnabled = false } else { sourceWood.isEnabled = true }
            if myPlayerIndex.coin < currentRatio { sourceCoin.isEnabled = false } else { sourceCoin.isEnabled = true }
            if myPlayerIndex.paper < currentRatio { sourcePaper.isEnabled = false } else { sourcePaper.isEnabled = true }
            if myPlayerIndex.cloth < currentRatio { sourceCloth.isEnabled = false } else { sourceCloth.isEnabled = true }
            if otherPlayer.brick == 0 { targetBrick.isEnabled = false } else { targetBrick.isEnabled = true }
            if otherPlayer.gold == 0 { targetGold.isEnabled = false } else { targetGold.isEnabled = true }
            if otherPlayer.sheep == 0 { targetSheep.isEnabled = false } else { targetSheep.isEnabled = true }
            if otherPlayer.stone == 0 { targetStone.isEnabled = false } else { targetStone.isEnabled = true }
            if otherPlayer.wheat == 0 { targetWheat.isEnabled = false } else { targetWheat.isEnabled = true }
            if otherPlayer.wood == 0 { targetWood.isEnabled = false } else { targetWood.isEnabled = true }
            if otherPlayer.coin == 0 { targetCoin.isEnabled = false } else { targetCoin.isEnabled = true }
            if otherPlayer.paper == 0 { targetPaper.isEnabled = false } else { targetPaper.isEnabled = true }
            if otherPlayer.cloth == 0 { targetCloth.isEnabled = false } else { targetCloth.isEnabled = true }
    }   }
    
    @IBAction func didChangeSegment(_ sender: Any) {
        currentRatio = 1
        if segmentSelector.selectedSegmentIndex != 0 {
            let targetIndex = (gameDataReference.scenePort.myPlayerIndex + ((segmentSelector.selectedSegmentIndex == 1) ? 2 : 1)) % 3
            gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fetchedTargetData = false
            let message = "getTradeResources.\(targetIndex)"
            let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: message)
            let loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
            loadingView.color = UIColor.gray
            loadingView.startAnimating()
            self.view.addSubview(loadingView)
            while self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].fetchedTargetData == false { }
            loadingView.removeFromSuperview()
        }
        updateOptions()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
