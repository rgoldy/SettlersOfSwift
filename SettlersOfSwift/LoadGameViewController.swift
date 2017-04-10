//
//  LoadGameViewController.swift
//  SettlersOfSwift
//
//  Created by Riley Goldman on 4/9/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

class LoadGameViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet var tblView: UITableView!
    
    var allFileNames : [String] = []
    var allFileContents : [String] = []
    var displayName : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tblView.dataSource = self
        tblView.delegate = self

        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let pathURL = DocumentDirURL.appendingPathComponent("settlersofswift")
        let files = FileManager.default.enumerator(at: pathURL, includingPropertiesForKeys: nil)
        for file in files! {
            if let path = NSURL(fileURLWithPath: file as! String, relativeTo: pathURL).path {
                print (path)
                allFileNames.append(path)
                let dirs = path.components(separatedBy: "/")
                displayName.append(dirs[dirs.count-1])
                do {
                    let fileContent = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
                    allFileContents.append(fileContent as String)
                }
                catch {
                    allFileNames.remove(at: allFileNames.count-1)
                    displayName.remove(at: displayName.count-1)

                }
            }
        }
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
        return allFileNames.count
    }
    
    // Adds saved games
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idGame")! as UITableViewCell
        
        // Configure the cell...
        cell.textLabel?.text = displayName[indexPath.row]
        
        return cell
    }
    
    // Sets row height
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    // Row selected -> load game
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = allFileContents[indexPath.row]
        appDelegate.networkManager.loadData = data
        joinGame()
    }
    
    func joinGame()
    {
        OperationQueue.main.addOperation { () -> Void in
            self.performSegue(withIdentifier: "goToGameLobby", sender: self)
        }
    }
}
