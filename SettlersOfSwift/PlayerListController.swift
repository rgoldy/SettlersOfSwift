//
//  TableViewController.swift
//  SettlersOfSwift
//
//  Created by Riley Goldman on 1/26/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PlayerListController: UITableViewController, NetworkDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.networkManager.delegate = self
        
        appDelegate.networkManager.disconnect()
        appDelegate.networkManager.setInvisible()
        appDelegate.networkManager.startBrowsing()
        
        tblView.dataSource = self
        tblView.delegate = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate.networkManager.disconnect()
        appDelegate.networkManager.setInvisible()
        appDelegate.networkManager.startBrowsing()
        
        appDelegate.networkManager.delegate = self
    }
    
    func foundPeer() { tblView.reloadData() }
    func lostPeer() { tblView.reloadData() }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // Only use 1 section, always
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    // Sets length of list to number of found users
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return appDelegate.networkManager.nearbyUsers.count
    }

    // Adds found users to list
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellPeer")! as UITableViewCell
        
        // Configure the cell...
        cell.textLabel?.text = appDelegate.networkManager.nearbyUsers[indexPath.row].displayName

        return cell
    }

    // Sets row height
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    

    // Table cell selected -> ask to connect with user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection Detected.")
        let selectedPeer = appDelegate.networkManager.nearbyUsers[indexPath.row] as MCPeerID
        
        appDelegate.networkManager.serviceBrowser.invitePeer(selectedPeer, to: self.appDelegate.networkManager.session, withContext: nil, timeout: 20)
        
        print("Invited peer: \(selectedPeer.displayName).")
    }
    
    // Invitation recieved
    func invitationWasReceived(fromPeer: MCPeerID) {
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
    
    // Connected with a peer
    func connectedWithPeer(peerID: MCPeerID) {
        print("Connected to \(peerID.displayName)")
        appDelegate.networkManager.isHost = false
        OperationQueue.main.addOperation { () -> Void in
            self.performSegue(withIdentifier: "goToLobby", sender: self)
        }
    }
    
    func recievedData(data: String) {
        // do nothing
    }
    
    func lostConnectionWith(peerID: MCPeerID)
    {
        tblView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
