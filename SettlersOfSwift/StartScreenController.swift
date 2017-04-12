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
//        let game = "GAMEBOARD|2,6,1,2;3,6,1,11;4,6,1,4;1,5,2,6;2,5,2,3;3,5,4,6;4,5,4,5;5,5,3,9;1,4,3,5;2,4,0,11;3,4,3,10;4,4,3,10;5,4,0,8;3,3,0,8;7,5,2,8;7,4,5,12;6,3,5,4;1,2,1,10;2,2,2,5;4,2,3,3;5,2,4,9;6,2,4,4;0,8,6,0;1,8,6,0;2,8,6,0;3,8,6,0;4,8,6,0;5,8,6,0;6,8,6,0;7,8,6,0;8,8,6,0;0,7,6,0;1,7,6,0;2,7,6,0;3,7,6,0;4,7,6,0;5,7,6,0;6,7,6,0;7,7,6,0;8,7,6,0;0,6,6,0;1,6,6,0;5,6,6,0;6,6,6,0;7,6,6,0;8,6,6,0;0,5,6,0;6,5,6,4;8,5,6,5;0,4,6,0;6,4,6,0;8,4,6,0;0,3,6,0;1,3,6,0;2,3,6,8;4,3,6,0;5,3,6,0;7,3,6,0;8,3,6,0;0,2,6,0;3,2,6,0;7,2,6,6;8,2,6,0;0,1,6,0;1,1,6,9;2,1,6,0;3,1,6,0;4,1,6,0;5,1,6,10;6,1,6,0;7,1,6,0;8,1,6,0;0,0,6,0;1,0,6,0;2,0,6,0;3,0,6,0;4,0,6,0;5,0,6,0;6,0,6,0;7,0,6,0;8,0,6,0;.PLAYER|Riley|0|Red|1|4|1|4|1|4|1|4|1|4|1|2|1|4|1|4|1|4|1|10|true|3|-1|-1|false|true|false|WillDoNothing|8|0|0|0|false|false.PLAYERCORNERS|0|10,7,City,false,false,General|11,10,City,false,false,General|10,9,Metropolis,true,false,General|6,9,City,false,false,General.PLAYEREDGES|0|8,9,Road,false|8,12,Road,false|7,11,Road,false|8,10,Road,false|8,8,Road,false|8,13,Boat,false|9,14,Road,false|10,14,Road,false|7,12,Boat,false|6,12,Road,false|5,12,Road,false.PLAYERKNIGHTS|0|9,5,1,false,false,false|9,7,3,true,false,false.PLAYERPROGRESSCARDS|0|Engineer|Spy|CommercialHarbor|MasterMerchant|MerchantFleet.PLAYER|iPhone|1|Blue|1|4|1|4|1|4|1|4|1|4|1|2|1|4|1|4|1|4|0|6|false|-1|-1|3|false|false|false|WillDoNothing|7|0|0|0|false|false.PLAYERCORNERS|1|9,4,City,false,false,General|11,1,City,false,true,Wood|9,4,City,false,false,General.PLAYEREDGES|1|7,7,Road,false|9,2,Road,false|8,2,Road,false|7,3,Road,false|7,4,Road,false|6,5,Road,false|7,6,Road,false.PLAYERKNIGHTS|1|9,1,2,false,false,false|8,4,1,false,false,false.PLAYERPROGRESSCARDS|1|Engineer|Spy|CommercialHarbor|MasterMerchant|MerchantFleet|RoadBuilding.PLAYER|Mario|2|Orange|1|4|1|4|1|4|1|4|1|4|1|2|1|4|1|4|1|4|0|12|false|3|5|4|true|false|true|WillDoNothing|14|0|0|0|false|false.PLAYERCORNERS|2|15,4,Metropolis,true,true,General|12,4,Metropolis,true,false,General|13,11,City,false,false,General.PLAYEREDGES|2|10,6,Road,false|13,6,Road,false|12,6,Road,false|11,6,Road,false|9,6,Road,false|13,7,Road,false|13,8,Road,false|12,9,Boat,false|13,10,Boat,false|12,10,Boat,false|11,11,Boat,false|12,12,Boat,false|12,13,Boat,false|12,14,Boat,true|11,15,Boat,true.PLAYERKNIGHTS|2|13,4,1,false,false,false|14,6,2,true,false,false.PLAYERPROGRESSCARDS|2|Engineer|Spy|CommercialHarbor|MasterMerchant|MerchantFleet|Crane|Bishop.GAMEPROGRESSCARDS|CommercialHarbor|Merchant|Merchant|Spy|ResourceMonopoly|Alchemist|Crane|Printer|Crane|Engineer|Saboteur|Warlord|Merchant|Mining|TradeMonopoly|ResourceMonopoly|Smith|Intrigue|Smith|Saboteur|Inventor|MasterMerchant|Merchant|Irrigation|Bishop|Wedding|Merchant|Medicine|Irrigation|RoadBuilding|Merchant|Inventor|Wedding|Deserter|Medicine|Spy|Alchemist|ResourceMonopoly|Deserter|Diplomat|MasterMerchant|CommercialHarbor|Bishop|Intrigue|Spy|Constitution|Diplomat|TradeMonopoly|Mining|ResourceMonopoly|MerchantFleet|MerchantFleet|Warlord|Medicine|MasterMerchant|MasterMerchant|Mining|Warlord|ResourceMonopoly|Alchemist|Spy|Inventor|Wedding|TradeMonopoly|Saboteur|Merchant|RoadBuilding|Alchemist|Irrigation|Irrigation|CommercialHarbor|ResourceMonopoly|MerchantFleet|Merchant|Mining|ResourceMonopoly|Deserter|Merchant|TradeMonopoly|Printer|Wedding|RoadBuilding|Deserter|Spy|Crane|Bishop|Engineer|ResourceMonopoly|Merchant|Warlord|MerchantFleet|Spy|Saboteur|Smith|Inventor|Medicine|Crane|Intrigue|CommercialHarbor|Smith|Constitution|Diplomat|Diplomat|Merchant|Intrigue|Merchant|CommercialHarbor|Mining|CommercialHarbor|Mining|Alchemist|ResourceMonopoly|Smith|Merchant|Bishop|TradeMonopoly|Warlord|Constitution|Bishop|Merchant|Wedding|MasterMerchant|Irrigation|RoadBuilding|Medicine|Spy|Intrigue|Diplomat|Inventor|Wedding|RoadBuilding|MasterMerchant|Merchant|TradeMonopoly|MerchantFleet|Irrigation|Warlord|Saboteur|Alchemist|Merchant|ResourceMonopoly|Saboteur|Crane|ResourceMonopoly|Deserter|Printer|Medicine|Diplomat|Merchant|Deserter|Spy|Engineer|ResourceMonopoly|Crane|MerchantFleet|Inventor|Intrigue|Smith|Merchant|Spy|Irrigation|Deserter|Diplomat|Bishop|Saboteur|Spy|TradeMonopoly|ResourceMonopoly|Diplomat|Merchant|Wedding|Merchant|Wedding|Alchemist|Inventor|Mining|Crane|TradeMonopoly|Alchemist|MasterMerchant|MasterMerchant|Spy|ResourceMonopoly|Spy|Warlord|CommercialHarbor|Intrigue|ResourceMonopoly|MerchantFleet|Merchant|Warlord|Deserter|Saboteur|Merchant|ResourceMonopoly|MerchantFleet|Engineer|Smith|Mining|Inventor|CommercialHarbor|Intrigue|Medicine|Merchant|Merchant|Printer|Medicine|RoadBuilding|Bishop|Irrigation|Smith|Constitution|RoadBuilding|Crane|Medicine|MasterMerchant|Bishop|Deserter|Saboteur|Saboteur|CommercialHarbor|Engineer|Alchemist|Merchant|CommercialHarbor|ResourceMonopoly|Diplomat|TradeMonopoly|Deserter|Wedding|Medicine|Spy|Merchant|Irrigation|RoadBuilding|Wedding|Warlord|Intrigue|Merchant|Printer|ResourceMonopoly|Smith|Inventor|Spy|Smith|MerchantFleet|Inventor|MerchantFleet|ResourceMonopoly|Merchant|Crane|Mining|Merchant|MasterMerchant|TradeMonopoly|Mining|Warlord|Constitution|ResourceMonopoly|Irrigation|Spy|Intrigue|Merchant|Diplomat|Alchemist|Bishop|RoadBuilding|ResourceMonopoly|Alchemist|TradeMonopoly|Wedding|Smith|MasterMerchant|MerchantFleet|CommercialHarbor|Printer|Spy|Crane|TradeMonopoly|Merchant|Merchant|Deserter|Smith|Alchemist|Spy|Crane|Saboteur|RoadBuilding|Mining|Engineer|Inventor|Mining|Bishop|Merchant|ResourceMonopoly|ResourceMonopoly|Intrigue|Warlord|MerchantFleet|RoadBuilding|ResourceMonopoly|Diplomat|Merchant|Constitution|Deserter|Medicine|Diplomat|Bishop|Merchant|Saboteur|Merchant|MasterMerchant|Intrigue|Wedding|Inventor|Medicine|Warlord|Irrigation|Irrigation|CommercialHarbor|Spy|ResourceMonopoly|MerchantFleet|Bishop|Inventor|Warlord|ResourceMonopoly|Printer|Spy|Wedding|Deserter|Spy|Saboteur|Merchant|Inventor|CommercialHarbor|MasterMerchant|CommercialHarbor|Alchemist|Saboteur|ResourceMonopoly|Spy|TradeMonopoly|Intrigue|Smith|Mining|Merchant|Merchant|Medicine|Deserter|Diplomat|RoadBuilding|Bishop|Intrigue|Alchemist|MasterMerchant|Medicine|TradeMonopoly|Wedding|Mining|Merchant|Irrigation|Engineer|RoadBuilding|Merchant|Smith|Warlord|Diplomat|Irrigation|MerchantFleet|Constitution|Merchant|ResourceMonopoly.GAMEFISHDECK|3|1|2|1|2|2|2|1|1|1|2|2|2|3|1|3|1|3|2|1|3|1|3|1|3|1|2|2|3.GAMEDATA|p3Turn|6|3|5|2|false|false|false|false|false|false|false|false|false|2|14|2"
//        
//        saveFile("Winning", game)
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
