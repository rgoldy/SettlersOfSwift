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
    case Wood = "WOOL"
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
    @IBOutlet weak var targetBrick: UIButton!
    @IBOutlet weak var targetGold: UIButton!
    @IBOutlet weak var targetSheep: UIButton!
    @IBOutlet weak var targetStone: UIButton!
    @IBOutlet weak var targetWheat: UIButton!
    @IBOutlet weak var targetWood: UIButton!
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateOptions()
        segmentSelector.selectedSegmentIndex = 0
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
                    case .Brick: myPlayerIndex.brick -= myPlayerIndex.brickTradeRatio
                    case .Gold: myPlayerIndex.gold -= myPlayerIndex.goldTradeRatio
                    case .Sheep: myPlayerIndex.sheep -= myPlayerIndex.sheepTradeRatio
                    case.Stone: myPlayerIndex.stone -= myPlayerIndex.stoneTradeRatio
                    case .Wheat: myPlayerIndex.wheat -= myPlayerIndex.wheatTradeRatio
                    case .Wood: myPlayerIndex.wood -= myPlayerIndex.woodTradeRatio
                    case .None: break;
                }
                switch selectedTarget {
                case .Brick: myPlayerIndex.brick += 1
                case .Gold: myPlayerIndex.gold += 1
                case .Sheep: myPlayerIndex.sheep += 1
                case.Stone: myPlayerIndex.stone += 1
                case .Wheat: myPlayerIndex.wheat += 1
                case .Wood: myPlayerIndex.wood += 1
                case .None: break;
            }   }
        } else {
            if selectedSource != .None, selectedTarget != .None {
                let requestDefinition = "Some player would like to exchange \(currentRatio) \(selectedSource.rawValue) for 1 \(selectedTarget.rawValue)...would you like to proceed with the trade?"
                if sendRequest(requestDefinition) {
                    let otherPlayer: Player
                    if segmentSelector.selectedSegmentIndex == 1 {
                        otherPlayer = gameDataReference.scenePort.players[(gameDataReference.scenePort.myPlayerIndex + 1) % 3]
                    } else {
                        otherPlayer = gameDataReference.scenePort.players[(gameDataReference.scenePort.myPlayerIndex + 2) % 3]
                    }
                    switch selectedSource {
                        case .Brick:
                            myPlayerIndex.brick -= currentRatio
                            otherPlayer.brick += currentRatio
                        case .Gold:
                            myPlayerIndex.gold -= currentRatio
                            otherPlayer.gold += currentRatio
                        case .Sheep:
                            myPlayerIndex.sheep -= currentRatio
                            otherPlayer.sheep += currentRatio
                        case.Stone:
                            myPlayerIndex.stone -= currentRatio
                            otherPlayer.stone += currentRatio
                        case .Wheat:
                            myPlayerIndex.wheat -= currentRatio
                            otherPlayer.wheat += currentRatio
                        case .Wood:
                            myPlayerIndex.wood -= currentRatio
                            otherPlayer.wood += currentRatio
                        case .None: break;
                    }
                    switch selectedTarget {
                        case .Brick:
                            myPlayerIndex.brick += 1
                            otherPlayer.brick -= 1
                        case .Gold:
                            myPlayerIndex.gold += 1
                            otherPlayer.gold -= 1
                        case .Sheep:
                            myPlayerIndex.sheep += 1
                            otherPlayer.sheep -= 1
                        case.Stone:
                            myPlayerIndex.stone += 1
                            otherPlayer.stone -= 1
                        case .Wheat:
                            myPlayerIndex.wheat += 1
                            otherPlayer.wheat -= 1
                        case .Wood:
                            myPlayerIndex.wood += 1
                            otherPlayer.wood -= 1
                        case .None: break;
                    }
                    let alert = UIAlertController(title: "Trade Notification", message: "The other player has accepted your request for a trade...", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Trade Notification", message: "The other player has declined your request for a trade...", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        }   }
        updateOptions()
    }
    
    //  OTHER PLAYER SHOULD RECEIVE AN ALERT BOX WITH TRADE SPECIFICATIONS
    //  MAY ACCEPT OR DECLINE
    
    func sendRequest(_ definition: String) -> Bool { return true }  //  NOT IMPLEMENTED, BLOCKING
    
    @IBAction func selectedSourceAsBrick(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceBrick.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Brick
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].brickTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsGold(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceGold.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Gold
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].goldTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsSheep(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceSheep.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Sheep
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].sheepTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsStone(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceStone.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Stone
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].stoneTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsWheat(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceWheat.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Wheat
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].wheatTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedSourceAsWood(_ sender: Any) {
        let buttonsCollection = [sourceBrick, sourceGold, sourceSheep, sourceStone, sourceWheat, sourceWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        sourceWood.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedSource = .Wood
        if segmentSelector.selectedSegmentIndex == 0 { ratioSelector.setTitle("\(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].woodTradeRatio) : 1", for: UIControlState.disabled) }
    }
    
    @IBAction func selectedTargetAsBrick(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetBrick.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Brick
    }
    
    @IBAction func selectedTargetAsGold(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetGold.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Gold
    }
    
    @IBAction func selectedTargetAsSheep(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetSheep.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Sheep
    }
    
    @IBAction func selectedTargetAsStone(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetStone.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Stone
    }
    
    @IBAction func selectedTargetAsWheat(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetWheat.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Wheat
    }
    
    @IBAction func selectedTargetAsWood(_ sender: Any) {
        let buttonsCollection = [targetBrick, targetGold, targetSheep, targetStone, targetWheat, targetWood]
        for item in buttonsCollection { item?.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        targetWood.setTitleColor(UIColor.orange, for: UIControlState.normal)
        selectedTarget = .Wood
    }
    
    func updateOptions() {
        selectedSource = .None
        selectedTarget = .None
        let buttonsCollection: [UIButton] = [sourceBrick, targetBrick,
                                              sourceGold, targetGold,
                                             sourceSheep, targetSheep,
                                             sourceStone, targetStone,
                                             sourceWheat, targetWheat,
                                              sourceWood, targetWood]
        for item in buttonsCollection { item.setTitleColor(UIColor.blue, for: UIControlState.normal) }
        let myPlayerIndex = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        if segmentSelector.selectedSegmentIndex == 0 {
            if myPlayerIndex.brick < myPlayerIndex.brickTradeRatio { sourceBrick.isEnabled = false } else { sourceBrick.isEnabled = true }
            if myPlayerIndex.gold < myPlayerIndex.goldTradeRatio { sourceGold.isEnabled = false } else { sourceGold.isEnabled = true }
            if myPlayerIndex.sheep < myPlayerIndex.sheepTradeRatio { sourceSheep.isEnabled = false } else { sourceSheep.isEnabled = true }
            if myPlayerIndex.stone < myPlayerIndex.stoneTradeRatio { sourceStone.isEnabled = false } else { sourceStone.isEnabled = true }
            if myPlayerIndex.wheat < myPlayerIndex.wheatTradeRatio { sourceWheat.isEnabled = false } else { sourceWheat.isEnabled = true }
            if myPlayerIndex.wood < myPlayerIndex.woodTradeRatio { sourceWood.isEnabled = false } else { sourceWood.isEnabled = true }
            ratioSelector.setTitle("* : 1", for: UIControlState.disabled)
            ratioSelector.isEnabled = false
        } else {
            ratioSelector.setTitle("\(currentRatio) : 1", for: UIControlState.normal)
            ratioSelector.isEnabled = true
            let otherPlayer: Player
            if segmentSelector.selectedSegmentIndex == 1 {
                otherPlayer = gameDataReference.scenePort.players[(gameDataReference.scenePort.myPlayerIndex + 1) % 3]
            } else {
                otherPlayer = gameDataReference.scenePort.players[(gameDataReference.scenePort.myPlayerIndex + 2) % 3]
            }
            if myPlayerIndex.brick < currentRatio { sourceBrick.isEnabled = false } else { sourceBrick.isEnabled = true }
            if myPlayerIndex.gold < currentRatio { sourceGold.isEnabled = false } else { sourceGold.isEnabled = true }
            if myPlayerIndex.sheep < currentRatio { sourceSheep.isEnabled = false } else { sourceSheep.isEnabled = true }
            if myPlayerIndex.stone < currentRatio { sourceStone.isEnabled = false } else { sourceStone.isEnabled = true }
            if myPlayerIndex.wheat < currentRatio { sourceWheat.isEnabled = false } else { sourceWheat.isEnabled = true }
            if myPlayerIndex.wood < currentRatio { sourceWood.isEnabled = false } else { sourceWood.isEnabled = true }
            if otherPlayer.brick == 0 { targetBrick.isEnabled = false } else { targetBrick.isEnabled = true }
            if otherPlayer.gold == 0 { targetGold.isEnabled = false } else { targetGold.isEnabled = true }
            if otherPlayer.sheep == 0 { targetSheep.isEnabled = false } else { targetSheep.isEnabled = true }
            if otherPlayer.stone == 0 { targetStone.isEnabled = false } else { targetStone.isEnabled = true }
            if otherPlayer.wheat == 0 { targetWheat.isEnabled = false } else { targetWheat.isEnabled = true }
            if otherPlayer.wood == 0 { targetWood.isEnabled = false } else { targetWood.isEnabled = true }
    }   }
    
    @IBAction func didChangeSegment(_ sender: Any) {
        currentRatio = 1
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
