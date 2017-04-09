//
//  InGameCardsDeckViewController.swift
//  SettlersOfSwift
//
//  Created by YIFFY on 3/31/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

class InGameCardsDeckViewController: UIViewController {

    @IBOutlet weak var firstCard: UIImageView!
    @IBOutlet weak var secondCard: UIImageView!
    @IBOutlet weak var thirdCard: UIImageView!
    
    var gameDataReference: GameViewController!
    
    var currentDisplayIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  MIGHT HAVE TO MODIFY BELOW CODE TO viewWillAppear(Bool) METHOD TO BE COMPATIBLE WITH SAVE LOADING
        gameDataReference = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! GameViewController
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "menuBackground")!)
        currentDisplayIndex = 0
        updateCardsDisplayWithStartingIndex(currentDisplayIndex)
    }

    func updateCardsDisplayWithStartingIndex(_ index: Int) {
        let player = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        if player.progressCards.count < 3 {
            switch player.progressCards.count {
                case 0:
                    firstCard.image = UIImage.init(named: "NoCard")
                    secondCard.image = UIImage.init(named: "NoCard")
                    thirdCard.image = UIImage.init(named: "NoCard")
                case 1:
                    firstCard.image = UIImage.init(named: "\(player.progressCards[0])")
                    secondCard.image = UIImage.init(named: "NoCard")
                    thirdCard.image = UIImage.init(named: "NoCard")
                case 2:
                    firstCard.image = UIImage.init(named: "\(player.progressCards[0])")
                    secondCard.image = UIImage.init(named: "\(player.progressCards[1])")
                    thirdCard.image = UIImage.init(named: "NoCard")
                default: break
            }
        } else {
            firstCard.image = UIImage.init(named: "\(player.progressCards[index % player.progressCards.count])")
            secondCard.image = UIImage.init(named: "\(player.progressCards[(index + 1) % player.progressCards.count])")
            thirdCard.image = UIImage.init(named: "\(player.progressCards[(index + 2) % player.progressCards.count])")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPreviousCards(_ sender: Any) {
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count <= 3 { updateCardsDisplayWithStartingIndex(0) }
        else {
            currentDisplayIndex += gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count - 1
            updateCardsDisplayWithStartingIndex(currentDisplayIndex)
    }   }
    
    @IBAction func showFollowingCards(_ sender: Any) {
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count <= 3 { updateCardsDisplayWithStartingIndex(0) }
        else {
            currentDisplayIndex += 1
            updateCardsDisplayWithStartingIndex(currentDisplayIndex)
    }   }
    
    @IBAction func didInteractWithLeftCard(_ sender: Any) {
        let cardIndex = currentDisplayIndex % gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count > cardIndex {
            tryUsingCard(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards[cardIndex])
    }   }
    
    @IBAction func didInteractWithMiddleCard(_ sender: Any) {
        let cardIndex = currentDisplayIndex % gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count > cardIndex {
            tryUsingCard(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards[cardIndex])
    }   }
    
    @IBAction func didInteractWithRightCard(_ sender: Any) {
        let cardIndex = currentDisplayIndex % gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count > cardIndex {
            tryUsingCard(gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards[cardIndex])
    }   }
    
    func tryUsingCard(_ card: ProgressCardsType) {
        let sceneReference = gameDataReference.scenePort!
        var cardHasBeenUsed = false
        switch card {
            case .Alchemist:
                let announcement = "This card may only be used when rolling the dice..."
                let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "CONTINUE", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .Crane:
                let announcement = "This card may only be used from the flip charts screen when performing a city improvement..."
                let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "CONTINUE", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .Engineer:
                break
                //
            case .Inventor:
                break
                //
            case .Irrigation:
                break
                //
            case .Medicine:
                break
                //
            case .Mining:
                break
                //
            case .Printer: break
            case .RoadBuilding:
                break
                //
            case .Smith:
                break
                //
            case .Bishop:
                break
                //
            case .Constitution: break
            case .Deserter:
                break
                //
            case .Diplomat:
                break
                //
            case .Intrigue:
                break
                //
            case .Saboteur:
                break
                //
            case .Spy:
                break
                //
            case .Warlord:
                break
                //
            case .Wedding:
                break
                //
            case .CommercialHarbor:
                break
                //
            case .MasterMerchant:
                break
                //
            case .Merchant:
                break
                //
            case .MerchantFleet:
                break
                //
            case .ResourceMonopoly:
                sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData = false
                var message = "getTradeResources.\((sceneReference.myPlayerIndex + 1) % 3)"
                let _ = gameDataReference.appDelegate.networkManager.sendData(data: message)
                let loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
                loadingView.color = UIColor.gray
                loadingView.startAnimating()
                self.view.addSubview(loadingView)
                while sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData == false { }
                loadingView.removeFromSuperview()
                sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData = false
                message = "getTradeResources.\((sceneReference.myPlayerIndex + 2) % 3)"
                let _ = gameDataReference.appDelegate.networkManager.sendData(data: message)
                loadingView.startAnimating()
                self.view.addSubview(loadingView)
                while sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData == false { }
                loadingView.removeFromSuperview()
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                let brickResource = UIAlertAction(title: "Brick", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].brick > 1 { sceneReference.players[sceneReference.myPlayerIndex].brick += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].brick > 0 { sceneReference.players[sceneReference.myPlayerIndex].brick += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].brick > 1 { sceneReference.players[sceneReference.myPlayerIndex].brick += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].brick > 0 { sceneReference.players[sceneReference.myPlayerIndex].brick += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Brick.rawValue).2")
                    cardHasBeenUsed = true
                }
                actionSheet.addAction(brickResource)
                let sheepResource = UIAlertAction(title: "Sheep", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].sheep > 1 { sceneReference.players[sceneReference.myPlayerIndex].sheep += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].sheep > 0 { sceneReference.players[sceneReference.myPlayerIndex].sheep += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].sheep > 1 { sceneReference.players[sceneReference.myPlayerIndex].sheep += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].sheep > 0 { sceneReference.players[sceneReference.myPlayerIndex].sheep += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Sheep.rawValue).2")
                    cardHasBeenUsed = true
                }
                actionSheet.addAction(sheepResource)
                let stoneResource = UIAlertAction(title: "Stone", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].stone > 1 { sceneReference.players[sceneReference.myPlayerIndex].stone += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].stone > 0 { sceneReference.players[sceneReference.myPlayerIndex].stone += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].stone > 1 { sceneReference.players[sceneReference.myPlayerIndex].stone += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].stone > 0 { sceneReference.players[sceneReference.myPlayerIndex].stone += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Stone.rawValue).2")
                    cardHasBeenUsed = true
                }
                actionSheet.addAction(stoneResource)
                let wheatResource = UIAlertAction(title: "Wheat", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].wheat > 1 { sceneReference.players[sceneReference.myPlayerIndex].wheat += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].wheat > 0 { sceneReference.players[sceneReference.myPlayerIndex].wheat += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].wheat > 1 { sceneReference.players[sceneReference.myPlayerIndex].wheat += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].wheat > 0 { sceneReference.players[sceneReference.myPlayerIndex].wheat += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Wheat.rawValue).2")
                    cardHasBeenUsed = true
                }
                actionSheet.addAction(wheatResource)
                let woodResource = UIAlertAction(title: "Wood", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].wood > 1 { sceneReference.players[sceneReference.myPlayerIndex].wood += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].wood > 0 { sceneReference.players[sceneReference.myPlayerIndex].wood += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].wood > 1 { sceneReference.players[sceneReference.myPlayerIndex].wood += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].wood > 0 { sceneReference.players[sceneReference.myPlayerIndex].wood += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Wood.rawValue).2")
                    cardHasBeenUsed = true
                }
                actionSheet.addAction(woodResource)
                let never_mind_XD = UIAlertAction(title: "Cancel", style: .default) { action -> Void in }
                actionSheet.addAction(never_mind_XD)
                self.present(actionSheet, animated: true, completion: nil)
            case .TradeMonopoly:
                sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData = false
                var message = "getTradeResources.\((sceneReference.myPlayerIndex + 1) % 3)"
                let _ = gameDataReference.appDelegate.networkManager.sendData(data: message)
                let loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
                loadingView.color = UIColor.gray
                loadingView.startAnimating()
                self.view.addSubview(loadingView)
                while sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData == false { }
                loadingView.removeFromSuperview()
                sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData = false
                message = "getTradeResources.\((sceneReference.myPlayerIndex + 2) % 3)"
                let _ = gameDataReference.appDelegate.networkManager.sendData(data: message)
                loadingView.startAnimating()
                self.view.addSubview(loadingView)
                while sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData == false { }
                loadingView.removeFromSuperview()
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                let coinCommidity = UIAlertAction(title: "Coin", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].coin > 0 { sceneReference.players[sceneReference.myPlayerIndex].coin += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].coin > 0 { sceneReference.players[sceneReference.myPlayerIndex].coin += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Coin.rawValue).1")
                    cardHasBeenUsed = true
                }
                actionSheet.addAction(coinCommidity)
                let paperCommodity = UIAlertAction(title: "Paper", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].paper > 0 { sceneReference.players[sceneReference.myPlayerIndex].paper += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].paper > 0 { sceneReference.players[sceneReference.myPlayerIndex].paper += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Paper.rawValue).1")
                    cardHasBeenUsed = true
                }
                actionSheet.addAction(paperCommodity)
                let clothCommodity = UIAlertAction(title: "Cloth", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].cloth > 0 { sceneReference.players[sceneReference.myPlayerIndex].cloth += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].cloth > 0 { sceneReference.players[sceneReference.myPlayerIndex].cloth += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Cloth.rawValue).1")
                    cardHasBeenUsed = true
                }
                actionSheet.addAction(clothCommodity)
                let never_mind_XD = UIAlertAction(title: "Cancel", style: .default) { action -> Void in }
                actionSheet.addAction(never_mind_XD)
                self.present(actionSheet, animated: true, completion: nil)
        }
        if cardHasBeenUsed {
            for index in 0..<gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count {
                if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards[index] == card {
                    gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.remove(at: index)
                    break
            }   }
            currentDisplayIndex = 0
            updateCardsDisplayWithStartingIndex(currentDisplayIndex)
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
