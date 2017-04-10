//
//  GameViewController.swift
//  SettlersOfSwift
//
//  Created by Riley Goldman on 1/25/17.
//  Written by Mario Youssef, 
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import MultipeerConnectivity
import AVFoundation

enum AdditionalButtonActions {
    case CancelPlayerIntention
    case PlaceMetropolisOnMap
}

class GameViewController: UIViewController, NetworkDelegate {
    
    //  CUSTOM BUTTONS FOR DIFFERENT PURPOSES
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backgroundMusicButton: UIButton!
    @IBOutlet weak var endCurrentTurnButton: UIButton!
    @IBOutlet weak var additionalButtonA: UIButton!
    @IBOutlet weak var additionalButtonB: UIButton!
    
    var additionalButtonAAction: AdditionalButtonActions? = nil
    var additionalButtonBAction: AdditionalButtonActions? = nil
    
    //  PLAYS BACKGROUND MUSIC CONTAINED IN FILE NAMED background.mp3 (NOT TESTED)
    
    var backgroundMusicPlayer: AVAudioPlayer!
    var muted = false
    
    // Added by Riley
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var viewPort: SKView!
    var scenePort: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                
                self.scenePort = scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            self.viewPort = view
        }
        
        // Added by Riley
        appDelegate.networkManager.delegate = self
        self.navigationController?.navigationBar.isHidden = true;
        appDelegate.networkManager.setInvisible()
        appDelegate.networkManager.stopBrowsing()
        
        syncBoard()
        
    }
    
    @IBAction func invokeActionsMenu(_ sender: Any) {
        if (scenePort.currGamePhase == .p1Turn || scenePort.currGamePhase == .p2Turn || scenePort.currGamePhase == .p3Turn) && scenePort.currentPlayer == scenePort.myPlayerIndex {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            let moveKnight = UIAlertAction(title: "Move Knight", style: .default) { action -> Void in
                self.scenePort.players[self.scenePort.myPlayerIndex].nextAction = .WillMoveKnight
            }
            actionSheet.addAction(moveKnight)
            let moveOutlaw = UIAlertAction(title: "Move Outlaw", style: .default) { action -> Void in
                self.scenePort.players[self.scenePort.myPlayerIndex].nextAction = .WillMoveOutlaw
            }
            actionSheet.addAction(moveOutlaw)
            let moveShip = UIAlertAction(title: "Move Ship", style: .default) { action -> Void in
                self.scenePort.players[self.scenePort.myPlayerIndex].nextAction = .WillMoveShip
            }
            actionSheet.addAction(moveShip)
            let never_mind_XD = UIAlertAction(title: "Cancel", style: .default) { action -> Void in }
            actionSheet.addAction(never_mind_XD)
            self.present(actionSheet, animated: true, completion: nil)
    }   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        if backgroundMusicPlayer == nil && !muted {
            do {
                let music = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "background.mp3", ofType: nil)!))
                backgroundMusicPlayer = music
                backgroundMusicPlayer.numberOfLoops = -1
                backgroundMusicPlayer.play()
            } catch { }
        }
        setAppearanceForMenuButton()
        if scenePort.players.count > 1 && scenePort.players[scenePort.myPlayerIndex].nextAction != .WillDoNothing {
            scenePort.cancelButton.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.04, alpha: 1.0)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setAppearanceForMenuButton() {
        if scenePort.myPlayerIndex != -1 {
            let playerColor = scenePort.players[scenePort.myPlayerIndex].color
            switch playerColor {
                case .Blue: menuButton.backgroundColor = UIColor.blue
                case .Orange: menuButton.backgroundColor = UIColor.orange
                case .Red: menuButton.backgroundColor = UIColor.red
            }
        } else { menuButton.backgroundColor = UIColor.black }
        //  CUSTOMIZES MENU BUTTON APPEARANCE
    }
    
    func syncBoard() {
        if (appDelegate.networkManager.loadData == "nil") {
            if (appDelegate.networkManager.isHost) {
                // Wait for all players to be ready
                while (appDelegate.networkManager.readyPlayers < appDelegate.networkManager.session.connectedPeers.count) { /* wait */}
                
                // Distribute board layout to others
                let boardEncoding = scenePort.getBoardLayout()
                let sent = appDelegate.networkManager.sendData(data: boardEncoding)
                if (!sent) {
                    print("Failed to sync board layout")
                }
                else {
                    print("Board Sync Data Sent")
                }
                
                // Create player objects and send to non-hosts
                scenePort.initPlayers()
                // Create and shuffle fish deck then send to non-hosts
                scenePort.initFish()
            }
            else
            {
                let sent = appDelegate.networkManager.sendData(data: "readyToPlay.true")
                if (!sent) {
                    print ("Unable to notify players of status")
                }
                else {
                    print ("Players notified of status")
                }
            }
        }
        else {
            scenePort.loadGame()
        }
    }

//    let requestDefinition = "playerTradeRequest.\(gameDataReference.scenePort.myPlayerIndex + ((segmentSelector.selectedSegmentIndex == 1) ? 2 : 1)).\(gameDataReference.scenePort.myPlayerIndex).\(currentRatio).\(selectedSource.rawValue).\(selectedTarget.rawValue)"
    
    func recievedData(data: String) {
        let message = data.components(separatedBy: ".")
        print("RECEIVED MESSAGE \(message[0])")
        switch(message[0]) {
            case "boardLayout": // data represents board layout
                scenePort.setBoardLayout(encoding: message[1])
                scenePort.handler.updateGUI()
                print("Updated Scene")
            case "readyToPlay": // data informs others whether player is ready
                if (message[1] == "true") {
                    appDelegate.networkManager.readyPlayers += 1
                }
                else {
                    appDelegate.networkManager.readyPlayers -= 1
                }
            case "playerData": // data represents players' information
                scenePort.setPlayers(info: message[1])
                print ("Updated Players")
            case "cornerData":
                scenePort.setCornerObjectFromMessage(info: message[1])
                print("Updated cornerObject")
            case "edgeData":
                scenePort.setEdgeObjectFromMessage(info: message[1])
                print("Updated edgeObject")
            case "currPlayerData":
                scenePort.setNewCurrPlayer(info: message[1])
                print("Updated currentPlayer")
            case "gamePhaseData":
                scenePort.setNewGamePhase(info: message[1])
                print("Updated currGamePhase")
            case "diceRoll":
                let diceData = message[1].components(separatedBy: ",")
                let redDie = Int(diceData[0])!
                let yellowDie = Int(diceData[1])!
                let eventDie = Int(diceData[2])!
                // distribuite resources
                if(redDie + yellowDie != 7) {
                    scenePort.distributeResources(dice: redDie + yellowDie)
                }
                // update dice and GUI
                scenePort.dice.redValue = redDie
                scenePort.dice.yellowValue = yellowDie
                scenePort.updateDice(red: redDie, yellow: yellowDie, event: eventDie)
                print ("Updated Dice")
            case "updatePlayerData":
                scenePort.recievePlayerData(data: message[1])
            case "fishdeck":
                scenePort.recievedFishDeck(encoding: message[1])
            case "playerTradeRequest":
                if Int(message[1])! == scenePort.myPlayerIndex {
                    let myReference = scenePort.players[scenePort.myPlayerIndex]
                    let announcement = "Some player would like to trade \(message[3]) \(message[4])(s) for one of your \(message[5])...would you like to proceed?"
                    let alert = UIAlertController(title: "Trade Notification", message: announcement, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (action) in
                        let receivedResourcesCount = Int(message[3])!
                        switch message[4] {
                            case "BRICK": myReference.brick += receivedResourcesCount
                            case "GOLD": myReference.gold += receivedResourcesCount
                            case "SHEEP": myReference.sheep += receivedResourcesCount
                            case "STONE": myReference.stone += receivedResourcesCount
                            case "WHEAT": myReference.wheat += receivedResourcesCount
                            case "WOOD": myReference.wood += receivedResourcesCount
                            case "COIN": myReference.coin += receivedResourcesCount
                            case "PAPER": myReference.paper += receivedResourcesCount
                            case "CLOTH": myReference.cloth += receivedResourcesCount
                            default: break
                        }
                        switch message[5] {
                            case "BRICK": myReference.brick -= 1
                            case "GOLD": myReference.gold -= 1
                            case "SHEEP": myReference.sheep -= 1
                            case "STONE": myReference.stone -= 1
                            case "WHEAT": myReference.wheat -= 1
                            case "WOOD": myReference.wood -= 1
                            case "COIN": myReference.coin -= 1
                            case "PAPER": myReference.paper -= 1
                            case "CLOTH": myReference.cloth -= 1
                            default: break
                        }
                        let _ = self.appDelegate.networkManager.sendData(data: "tradeAcknowledgement.\(message[2]).YES")
                    }))
                    alert.addAction(UIAlertAction(title: "Decline", style: .default, handler: { (action) in
                        let _ = self.appDelegate.networkManager.sendData(data: "tradeAcknowledgement.\(message[2]).NO")
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            case "tradeAcknowledgement":
                if Int(message[1]) != nil && Int(message[1])! == scenePort.myPlayerIndex {
                    if message[2] == "YES" { scenePort.players[scenePort.myPlayerIndex].tradeAccepted = true }
                    if message[2] == "NO" { scenePort.players[scenePort.myPlayerIndex].tradeAccepted = false }
                }
            case "getTradeResources":
                if Int(message[1])! == scenePort.myPlayerIndex {
                    let player = scenePort.players[scenePort.myPlayerIndex]
                    let message = "sendResourcesCount.\(scenePort.myPlayerIndex).\(player.brick).\(player.gold).\(player.sheep).\(player.stone).\(player.wheat).\(player.wood).\(player.coin).\(player.paper).\(player.cloth)"
                    let _ = self.appDelegate.networkManager.sendData(data: message)
                }
            case "broadcastProgressCards":
                if scenePort.myPlayerIndex == Int(message[1])! {
                    var message = "myProgressCards.\(scenePort.myPlayerIndex)."
                    for card in scenePort.players[scenePort.myPlayerIndex].progressCards {
                        message += card.rawValue + "."
                    }
                    message += "nil"
                    let _ = appDelegate.networkManager.sendData(data: message)
                }
            case "myProgressCards":
                let playerReference = scenePort.players[Int(message[1])!]
                var index = 2
                playerReference.progressCards = [ProgressCardsType]()
                while message[index] != "nil" {
                    playerReference.progressCards.append(ProgressCardsType(rawValue: message[index])!)
                    index += 1
                }
                scenePort.players[scenePort.myPlayerIndex].receivedPeersCards = true
            case "stoleProgressCard":
                if scenePort.myPlayerIndex == Int(message[2])! {
                    let stolenProgressCard = ProgressCardsType(rawValue: message[1])
                    for index in 0..<scenePort.players[scenePort.myPlayerIndex].progressCards.count {
                        if scenePort.players[scenePort.myPlayerIndex].progressCards[index] == stolenProgressCard {
                            scenePort.players[scenePort.myPlayerIndex].progressCards.remove(at: index)
                            break
                }   }   }
            case "robberDiscardScenario": scenePort.checkIfCardsNeedDiscard()
            case "sendResourcesCount":
                let player = scenePort.players[Int(message[1])!]
                player.brick = Int(message[2])!
                player.gold = Int(message[3])!
                player.sheep = Int(message[4])!
                player.stone = Int(message[5])!
                player.wheat = Int(message[6])!
                player.wood = Int(message[7])!
                player.coin = Int(message[8])!
                player.paper = Int(message[9])!
                player.cloth = Int(message[10])!
                scenePort.players[scenePort.myPlayerIndex].fetchedTargetData = true
            case "displace":
                scenePort.displaceKnight(data: message[1])
            case "drewProgressCard":
                switch message[1] {
                    case "POLITICS":
                        let _ = ProgressCardsType.getNextCardOfCategory(.Politics, fromDeck: &scenePort.gameDeck)
                    case "SCIENCES":
                        let _ = ProgressCardsType.getNextCardOfCategory(.Sciences, fromDeck: &scenePort.gameDeck)
                    case "TRADES":
                        let _ = ProgressCardsType.getNextCardOfCategory(.Trades, fromDeck: &scenePort.gameDeck)
                    default: break
                }
            case "barbariansDistanceUpdate":
                let distance = Int(message[1])!
                scenePort.barbariansDistanceFromCatan = distance
                scenePort.alertAboutBarbarians()
            case "intentions":
                let player = Int(message[1])!
                let intent = PlayerIntentions(rawValue: message[2])
                scenePort.players[player].nextAction = intent!
            case "victoryPoints":
                let player = Int(message[1])!
                let value = Int(message[2])!
                scenePort.players[player].victoryPoints = value
                scenePort.checkWinningConditions(who: player)
            case "oldBoot":
                let player = Int(message[1])!
                let hasBoot = Bool(message[2])!
                scenePort.bootFromMessage(player: player, hasBoot: hasBoot)
            case "gameOver":
                let announcement = "Unfortunately, you have lost...better luck next time!"
                let alert = UIAlertController(title: "GAME OVER", message: announcement, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "CONTINUE", style: .default, handler: { (action) in
                        //  END GAME AND RETURN TO MAIN MENU
                    }))
                self.present(alert, animated: true, completion: nil)
            case "sendCommodityOrResource":
                if Int(message[2])! == scenePort.myPlayerIndex {
                    let notificationBanner = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                    notificationBanner.isOpaque = false
                    notificationBanner.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.8)
                    let notificationContent = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                    notificationContent.isOpaque = false
                    notificationContent.font = UIFont(name: "Avenir-Roman", size: 14)
                    notificationContent.textColor = UIColor.lightGray
                    notificationContent.textAlignment = .center
                    switch message[1] {
                        case "BRICK":
                            scenePort.players[scenePort.myPlayerIndex].brick += 1
                            notificationContent.text = "You have just received some BRICK...congratulations!"
                            self.view?.addSubview(notificationBanner)
                            self.view?.addSubview(notificationContent)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                notificationContent.removeFromSuperview()
                                notificationBanner.removeFromSuperview()
                            })
                        case "GOLD":
                            scenePort.players[scenePort.myPlayerIndex].gold += 1
                            notificationContent.text = "You have just received some GOLD...congratulations!"
                            self.view?.addSubview(notificationBanner)
                            self.view?.addSubview(notificationContent)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                notificationContent.removeFromSuperview()
                                notificationBanner.removeFromSuperview()
                            })
                        case "SHEEP":
                            scenePort.players[scenePort.myPlayerIndex].sheep += 1
                            notificationContent.text = "You have just received some SHEEP...congratulations!"
                            self.view?.addSubview(notificationBanner)
                            self.view?.addSubview(notificationContent)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                notificationContent.removeFromSuperview()
                                notificationBanner.removeFromSuperview()
                            })
                        case "STONE":
                            scenePort.players[scenePort.myPlayerIndex].stone += 1
                            notificationContent.text = "You have just received some STONE...congratulations!"
                            self.view?.addSubview(notificationBanner)
                            self.view?.addSubview(notificationContent)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                notificationContent.removeFromSuperview()
                                notificationBanner.removeFromSuperview()
                            })
                        case "WHEAT":
                            scenePort.players[scenePort.myPlayerIndex].wheat += 1
                            notificationContent.text = "You have just received some WHEAT...congratulations!"
                            self.view?.addSubview(notificationBanner)
                            self.view?.addSubview(notificationContent)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                notificationContent.removeFromSuperview()
                                notificationBanner.removeFromSuperview()
                            })
                        case "WOOD":
                            scenePort.players[scenePort.myPlayerIndex].wood += 1
                            notificationContent.text = "You have just received some WOOD...congratulations!"
                            self.view?.addSubview(notificationBanner)
                            self.view?.addSubview(notificationContent)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                notificationContent.removeFromSuperview()
                                notificationBanner.removeFromSuperview()
                            })
                        case "COIN":
                            scenePort.players[scenePort.myPlayerIndex].coin += 1
                            notificationContent.text = "You have just received some COIN...congratulations!"
                            self.view?.addSubview(notificationBanner)
                            self.view?.addSubview(notificationContent)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                notificationContent.removeFromSuperview()
                                notificationBanner.removeFromSuperview()
                            })
                        case "PAPER":
                            scenePort.players[scenePort.myPlayerIndex].paper += 1
                            notificationContent.text = "You have just received some PAPER...congratulations!"
                            self.view?.addSubview(notificationBanner)
                            self.view?.addSubview(notificationContent)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                notificationContent.removeFromSuperview()
                                notificationBanner.removeFromSuperview()
                            })
                        case "CLOTH":
                            scenePort.players[scenePort.myPlayerIndex].cloth += 1
                            notificationContent.text = "You have just received some CLOTH...congratulations!"
                            self.view?.addSubview(notificationBanner)
                            self.view?.addSubview(notificationContent)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                notificationContent.removeFromSuperview()
                                notificationBanner.removeFromSuperview()
                            })
                        default: break
                    }
                }
            case "weddingCard":
                if scenePort.players[scenePort.myPlayerIndex].victoryPoints > scenePort.players[Int(message[1])!].victoryPoints { scenePort.weddingCardDiscard(receiverIndex: Int(message[1])!) }
            case "loseOneOf":
                if Int(message[2])! == scenePort.myPlayerIndex {
                    switch message[1] {
                        case "BRICK": scenePort.players[scenePort.myPlayerIndex].brick -= 1
                        case "SHEEP": scenePort.players[scenePort.myPlayerIndex].sheep -= 1
                        case "STONE": scenePort.players[scenePort.myPlayerIndex].stone -= 1
                        case "WHEAT": scenePort.players[scenePort.myPlayerIndex].wheat -= 1
                        case "WOOD": scenePort.players[scenePort.myPlayerIndex].wood -= 1
                        case "COIN": scenePort.players[scenePort.myPlayerIndex].coin -= 1
                        case "PAPER": scenePort.players[scenePort.myPlayerIndex].paper -= 1
                        case "CLOTH": scenePort.players[scenePort.myPlayerIndex].cloth -= 1
                        default: break
                    }
                    let notificationBanner = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                    notificationBanner.isOpaque = false
                    notificationBanner.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.8)
                    let notificationContent = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view!.bounds.width, height: self.view!.bounds.height / 8))
                    notificationContent.isOpaque = false
                    notificationContent.font = UIFont(name: "Avenir-Roman", size: 14)
                    notificationContent.textColor = UIColor.lightGray
                    notificationContent.textAlignment = .center
                    notificationContent.text = "You have just lost a \(message[1])..."
                    self.view?.addSubview(notificationBanner)
                    self.view?.addSubview(notificationContent)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        notificationContent.removeFromSuperview()
                        notificationBanner.removeFromSuperview()
                    })
                }
            case "resourcesHasBeenStolen":
                switch message[1] {
                    case "BRICK":
                        if scenePort.players[scenePort.myPlayerIndex].brick > 1 { scenePort.players[scenePort.myPlayerIndex].brick -= 2 }
                        else if scenePort.players[scenePort.myPlayerIndex].brick > 0 { scenePort.players[scenePort.myPlayerIndex].brick -= 1 }
                    case "SHEEP":
                        if scenePort.players[scenePort.myPlayerIndex].sheep > 1 { scenePort.players[scenePort.myPlayerIndex].sheep -= 2 }
                        else if scenePort.players[scenePort.myPlayerIndex].sheep > 0 { scenePort.players[scenePort.myPlayerIndex].sheep -= 1 }
                    case "STONE":
                        if scenePort.players[scenePort.myPlayerIndex].stone > 1 { scenePort.players[scenePort.myPlayerIndex].stone -= 2 }
                        else if scenePort.players[scenePort.myPlayerIndex].stone > 0 { scenePort.players[scenePort.myPlayerIndex].stone -= 1 }
                    case "WHEAT":
                        if scenePort.players[scenePort.myPlayerIndex].wheat > 1 { scenePort.players[scenePort.myPlayerIndex].wheat -= 2 }
                        else if scenePort.players[scenePort.myPlayerIndex].wheat > 0 { scenePort.players[scenePort.myPlayerIndex].wheat -= 1 }
                    case "WOOD":
                        if scenePort.players[scenePort.myPlayerIndex].wood > 1 { scenePort.players[scenePort.myPlayerIndex].wood -= 2 }
                        else if scenePort.players[scenePort.myPlayerIndex].wood > 0 { scenePort.players[scenePort.myPlayerIndex].wood -= 1 }
                    case "COIN": if scenePort.players[scenePort.myPlayerIndex].coin > 0 { scenePort.players[scenePort.myPlayerIndex].coin -= 1 }
                    case "PAPER": if scenePort.players[scenePort.myPlayerIndex].paper > 0 { scenePort.players[scenePort.myPlayerIndex].paper -= 1 }
                    case "CLOTH": if scenePort.players[scenePort.myPlayerIndex].cloth > 0 { scenePort.players[scenePort.myPlayerIndex].cloth -= 1 }
                    default: break
                }
                switch message[2] {
                    case "1":
                        let announcement = "Someone has used a Commodity Monopoly card on you over " + message[1] + "..."
                        let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "CONTINUE", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    case "2":
                        let announcement = "Someone has used a Resource Monopoly card on you over " + message[1] + "..."
                        let alert = UIAlertController(title: "Alert", message: announcement, preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "CONTINUE", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    default: break
                }
            default:
                print("Unknown message")
        }
    }
    
    @IBAction func didInteractWithAdditionalButtonA(_ sender: Any) {
    }
    
    @IBAction func didInteractWithAdditionalButtonB(_ sender: Any) {
    }
    
    @IBAction func toggleMusicPlayback(_ sender: Any) {
        if backgroundMusicPlayer != nil && !muted {
            muted = true
            backgroundMusicPlayer.stop()
            backgroundMusicPlayer = nil
        } else {
            do {
                muted = false
                let music = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "background.mp3", ofType: nil)!))
                backgroundMusicPlayer = music
                backgroundMusicPlayer.numberOfLoops = -1
                backgroundMusicPlayer.play()
            } catch { }
    }   }
    
    @IBAction func endCurrentPlayerTurn(_ sender: Any) {
        //  REPLACES END TURN FOR CURRENT PLAYER FROM SCENE FILE
        //  CURRENTLY DOES NOTHING AT ALL
    }
    
    
    func foundPeer() {}
    func lostPeer() {}
    
    // Decline invitation
    func invitationWasReceived(fromPeer: MCPeerID) { self.appDelegate.networkManager.invitationHandler(false, nil) }
    // Will never connect
    func connectedWithPeer(peerID: MCPeerID) {}
    // If a player leaves the game...
    func lostConnectionWith(peerID: MCPeerID) {
        let date = Date()
        let form = DateFormatter()
        form.timeStyle = .medium
        form.dateStyle = .medium
        let file = form.string(from: date)
        
        print ("LOST PEER: autosaving")
        scenePort.saveGame(filename: file)
    }
}
