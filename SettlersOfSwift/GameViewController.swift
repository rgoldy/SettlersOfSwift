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

class GameViewController: UIViewController, NetworkDelegate {
    
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
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Added by Riley...
    func updateGUI() {
        
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
                updateGUI()
                print("Updated Scene")
            case "readyToPlay":
                readyPlayers += 1
            default: print("Unknown message")
        }
    }
    
    // Do nothing
    func foundPeer() {}
    func lostPeer() {}
    
    // Decline invitation
    func invitationWasReceived(fromPeer: MCPeerID) { self.appDelegate.networkManager.invitationHandler(false, nil) }
    // Will never connect
    func connectedWithPeer(peerID: MCPeerID) {}
    // If a player leaves the game...
    func lostConnectionWith(peerID: MCPeerID) { /* TODO */ }
}
