//
//  ViewController.swift
//  SettlersOfSwift
//
//  Created by Riley Goldman on 2/9/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

class StartScreenController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.networkManager.setInvisible()
        appDelegate.networkManager.stopBrowsing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        appDelegate.networkManager.setInvisible()
        appDelegate.networkManager.stopBrowsing()
        appDelegate.networkManager.nearbyUsers.removeAll()
        self.navigationController?.navigationBar.isHidden = false;
        appDelegate.networkManager.disconnect()
        appDelegate.networkManager.delegate = nil
        appDelegate.networkManager.loadData = "nil"
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

}
