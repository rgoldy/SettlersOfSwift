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
            case .Engineer: //  NOT IMPLEMENTED
                let announcement = "This card may only be used from the flip charts screen when purchasing a city wall..."
                let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "CONTINUE", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //  ONE CITY WALL FOR FREE
            case .Inventor: //  NOT IMPLEMENTED
                break
            case .Irrigation:   //  NOT IMPLEMENTED
                break
            case .Medicine: //  NOT IMPLEMENTED
                let announcement = "This card may only be used from the flip charts screen when upgrading a settlement..."
                let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "CONTINUE", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //  SETTLEMENT UPGRADES NOW COST TWO ORE AND ONE GRAIN FOR ONE
            case .Mining:   //  NOT IMPLEMENTED
                break
            case .Printer: break
            case .RoadBuilding: //  NOT IMPLEMENTED
                let announcement = "This card may only be used from the flip charts screen when purchasing a road..."
                let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "CONTINUE", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //  BUILD TWO ROADS FOR FREE
            case .Smith:    //  NOT IMPLEMENTED
                let announcement = "This card may only be used from the flip charts screen when promoting a knight..."
                let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "CONTINUE", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //  PROMOTE TWO KNIGHTS FOR FREE
            case .Bishop:   //  NOT IMPLEMENTED
                break
            case .Constitution: break
            case .Deserter: //  NOT IMPLEMENTED
                break
            case .Diplomat: //  NOT IMPLEMENTED
                break
            case .Intrigue: //  NOT IMPLEMENTED
                break
            case .Saboteur: //  NOT IMPLEMENTED
                gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].victoryPointsRefreshed = false
                let _ = gameDataReference.appDelegate.networkManager.sendData(data: "refreshVictoryPoints.\((gameDataReference.scenePort.myPlayerIndex + 1) % 3)")
                while !gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].victoryPointsRefreshed { }
                gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].victoryPointsRefreshed = false
                let _ = gameDataReference.appDelegate.networkManager.sendData(data: "refreshVictoryPoints.\((gameDataReference.scenePort.myPlayerIndex + 2) % 3)")
                while !gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].victoryPointsRefreshed { }
                break
                //  PLAYERS WITH EQUALLY MANY OR MORE VICTORY POINTS DISCARD HALF OF THEIR CARDS
            case .Spy:
                let announcement = "Would you like to use The Spy Progress Card...?"
                let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { action -> Void in
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].receivedPeersCards = false
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "broadcastProgressCards.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3)")
                    let loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
                    loadingView.color = UIColor.gray
                    loadingView.startAnimating()
                    self.view.addSubview(loadingView)
                    while self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].receivedPeersCards == false { }
                    loadingView.removeFromSuperview()
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].receivedPeersCards = false
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "broadcastProgressCards.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3)")
                    let nextLoadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
                    nextLoadingView.color = UIColor.gray
                    nextLoadingView.startAnimating()
                    self.view.addSubview(nextLoadingView)
                    while self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].receivedPeersCards == false { }
                    loadingView.removeFromSuperview()
                    if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].progressCards.count == 0 && self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].progressCards.count == 0 {
                        let newAlert = UIAlertController(title: nil, message: "Unfortunately, no one has any Progress Card to spare...", preferredStyle: .alert)
                        newAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(newAlert, animated: true, completion: nil)
                    } else {
                        let newAlert = UIAlertController(title: nil, message: "Who would you like to steal from...?", preferredStyle: .alert)
                        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].progressCards.count != 0 {
                            newAlert.addAction(UIAlertAction(title: "Previous Player", style: .default, handler: { action -> Void in
                                let newSheet = UIAlertController(title: "", message: "Select a Progress Card...", preferredStyle: .actionSheet)
                                for card in self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].progressCards {
                                    newSheet.addAction(UIAlertAction(title: card.rawValue, style: .default, handler: { action -> Void in
                                        self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].progressCards.append(card)
                                        let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stoleProgressCard.\(card.rawValue).\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3)")
                                        self.removeAndRefresh(card)
                                    }))
                                }
                            }))
                        }
                        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].progressCards.count != 0 {
                            newAlert.addAction(UIAlertAction(title: "Next Player", style: .default, handler: { action -> Void in
                                let newSheet = UIAlertController(title: "", message: "Select a Progress Card...", preferredStyle: .actionSheet)
                                for card in self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].progressCards {
                                    newSheet.addAction(UIAlertAction(title: card.rawValue, style: .default, handler: { action -> Void in
                                        self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].progressCards.append(card)
                                        let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stoleProgressCard.\(card.rawValue).\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3)")
                                        self.removeAndRefresh(card)
                                    }))
                                }
                            }))
                        }
                        self.present(newAlert, animated: true, completion: nil)
                    }
                }))
                alert.addAction(UIAlertAction(title: "NO", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .Warlord:  //  NOT IMPLEMENTED
                break
                //  ALL KNIGHTS ACTIVATION ARE FREE
            case .Wedding:
                let announcement = "Would you like to use The Wedding Progress Card...?"
                let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { action -> Void in
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "weddingCard.\(self.gameDataReference.scenePort.myPlayerIndex)")
                    self.removeAndRefresh(card)
                }))
                alert.addAction(UIAlertAction(title: "NO", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .CommercialHarbor: //  NOT IMPLEMENTED
                sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData = false
                var message = "getTradeResources.\((sceneReference.myPlayerIndex + 2) % 3)"
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: message)
                var loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
                loadingView.color = UIColor.gray
                loadingView.startAnimating()
                self.view.addSubview(loadingView)
                while sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData == false { }
                loadingView.removeFromSuperview()
                sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData = false
                message = "getTradeResources.\((sceneReference.myPlayerIndex + 1) % 3)"
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: message)
                loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
                loadingView.color = UIColor.gray
                loadingView.startAnimating()
                self.view.addSubview(loadingView)
                while sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData == false { }
                loadingView.removeFromSuperview()
//                let myResourcesCount = sceneReference.players[sceneReference.myPlayerIndex].brick +
//                                       sceneReference.players[sceneReference.myPlayerIndex].gold +
//                                       sceneReference.players[sceneReference.myPlayerIndex].sheep +
//                                       sceneReference.players[sceneReference.myPlayerIndex].stone +
//                                       sceneReference.players[sceneReference.myPlayerIndex].wheat +
//                                       sceneReference.players[sceneReference.myPlayerIndex].wood
//                let previousPlayerCommoditiesCount = sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].coin +
//                                                     sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].paper +
//                                                     sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].cloth
//                let nextPlayerCommoditiesCount = sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].coin +
//                                                 sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].paper +
//                                                 sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].cloth
            
            
                //  TO BE CONTINUED
            
            
                //  FOR EACH PLAYER GIVE ONE RESOURCE AND RECEIVE ONE COMMODITY, INVALIDATED IF NOT ENOUGH RESOURCE / COMMIDITY
            case .MasterMerchant:
                gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].victoryPointsRefreshed = false
                let _ = gameDataReference.appDelegate.networkManager.sendData(data: "refreshVictoryPoints.\((gameDataReference.scenePort.myPlayerIndex + 1) % 3)")
                while !gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].victoryPointsRefreshed { }
                gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].victoryPointsRefreshed = false
                let _ = gameDataReference.appDelegate.networkManager.sendData(data: "refreshVictoryPoints.\((gameDataReference.scenePort.myPlayerIndex + 2) % 3)")
                while !gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].victoryPointsRefreshed { }
                if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].victoryPoints <= self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].victoryPoints && self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].victoryPoints <= self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].victoryPoints {
                    let newAlert = UIAlertController(title: nil, message: "Looks like you have equally many or more victory points than anyone else! This card has not been used.", preferredStyle: .alert)
                    newAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(newAlert, animated: true, completion: nil)
                } else {
                    let newAlert = UIAlertController(title: nil, message: "Who would you like to take resources and / or commodities from...?", preferredStyle: .alert)
                    if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].victoryPoints > self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].victoryPoints {
                        newAlert.addAction(UIAlertAction(title: "Previous Player", style: .default, handler: { action -> Void in
                            var invalidCounter = 0
                            sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData = false
                            let message = "getTradeResources.\((sceneReference.myPlayerIndex + 2) % 3)"
                            let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: message)
                            let loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
                            loadingView.color = UIColor.gray
                            loadingView.startAnimating()
                            self.view.addSubview(loadingView)
                            while sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData == false { }
                            loadingView.removeFromSuperview()
                            let newSheet = UIAlertController(title: "", message: "Select a resource or a commodity...", preferredStyle: .actionSheet)
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].brick > 0 {
                                let commodity = UIAlertAction(title: "Brick", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3).BRICK")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].brick -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].brick += 1
                                    self.masterMerchantHelper(offset: 2, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].gold > 0 {
                                let commodity = UIAlertAction(title: "Gold", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3).GOLD")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].gold -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].gold += 1
                                    self.masterMerchantHelper(offset: 2, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].sheep > 0 {
                                let commodity = UIAlertAction(title: "Sheep", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3).SHEEP")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].sheep -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].sheep += 1
                                    self.masterMerchantHelper(offset: 2, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].stone > 0 {
                                let commodity = UIAlertAction(title: "Stone", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3).STONE")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].stone -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].stone += 1
                                    self.masterMerchantHelper(offset: 2, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].wheat > 0 {
                                let commodity = UIAlertAction(title: "Wheat", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3).WHEAT")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].wheat -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wheat += 1
                                    self.masterMerchantHelper(offset: 2, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].wood > 0 {
                                let commodity = UIAlertAction(title: "Wood", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3).WOOD")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].wood -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wood += 1
                                    self.masterMerchantHelper(offset: 2, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].coin > 0 {
                                let commodity = UIAlertAction(title: "Coin", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3).COIN")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].coin -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].coin += 1
                                    self.masterMerchantHelper(offset: 2, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].paper > 0 {
                                let commodity = UIAlertAction(title: "Paper", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3).PAPER")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].paper -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].paper += 1
                                    self.masterMerchantHelper(offset: 2, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].cloth > 0 {
                                let commodity = UIAlertAction(title: "Cloth", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3).CLOTH")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].cloth -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].cloth += 1
                                    self.masterMerchantHelper(offset: 2, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if invalidCounter == 9 {
                                let newAlert = UIAlertController(title: nil, message: "Sorry, but looks like the player you chose is broke!", preferredStyle: .alert)
                                newAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(newAlert, animated: true, completion: nil)
                                self.removeAndRefresh(card)
                            } else { self.present(newSheet, animated: true, completion: nil) }
                        }))
                    }
                    if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].victoryPoints > self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].victoryPoints {
                        newAlert.addAction(UIAlertAction(title: "Next Player", style: .default, handler: { action -> Void in
                            var invalidCounter = 0
                            sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData = false
                            let message = "getTradeResources.\((sceneReference.myPlayerIndex + 2) % 3)"
                            let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: message)
                            let loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
                            loadingView.color = UIColor.gray
                            loadingView.startAnimating()
                            self.view.addSubview(loadingView)
                            while sceneReference.players[sceneReference.myPlayerIndex].fetchedTargetData == false { }
                            loadingView.removeFromSuperview()
                            let newSheet = UIAlertController(title: "", message: "Select a resource or a commodity...", preferredStyle: .actionSheet)
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].brick > 0 {
                                let commodity = UIAlertAction(title: "Brick", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3).BRICK")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].brick -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].brick += 1
                                    self.masterMerchantHelper(offset: 1, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].gold > 0 {
                                let commodity = UIAlertAction(title: "Gold", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3).GOLD")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].gold -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].gold += 1
                                    self.masterMerchantHelper(offset: 1, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].sheep > 0 {
                                let commodity = UIAlertAction(title: "Sheep", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3).SHEEP")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].sheep -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].sheep += 1
                                    self.masterMerchantHelper(offset: 1, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].stone > 0 {
                                let commodity = UIAlertAction(title: "Stone", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3).STONE")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].stone -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].stone += 1
                                    self.masterMerchantHelper(offset: 1, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].wheat > 0 {
                                let commodity = UIAlertAction(title: "Wheat", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3).WHEAT")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].wheat -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wheat += 1
                                    self.masterMerchantHelper(offset: 1, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].wood > 0 {
                                let commodity = UIAlertAction(title: "Wood", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3).WOOD")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].wood -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wood += 1
                                    self.masterMerchantHelper(offset: 1, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].coin > 0 {
                                let commodity = UIAlertAction(title: "Coin", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3).COIN")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].coin -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].coin += 1
                                    self.masterMerchantHelper(offset: 1, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].paper > 0 {
                                let commodity = UIAlertAction(title: "Paper", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3).PAPER")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].paper -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].paper += 1
                                    self.masterMerchantHelper(offset: 1, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].cloth > 0 {
                                let commodity = UIAlertAction(title: "Cloth", style: .default) { action -> Void in
                                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3).CLOTH")
                                    self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].cloth -= 1
                                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].cloth += 1
                                    self.masterMerchantHelper(offset: 1, card: card)
                                }
                                newSheet.addAction(commodity)
                            } else { invalidCounter += 1 }
                            if invalidCounter == 9 {
                                let newAlert = UIAlertController(title: nil, message: "Sorry, but looks like the player you chose is broke!", preferredStyle: .alert)
                                newAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(newAlert, animated: true, completion: nil)
                                self.removeAndRefresh(card)
                            } else { self.present(newSheet, animated: true, completion: nil) }
                        }))
                    }
                    self.present(newAlert, animated: true, completion: nil)
            }
            case .Merchant: //  NOT IMPLEMENTED
                break
            case .MerchantFleet:
                let actionSheet = UIAlertController(title: nil, message: "Select an item to trade at 2 : 1 ratio for current turn...", preferredStyle: .alert)
                let brickResource = UIAlertAction(title: "Brick", style: .default) { action -> Void in
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect = .Brick
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(brickResource)
                let goldResource = UIAlertAction(title: "Gold", style: .default) { action -> Void in
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect = .Gold
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(goldResource)
                let sheepResource = UIAlertAction(title: "Sheep", style: .default) { action -> Void in
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect = .Sheep
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(sheepResource)
                let stoneResource = UIAlertAction(title: "Stone", style: .default) { action -> Void in
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect = .Stone
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(stoneResource)
                let wheatResource = UIAlertAction(title: "Wheat", style: .default) { action -> Void in
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect = .Wheat
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(wheatResource)
                let woodResource = UIAlertAction(title: "Wood", style: .default) { action -> Void in
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect = .Wood
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(woodResource)
                let coinResource = UIAlertAction(title: "Coin", style: .default) { action -> Void in
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect = .Coin
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(coinResource)
                let paperResource = UIAlertAction(title: "Paper", style: .default) { action -> Void in
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect = .Paper
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(paperResource)
                let clothResource = UIAlertAction(title: "Cloth", style: .default) { action -> Void in
                    self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].merchantFleetSelect = .Cloth
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(clothResource)
                self.present(actionSheet, animated: true, completion: nil)
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
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(brickResource)
                let sheepResource = UIAlertAction(title: "Sheep", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].sheep > 1 { sceneReference.players[sceneReference.myPlayerIndex].sheep += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].sheep > 0 { sceneReference.players[sceneReference.myPlayerIndex].sheep += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].sheep > 1 { sceneReference.players[sceneReference.myPlayerIndex].sheep += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].sheep > 0 { sceneReference.players[sceneReference.myPlayerIndex].sheep += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Sheep.rawValue).2")
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(sheepResource)
                let stoneResource = UIAlertAction(title: "Stone", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].stone > 1 { sceneReference.players[sceneReference.myPlayerIndex].stone += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].stone > 0 { sceneReference.players[sceneReference.myPlayerIndex].stone += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].stone > 1 { sceneReference.players[sceneReference.myPlayerIndex].stone += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].stone > 0 { sceneReference.players[sceneReference.myPlayerIndex].stone += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Stone.rawValue).2")
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(stoneResource)
                let wheatResource = UIAlertAction(title: "Wheat", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].wheat > 1 { sceneReference.players[sceneReference.myPlayerIndex].wheat += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].wheat > 0 { sceneReference.players[sceneReference.myPlayerIndex].wheat += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].wheat > 1 { sceneReference.players[sceneReference.myPlayerIndex].wheat += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].wheat > 0 { sceneReference.players[sceneReference.myPlayerIndex].wheat += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Wheat.rawValue).2")
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(wheatResource)
                let woodResource = UIAlertAction(title: "Wood", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].wood > 1 { sceneReference.players[sceneReference.myPlayerIndex].wood += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].wood > 0 { sceneReference.players[sceneReference.myPlayerIndex].wood += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].wood > 1 { sceneReference.players[sceneReference.myPlayerIndex].wood += 2 }
                    else if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].wood > 0 { sceneReference.players[sceneReference.myPlayerIndex].wood += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Wood.rawValue).2")
                    self.removeAndRefresh(card)
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
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(coinCommidity)
                let paperCommodity = UIAlertAction(title: "Paper", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].paper > 0 { sceneReference.players[sceneReference.myPlayerIndex].paper += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].paper > 0 { sceneReference.players[sceneReference.myPlayerIndex].paper += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Paper.rawValue).1")
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(paperCommodity)
                let clothCommodity = UIAlertAction(title: "Cloth", style: .default) { action -> Void in
                    if sceneReference.players[(sceneReference.myPlayerIndex + 1) % 3].cloth > 0 { sceneReference.players[sceneReference.myPlayerIndex].cloth += 1 }
                    if sceneReference.players[(sceneReference.myPlayerIndex + 2) % 3].cloth > 0 { sceneReference.players[sceneReference.myPlayerIndex].cloth += 1 }
                    let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "resourcesHasBeenStolen.\(SelectedItem.Cloth.rawValue).1")
                    self.removeAndRefresh(card)
                }
                actionSheet.addAction(clothCommodity)
                let never_mind_XD = UIAlertAction(title: "Cancel", style: .default) { action -> Void in }
                actionSheet.addAction(never_mind_XD)
                self.present(actionSheet, animated: true, completion: nil)
    }   }
    
    func removeAndRefresh(_ card: ProgressCardsType) {
        for index in 0..<self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].progressCards.count {
            if self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].progressCards[index] == card {
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].progressCards.remove(at: index)
                break
            }   }
        self.currentDisplayIndex = 0
        self.updateCardsDisplayWithStartingIndex(self.currentDisplayIndex)
    }
    
    func masterMerchantHelper(offset: Int, card: ProgressCardsType) {
        var invalidCounter = 0
        let newSheet = UIAlertController(title: "", message: "Select a resource or a commodity...", preferredStyle: .actionSheet)
        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].brick > 0 {
            let commodity = UIAlertAction(title: "Brick", style: .default) { action -> Void in
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + offset) % 3).BRICK")
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].brick -= 1
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].brick += 1
                self.removeAndRefresh(card)
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].gold > 0 {
            let commodity = UIAlertAction(title: "Gold", style: .default) { action -> Void in
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + offset) % 3).GOLD")
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].gold -= 1
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].gold += 1
                self.removeAndRefresh(card)
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].sheep > 0 {
            let commodity = UIAlertAction(title: "Sheep", style: .default) { action -> Void in
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + offset) % 3).SHEEP")
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].sheep -= 1
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].sheep += 1
                self.removeAndRefresh(card)
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].stone > 0 {
            let commodity = UIAlertAction(title: "Stone", style: .default) { action -> Void in
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + offset) % 3).STONE")
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].stone -= 1
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].stone += 1
                self.removeAndRefresh(card)
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].wheat > 0 {
            let commodity = UIAlertAction(title: "Wheat", style: .default) { action -> Void in
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + offset) % 3).WHEAT")
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].wheat -= 1
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wheat += 1
                self.removeAndRefresh(card)
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].wood > 0 {
            let commodity = UIAlertAction(title: "Wood", style: .default) { action -> Void in
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + offset) % 3).WOOD")
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].wood -= 1
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wood += 1
                self.removeAndRefresh(card)
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].coin > 0 {
            let commodity = UIAlertAction(title: "Coin", style: .default) { action -> Void in
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + offset) % 3).COIN")
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].coin -= 1
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].coin += 1
                self.removeAndRefresh(card)
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].paper > 0 {
            let commodity = UIAlertAction(title: "Paper", style: .default) { action -> Void in
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + offset) % 3).PAPER")
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].paper -= 1
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].paper += 1
                self.removeAndRefresh(card)
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].cloth > 0 {
            let commodity = UIAlertAction(title: "Cloth", style: .default) { action -> Void in
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "stealPlayerResourceOrCommodity.\((self.gameDataReference.scenePort.myPlayerIndex + offset) % 3).CLOTH")
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + offset) % 3].cloth -= 1
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].cloth += 1
                self.removeAndRefresh(card)
            }
            newSheet.addAction(commodity)
        } else { invalidCounter += 1 }
        if invalidCounter == 9 {
            let newAlert = UIAlertController(title: nil, message: "Sorry, but looks like the player you chose is broke!", preferredStyle: .alert)
            newAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(newAlert, animated: true, completion: nil)
            self.removeAndRefresh(card)
        } else { self.present(newSheet, animated: true, completion: nil) }
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
