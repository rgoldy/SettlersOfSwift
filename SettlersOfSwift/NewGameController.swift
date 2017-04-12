//
//  ViewController.swift
//  SettlersOfSwift
//
//  Created by Riley Goldman on 2/9/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class NewGameController: UITableViewController, NetworkDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let numberOfPlayers = 3
    var players : [String] = []
    
    @IBOutlet var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate.networkManager.delegate = self
        
        appDelegate.networkManager.setVisible()
        appDelegate.networkManager.startBrowsing()
        
        tblView.dataSource = self
        tblView.delegate = self
        
        players = extractPlayerNames(appDelegate.networkManager.loadData)
        print ("\(players.count) player game")
        
        if (appDelegate.networkManager.loadData == "nil" && appDelegate.networkManager.session.connectedPeers.count + 1 == numberOfPlayers)
        {
            startGame()
        }
        else if (appDelegate.networkManager.session.connectedPeers.count + 1 == players.count)
        {
            startGame()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate.networkManager.setVisible()
        appDelegate.networkManager.startBrowsing()
        
        appDelegate.networkManager.delegate = self
    }

    func foundPeer() { tblView.reloadData() }
    func lostPeer() { tblView.reloadData() }
    
    // Invitation recieved
    func invitationWasReceived(fromPeer: MCPeerID) {
        if (appDelegate.networkManager.loadData == "nil") {
            let alert = UIAlertController(title: "", message: "\(fromPeer.displayName) wants to play Catan with you.", preferredStyle: UIAlertControllerStyle.alert)
            
            let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
                self.appDelegate.networkManager.invitationHandler(true, self.appDelegate.networkManager.session)
            }
            
            let declineAction = UIAlertAction(title: "Decline", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
                self.appDelegate.networkManager.invitationHandler(false, nil)
            }
            
            alert.addAction(acceptAction)
            alert.addAction(declineAction)
            
            OperationQueue.main.addOperation { () -> Void in
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            print ("Invitation from \(fromPeer.displayName)")
            for name in players {
                if name == fromPeer.displayName {
                    print ("found \(fromPeer.displayName) in save")
                    self.appDelegate.networkManager.invitationHandler(true, self.appDelegate.networkManager.session)
                    return
                }
            }
            print ("\(fromPeer.displayName) not in save")
            self.appDelegate.networkManager.invitationHandler(false, nil)
        }
    }
    
    func extractPlayerNames(_ data: String) -> [String] {
        if data == "nil" { return [] }
        var players : [String] = []
        let gameState = appDelegate.networkManager.loadData
        let unitData = gameState.components(separatedBy: ".")
        for unit in unitData {
            let data = unit.components(separatedBy: "|")
            if (data[0] == "PLAYER") {
                let name = data[1]
                print ("\tplayer \(name) in game.")
                players.append(name)
            }
        }
        return players
    }
    
    // Connected with a peer
    func connectedWithPeer(peerID: MCPeerID) {
        tblView.reloadData()

        if appDelegate.networkManager.loadData == "nil" {
            if (appDelegate.networkManager.session.connectedPeers.count == numberOfPlayers - 1)
            {
                startGame()
            }
        }
        else {
            let _ = appDelegate.networkManager.sendData(data: appDelegate.networkManager.loadData)
            if (appDelegate.networkManager.session.connectedPeers.count == players.count - 1)
            {
                startGame()
            }
        }
    }
    
    func lostConnectionWith(peerID: MCPeerID) {
        tblView.reloadData()
    }
    
    func recievedData(data: String) {
        let message = data.components(separatedBy: ".")
        if (message[0] == "readyToPlay") {
            appDelegate.networkManager.readyPlayers += 1
        }
        else {
            appDelegate.networkManager.loadData = data
            players = extractPlayerNames(data)
            if (appDelegate.networkManager.session.connectedPeers.count + 1 == players.count)
            {
                startGame()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Only use 1 section, always
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    // Sets length of list to number of found users
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return appDelegate.networkManager.session.connectedPeers.count + 1
    }
    
    // Adds found users to list
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellPeer2")! as UITableViewCell
        
        // Configure the cell...
        if (indexPath.row == 0) {
            cell.textLabel?.text = appDelegate.networkManager.getName()
        }
        else {
            cell.textLabel?.text = appDelegate.networkManager.session.connectedPeers[indexPath.row-1].displayName
        }
        
        return cell
    }
    
    // Sets row height
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    // Row selected -> connect to user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection Detected at \(indexPath.row).")
        
        if (indexPath.row == 0){
            return
        }
        
        let selectedPeer = appDelegate.networkManager.session.connectedPeers[indexPath.row-1] as MCPeerID
        //appDelegate.networkManager.sendDataTo(data: "Hello World!", player: selectedPeer)
        print("Selected: \(selectedPeer.displayName)")
    }
    
    func startGame()
    {
        OperationQueue.main.addOperation { () -> Void in
            self.performSegue(withIdentifier: "startGame", sender: self)
        }
    }

}
