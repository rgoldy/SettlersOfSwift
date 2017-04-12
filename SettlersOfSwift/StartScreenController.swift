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
//        let game = "GAMEBOARD|2,6,1,2;3,6,1,11;4,6,1,4;1,5,2,6;2,5,2,3;3,5,4,6;4,5,4,5;5,5,3,9;1,4,3,5;2,4,0,11;3,4,3,10;4,4,3,10;5,4,0,8;3,3,0,8;7,5,2,8;7,4,5,12;6,3,5,4;1,2,1,10;2,2,2,5;4,2,3,3;5,2,4,9;6,2,4,4;0,8,6,0;1,8,6,0;2,8,6,0;3,8,6,0;4,8,6,0;5,8,6,0;6,8,6,0;7,8,6,0;8,8,6,0;0,7,6,0;1,7,6,0;2,7,6,0;3,7,6,0;4,7,6,0;5,7,6,0;6,7,6,0;7,7,6,0;8,7,6,0;0,6,6,0;1,6,6,0;5,6,6,0;6,6,6,0;7,6,6,0;8,6,6,0;0,5,6,0;6,5,6,0;8,5,6,0;0,4,6,0;6,4,6,0;8,4,6,0;0,3,6,0;1,3,6,0;2,3,6,0;4,3,6,0;5,3,6,0;7,3,6,0;8,3,6,0;0,2,6,0;3,2,6,0;7,2,6,0;8,2,6,0;0,1,6,0;1,1,6,0;2,1,6,0;3,1,6,0;4,1,6,0;5,1,6,0;6,1,6,0;7,1,6,0;8,1,6,0;0,0,6,0;1,0,6,0;2,0,6,0;3,0,6,0;4,0,6,0;5,0,6,0;6,0,6,0;7,0,6,0;8,0,6,0;.PLAYER|Riley|0|Red|4|4|4|4|4|4|4|4|4|4|4|2|10|4|10|4|10|4|4|3|true|2|2|2|false|false|false|WillDoNothing|1|0|0|0|false|false.PLAYERCORNERS|0|10,7,Settlement,false,false,General|10,9,City,false,false,General.PLAYEREDGES|0|8,9,Road,false|8,12,Road,false.PLAYERKNIGHTS|0.PLAYERPROGRESSCARDS|0|Engineer|Spy|CommercialHarbor|MasterMerchant|MerchantFleet.PLAYER|Riley’s MacBook Pro|1|Blue|4|4|4|4|4|4|4|4|4|4|4|2|10|4|10|4|10|4|4|3|false|2|2|2|false|false|false|WillDoNothing|1|0|0|0|false|false.PLAYERCORNERS|1|9,4,Settlement,false,false,General|11,1,City,false,true,Wood.PLAYEREDGES|1|7,7,Road,false|9,2,Road,false.PLAYERKNIGHTS|1.PLAYERPROGRESSCARDS|1|Engineer|Spy|CommercialHarbor|MasterMerchant|MerchantFleet.PLAYER|Mario|2|Orange|4|4|4|4|4|4|4|4|4|4|4|2|10|4|10|4|10|4|4|3|false|2|2|2|false|false|false|WillDoNothing|1|0|0|0|false|false.PLAYERCORNERS|2|12,4,Settlement,false,false,General|15,4,City,false,true,General.PLAYEREDGES|2|10,6,Road,false|13,6,Road,false.PLAYERKNIGHTS|2.PLAYERPROGRESSCARDS|2|Engineer|Spy|CommercialHarbor|MasterMerchant|MerchantFleet.GAMEPROGRESSCARDS|ResourceMonopoly|MerchantFleet|Bishop|Inventor|Warlord|ResourceMonopoly|Printer|Spy|Wedding|Deserter|Spy|Saboteur|Merchant|Inventor|CommercialHarbor|MasterMerchant|CommercialHarbor|Alchemist|Saboteur|ResourceMonopoly|Spy|TradeMonopoly|Intrigue|Smith|Mining|Merchant|Merchant|Medicine|Deserter|Diplomat|RoadBuilding|Bishop|Intrigue|Alchemist|MasterMerchant|Medicine|TradeMonopoly|Wedding|Mining|Merchant|Irrigation|Engineer|RoadBuilding|Merchant|Smith|Warlord|Diplomat|Irrigation|MerchantFleet|Constitution|Merchant|ResourceMonopoly.GAMEFISHDECK|3|1|2|1|2|2|2|1|1|1|2|2|2|3|1|3|1|3|2|1|3|1|3|1|3|1|2|2|3.GAMEDATA|p3Turn|2|5|6|2|false|false|false|false|false|false|false|false|false|6|0|-1"
//        
//        saveFile("Year of Plenty", game)
//    }
//    
//    func saveFile(_ filename: String, _ game: String) {
//        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        //let fileURL = DocumentDirURL.appendingPathComponent("settlersofswift/\(filename)")
//        let fileURL = DocumentDirURL.appendingPathComponent(filename)
//        
//        do {
//        try game.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
//        }
//        catch let error as NSError {
//        print("Failed writing to URL: \(fileURL), Error: \(error.localizedDescription)")
//        }
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
