//
//  InGameMiscellaneousViewController.swift
//  SettlersOfSwift
//
//  Created by YIFFY on 4/8/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

class InGameMiscellaneousViewController: UIViewController {

    @IBOutlet weak var topLeftButton: UIButton!
    @IBOutlet weak var middleLeftButton: UIButton!
    @IBOutlet weak var bottomLeftButton: UIButton!
    @IBOutlet weak var topRightButton: UIButton!
    @IBOutlet weak var middleRightButton: UIButton!
    @IBOutlet weak var bottomRightButton: UIButton!
    
    var gameDataReference: GameViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameDataReference = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! GameViewController
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "menuBackground")!)
        wireButtonFunctionalities()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func wireButtonFunctionalities() {
        gameDataReference.scenePort.sendPlayerData(player: gameDataReference.scenePort.myPlayerIndex)
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish > 1 { topLeftButton.isEnabled = true } else { topLeftButton.isEnabled = false }
        if gameDataReference.scenePort.pirateRemoved && gameDataReference.scenePort.robberRemoved { topLeftButton.isEnabled = false }
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish > 2 { middleLeftButton.isEnabled = true } else { middleLeftButton.isEnabled = false }
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish > 3 { bottomLeftButton.isEnabled = true } else { bottomLeftButton.isEnabled = false }
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish > 4 { topRightButton.isEnabled = true } else { topRightButton.isEnabled = false }
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish > 4 { middleRightButton.isEnabled = true } else { middleRightButton.isEnabled = false }
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish > 6 { bottomRightButton.isEnabled = true } else { bottomRightButton.isEnabled = false }
        topLeftButton.setTitle("Remove Outlaw", for: .normal)
        topLeftButton.setTitle("Remove Outlaw", for: .disabled)
        middleLeftButton.setTitle("Steal from Opponent", for: .normal)
        middleLeftButton.setTitle("Steal from Opponent", for: .disabled)
        bottomLeftButton.setTitle("Steal from Bank", for: .normal)
        bottomLeftButton.setTitle("Steal from Bank", for: .disabled)
        topRightButton.setTitle("Free Road", for: .normal)
        topRightButton.setTitle("Free Road", for: .disabled)
        middleRightButton.setTitle("Free Ship", for: .normal)
        middleRightButton.setTitle("Free Ship", for: .disabled)
        bottomRightButton.setTitle("Free Progress Card", for: .normal)
        bottomRightButton.setTitle("Free Progress Card", for: .disabled)
    }
    
    @IBAction func didInteractWithTopLeftButton(_ sender: Any) {
        if gameDataReference.scenePort.myPlayerIndex != gameDataReference.scenePort.currentPlayer || !gameDataReference.scenePort.rolled { return }
        if !gameDataReference.scenePort.pirateRemoved || !gameDataReference.scenePort.robberRemoved {
            
            
            if gameDataReference.scenePort.currentPlayer != gameDataReference.scenePort.myPlayerIndex { return }
            let alert = UIAlertController(title: "Removal", message: "Pick an outlaw to remove", preferredStyle: .actionSheet)
            let robber = UIAlertAction(title: "Robber", style: .default, handler: { action -> Void in
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].fish -= 2
                let oldHex = self.gameDataReference.scenePort.handler.landHexArray.first(where: {$0.center?.hasRobber == true})
                oldHex?.center?.hasRobber = false
                self.gameDataReference.scenePort.handler.Vertices.setTileGroup(nil, forColumn: (oldHex?.center?.column)!, row: (oldHex?.center?.row)!)
                self.gameDataReference.scenePort.robberRemoved = true
                
                let message = "removeOutlaw.Robber"
                let sent = self.gameDataReference.appDelegate.networkManager.sendData(data: message)
                if !sent { print("unable to remove Robber") }
                
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].nextAction = .WillDoNothing
            })
            let pirate = UIAlertAction(title: "Pirate", style: .default, handler: { action -> Void in
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].fish -= 2
                let oldHex = self.gameDataReference.scenePort.handler.landHexArray.first(where: {$0.center?.hasPirate == true})
                oldHex?.center?.hasPirate = false
                self.gameDataReference.scenePort.handler.Vertices.setTileGroup(nil, forColumn: (oldHex?.center?.column)!, row: (oldHex?.center?.row)!)
                self.gameDataReference.scenePort.pirateRemoved = true
                
                let message = "removeOutlaw.Pirate"
                let sent = self.gameDataReference.appDelegate.networkManager.sendData(data: message)
                if !sent { print("unable to remove Pirate") }
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].nextAction = .WillDoNothing
            })
            let nothing = UIAlertAction(title: "Nothing", style: .default, handler: { action -> Void in
                self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].nextAction = .WillDoNothing
            })
            
            if !gameDataReference.scenePort.robberRemoved {
                alert.addAction(robber)
            }
            if !gameDataReference.scenePort.pirateRemoved {
                alert.addAction(pirate)
            }
            alert.addAction(nothing)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        self.tabBarController?.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didInteractWithMiddleLeftButton(_ sender: Any) {
        if gameDataReference.scenePort.myPlayerIndex != gameDataReference.scenePort.currentPlayer || !gameDataReference.scenePort.rolled { return }
        gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish -= 3
        let actionSheet = UIAlertController(title: "Opponent Steal", message: "Who would you like to steal randomly from?", preferredStyle: .alert)
        let previousPlayer = UIAlertAction(title: "Previous Player", style: .default) { action -> Void in
            self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].fetchedTargetData = false
            let message = "getTradeResources.\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3)"
            let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: message)
            let loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
            loadingView.color = UIColor.gray
            loadingView.startAnimating()
            self.view.addSubview(loadingView)
            while self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].fetchedTargetData == false { }
            loadingView.removeFromSuperview()
            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].brick == 0 &&
               self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].gold == 0 &&
               self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].sheep == 0 &&
               self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].stone == 0 &&
               self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].wheat == 0 &&
               self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].wood == 0 &&
               self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].coin == 0 &&
               self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].paper == 0 &&
               self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].cloth == 0 {
                let notificationBanner = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                notificationBanner.isOpaque = false
                notificationBanner.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.6)
                let notificationContent = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                notificationContent.isOpaque = false
                notificationContent.font = UIFont(name: "Avenir-Roman", size: 14)
                notificationContent.textColor = UIColor.lightGray
                notificationContent.textAlignment = .center
                notificationContent.text = "Unfortunately, the other player did not have anything to steal...poor fishes 🐠🐡🐳."
                self.view?.addSubview(notificationBanner)
                self.view?.addSubview(notificationContent)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    notificationContent.removeFromSuperview()
                    notificationBanner.removeFromSuperview()
                })
            } else {
                var stealableResource: SelectedItem? = nil
                while stealableResource == nil {
                    let index = Int(arc4random()) % 9
                    switch index {
                        case 0: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].brick > 0 { stealableResource = .Brick }
                        case 1: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].gold > 0 { stealableResource = .Gold }
                        case 2: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].sheep > 0 { stealableResource = .Sheep }
                        case 3: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].stone > 0 { stealableResource = .Stone }
                        case 4: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].wheat > 0 { stealableResource = .Wheat }
                        case 5: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].wood > 0 { stealableResource = .Wood }
                        case 6: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].coin > 0 { stealableResource = .Coin }
                        case 7: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].paper > 0 { stealableResource = .Paper }
                        case 8: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 2) % 3].cloth > 0 { stealableResource = .Cloth }
                        default: break
                }   }
                switch stealableResource! {
                    case .Brick: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].brick += 1
                    case .Gold: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].gold += 1
                    case .Sheep: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].sheep += 1
                    case .Stone: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].stone += 1
                    case .Wheat: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wheat += 1
                    case .Wood: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wood += 1
                    case .Coin: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].coin += 1
                    case .Paper: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].paper += 1
                    case .Cloth: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].cloth += 1
                    case .None: break
                }
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "loseOneOf.\(stealableResource!.rawValue).\((self.gameDataReference.scenePort.myPlayerIndex + 2) % 3)")
                let notificationBanner = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                notificationBanner.isOpaque = false
                notificationBanner.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.6)
                let notificationContent = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                notificationContent.isOpaque = false
                notificationContent.font = UIFont(name: "Avenir-Roman", size: 14)
                notificationContent.textColor = UIColor.lightGray
                notificationContent.textAlignment = .center
                notificationContent.text = "You have randomly stolen a \(stealableResource!.rawValue) from your opponent!"
                self.view?.addSubview(notificationBanner)
                self.view?.addSubview(notificationContent)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    notificationContent.removeFromSuperview()
                    notificationBanner.removeFromSuperview()
                })
            }
            self.wireButtonFunctionalities()
        }
        actionSheet.addAction(previousPlayer)
        let nextPlayer = UIAlertAction(title: "Next Player", style: .default) { action -> Void in
            self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].fetchedTargetData = false
            let message = "getTradeResources.\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3)"
            let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: message)
            let loadingView = UIActivityIndicatorView(frame: CGRect(x: 343, y: 182, width: 50, height: 50))
            loadingView.color = UIColor.gray
            loadingView.startAnimating()
            self.view.addSubview(loadingView)
            while self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].fetchedTargetData == false { }
            loadingView.removeFromSuperview()
            if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].brick == 0 &&
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].gold == 0 &&
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].sheep == 0 &&
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].stone == 0 &&
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].wheat == 0 &&
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].wood == 0 &&
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].coin == 0 &&
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].paper == 0 &&
                self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].cloth == 0 {
                let notificationBanner = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                notificationBanner.isOpaque = false
                notificationBanner.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.6)
                let notificationContent = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                notificationContent.isOpaque = false
                notificationContent.font = UIFont(name: "Avenir-Roman", size: 14)
                notificationContent.textColor = UIColor.lightGray
                notificationContent.textAlignment = .center
                notificationContent.text = "Unfortunately, the other player did not have anything to steal...poor fishes 🐠🐡🐳."
                self.view?.addSubview(notificationBanner)
                self.view?.addSubview(notificationContent)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    notificationContent.removeFromSuperview()
                    notificationBanner.removeFromSuperview()
                })
            } else {
                var stealableResource: SelectedItem? = nil
                while stealableResource == nil {
                    let index = Int(arc4random()) % 9
                    switch index {
                    case 0: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].brick > 0 { stealableResource = .Brick }
                    case 1: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].gold > 0 { stealableResource = .Gold }
                    case 2: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].sheep > 0 { stealableResource = .Sheep }
                    case 3: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].stone > 0 { stealableResource = .Stone }
                    case 4: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].wheat > 0 { stealableResource = .Wheat }
                    case 5: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].wood > 0 { stealableResource = .Wood }
                    case 6: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].coin > 0 { stealableResource = .Coin }
                    case 7: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].paper > 0 { stealableResource = .Paper }
                    case 8: if self.gameDataReference.scenePort.players[(self.gameDataReference.scenePort.myPlayerIndex + 1) % 3].cloth > 0 { stealableResource = .Cloth }
                    default: break
                    }   }
                switch stealableResource! {
                case .Brick: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].brick += 1
                case .Gold: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].gold += 1
                case .Sheep: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].sheep += 1
                case .Stone: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].stone += 1
                case .Wheat: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wheat += 1
                case .Wood: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wood += 1
                case .Coin: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].coin += 1
                case .Paper: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].paper += 1
                case .Cloth: self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].cloth += 1
                case .None: break
                }
                let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "loseOneOf.\(stealableResource!.rawValue).\((self.gameDataReference.scenePort.myPlayerIndex + 1) % 3)")
                let notificationBanner = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                notificationBanner.isOpaque = false
                notificationBanner.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.6)
                let notificationContent = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                notificationContent.isOpaque = false
                notificationContent.font = UIFont(name: "Avenir-Roman", size: 14)
                notificationContent.textColor = UIColor.lightGray
                notificationContent.textAlignment = .center
                notificationContent.text = "You have randomly stolen a \(stealableResource!.rawValue) from your opponent!"
                self.view?.addSubview(notificationBanner)
                self.view?.addSubview(notificationContent)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    notificationContent.removeFromSuperview()
                    notificationBanner.removeFromSuperview()
                })
            }
            self.wireButtonFunctionalities()
        }
        actionSheet.addAction(nextPlayer)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func didInteractWithBottomLeftButton(_ sender: Any) {
        if gameDataReference.scenePort.myPlayerIndex != gameDataReference.scenePort.currentPlayer || !gameDataReference.scenePort.rolled { return }
        gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish -= 4
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let brickResource = UIAlertAction(title: "Brick", style: .default) { action -> Void in
            self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].brick += 1
            self.wireButtonFunctionalities()
        }
        actionSheet.addAction(brickResource)
        let goldResource = UIAlertAction(title: "Gold", style: .default) { action -> Void in
            self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].gold += 1
            self.wireButtonFunctionalities()
        }
        actionSheet.addAction(goldResource)
        let sheepResource = UIAlertAction(title: "Sheep", style: .default) { action -> Void in
            self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].sheep += 1
            self.wireButtonFunctionalities()
        }
        actionSheet.addAction(sheepResource)
        let stoneResource = UIAlertAction(title: "Stone", style: .default) { action -> Void in
            self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].stone += 1
            self.wireButtonFunctionalities()
        }
        actionSheet.addAction(stoneResource)
        let wheatResource = UIAlertAction(title: "Wheat", style: .default) { action -> Void in
            self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wheat += 1
            self.wireButtonFunctionalities()
        }
        actionSheet.addAction(wheatResource)
        let woodResource = UIAlertAction(title: "Wood", style: .default) { action -> Void in
            self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].wood += 1
            self.wireButtonFunctionalities()
        }
        actionSheet.addAction(woodResource)
        let never_mind_XD = UIAlertAction(title: "Cancel", style: .default) { action -> Void in
            self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].fish += 3
            self.wireButtonFunctionalities()
        }
        actionSheet.addAction(never_mind_XD)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func didInteractWithTopRightButton(_ sender: Any) {
        if gameDataReference.scenePort.myPlayerIndex != gameDataReference.scenePort.currentPlayer || !gameDataReference.scenePort.rolled { return }
        gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish -= 5
        gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].nextAction = .WillBuildRoadForFree
        gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].comingFromFishes = true
        self.tabBarController?.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didInteractWithMiddleRightButton(_ sender: Any) {
        if gameDataReference.scenePort.myPlayerIndex != gameDataReference.scenePort.currentPlayer || !gameDataReference.scenePort.rolled { return }
        gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish -= 5
        gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].nextAction = .WillBuildShipForFree
        gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].comingFromFishes = true
        self.tabBarController?.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didInteractWithBottomRightButton(_ sender: Any) {
        if gameDataReference.scenePort.myPlayerIndex != gameDataReference.scenePort.currentPlayer || !gameDataReference.scenePort.rolled { return }
        gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].fish -= 7
        var deckCopy = [ProgressCardsType?]()
        for item in gameDataReference.scenePort.gameDeck { deckCopy.append(item) }
        for _ in 0..<216 {
            let first = Int(arc4random() % 54)
            let second = Int(arc4random() % 54)
            let temporaryCard = deckCopy[first]
            deckCopy[first] = deckCopy[second]
            deckCopy[second] = temporaryCard
        }
        let actionSheet = UIAlertController(title: nil, message: "Please select the Progress Card you would like to receive...", preferredStyle: .actionSheet)
        for item in deckCopy {
            if item != nil {
                let itemAction = UIAlertAction(title: item!.rawValue, style: .default, handler: { action -> Void in
                    for index in 0..<self.gameDataReference.scenePort.gameDeck.count {
                        if self.gameDataReference.scenePort.gameDeck[index] == item {
                            let _ = self.gameDataReference.appDelegate.networkManager.sendData(data: "removeProgressCardAtIndex.\(index)")
                            self.gameDataReference.scenePort.gameDeck[index] = nil
                            if item == .Constitution || item == .Printer {
                                self.gameDataReference.scenePort.give(victoryPoints: 1, to: self.gameDataReference.scenePort.myPlayerIndex)
                            } else { self.gameDataReference.scenePort.players[self.gameDataReference.scenePort.myPlayerIndex].progressCards.append(item!)
                            }
                            break
                    }   }
                    self.wireButtonFunctionalities()
                })
                actionSheet.addAction(itemAction)
        }   }
        self.present(actionSheet, animated: true, completion: nil)
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
