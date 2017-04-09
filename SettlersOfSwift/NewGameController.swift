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
    let numberOfPlayers = 2
    
    @IBOutlet var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate.networkManager.delegate = self
        
        appDelegate.networkManager.setVisible()
        appDelegate.networkManager.startBrowsing()
        
        tblView.dataSource = self
        tblView.delegate = self
        
        if (appDelegate.networkManager.session.connectedPeers.count == numberOfPlayers - 1)
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
        let alert = UIAlertController(title: "", message: "\(fromPeer.displayName) wants to play Catan with you.", preferredStyle: UIAlertControllerStyle.alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.appDelegate.networkManager.invitationHandler(true, self.appDelegate.networkManager.session)
            //self.appDelegate.networkManager.serviceBrowser.invitePeer(fromPeer, to: self.appDelegate.networkManager.session, withContext: nil, timeout: 10)
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
    
    // Connected with a peer
    func connectedWithPeer(peerID: MCPeerID) {
        tblView.reloadData()
        
        if (appDelegate.networkManager.session.connectedPeers.count == numberOfPlayers - 1)
        {
            startGame()
        }
    }
    
    func lostConnectionWith(peerID: MCPeerID) {
        tblView.reloadData()
    }
    
    func recievedData(data: String) {
        print("Received: \(data)")
        let message = data.components(separatedBy: ".")
        if (message[0] == "readyToPlay") {
            appDelegate.networkManager.readyPlayers += 1
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
