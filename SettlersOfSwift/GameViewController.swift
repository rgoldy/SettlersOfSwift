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

class GameViewController: UIViewController, NetworkDelegate {
    
    //  CUSTOM BUTTONS FOR DIFFERENT PURPOSES
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backgroundMusicButton: UIButton!
    @IBOutlet weak var endCurrentTurnButton: UIButton!
    
    //  PLAYS BACKGROUND MUSIC CONTAINED IN FILE NAMED background.mp3 (NOT TESTED)
    
    var backgroundMusicPlayer: AVAudioPlayer!
    
    // Added by Riley
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var viewPort: SKView!
    var scenePort: GameScene!
    var readyPlayers = 0
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let music = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "background.mp3", ofType: nil)!))
            backgroundMusicPlayer = music
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.play()
        } catch { }
        setAppearanceForMenuButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if backgroundMusicPlayer != nil {
            backgroundMusicPlayer.stop()
            backgroundMusicPlayer = nil
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
        let playerColor = scenePort.players[scenePort.myPlayerIndex].color
        switch playerColor {
            case .Blue: menuButton.backgroundColor = UIColor.blue
            case .Orange: menuButton.backgroundColor = UIColor.orange
            case .Red: menuButton.backgroundColor = UIColor.red
        }
        //  CUSTOMIZES MENU BUTTON APPEARANCE
    }
    
    func syncBoard() {
        if (appDelegate.networkManager.isHost) {
            // Wait for all players to be ready
            while (readyPlayers < appDelegate.networkManager.session.connectedPeers.count) { /* wait */}
            
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
                    readyPlayers += 1
                }
                else {
                    readyPlayers -= 1
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
            default:
                print("Unknown message")
        }
    }
    
    @IBAction func toggleMusicPlayback(_ sender: Any) {
        if backgroundMusicPlayer != nil {
            backgroundMusicPlayer.stop()
            backgroundMusicPlayer = nil
        } else {
            do {
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
    
    // Do nothing
    func foundPeer() {}
    func lostPeer() {}
    
    // Decline invitation
    func invitationWasReceived(fromPeer: MCPeerID) { self.appDelegate.networkManager.invitationHandler(false, nil) }
    // Will never connect
    func connectedWithPeer(peerID: MCPeerID) {}
    // If a player leaves the game...
    func lostConnectionWith(peerID: MCPeerID) { /* TODO? */ }
}
