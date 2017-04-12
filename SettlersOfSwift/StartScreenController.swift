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
        //appDelegate.networkManager.loadData = "nil"
        appDelegate.networkManager.loadData = "GAMEBOARD|2,6,3,9;3,6,0,10;4,6,3,5;1,5,2,10;2,5,4,3;3,5,1,8;4,5,3,11;5,5,2,4;1,4,3,6;2,4,4,5;3,4,1,2;4,4,0,11;5,4,0,6;3,3,1,8;7,5,2,8;7,4,5,9;6,3,5,10;1,2,4,3;2,2,3,5;4,2,2,4;5,2,1,4;6,2,4,12;0,8,6,0;1,8,6,0;2,8,6,0;3,8,6,0;4,8,6,0;5,8,6,0;6,8,6,0;7,8,6,0;8,8,6,0;0,7,6,0;1,7,6,0;2,7,6,0;3,7,6,0;4,7,6,0;5,7,6,0;6,7,6,0;7,7,6,0;8,7,6,0;0,6,6,0;1,6,6,0;5,6,6,0;6,6,6,0;7,6,6,0;8,6,6,0;0,5,6,0;6,5,6,0;8,5,6,0;0,4,6,0;6,4,6,0;8,4,6,0;0,3,6,0;1,3,6,0;2,3,6,0;4,3,6,0;5,3,6,0;7,3,6,0;8,3,6,0;0,2,6,0;3,2,6,0;7,2,6,0;8,2,6,0;0,1,6,0;1,1,6,0;2,1,6,0;3,1,6,0;4,1,6,0;5,1,6,0;6,1,6,0;7,1,6,0;8,1,6,0;0,0,6,0;1,0,6,0;2,0,6,0;3,0,6,0;4,0,6,0;5,0,6,0;6,0,6,0;7,0,6,0;8,0,6,0;.PLAYER|Riley’s MacBook Pro|0|Red|100|4|100|4|100|4|100|4|100|4|100|2|100|4|100|4|100|4|100|3|false|2|2|2|false|false|false|WillDoNothing|0|0|0|0|false|false.PLAYERCORNERS|0|9,5,Settlement,false,false,General|11,7,City,false,false,General.PLAYEREDGES|0|8,8,Road,false|9,10,Road,false.PLAYERKNIGHTS|0|10,6,1,false,false,false.PLAYERPROGRESSCARDS|0|Warlord|Crane|Spy.PLAYER|Riley’s iPhone|1|Blue|100|4|100|4|100|4|100|4|100|4|100|2|100|4|100|4|100|4|100|3|false|2|2|2|false|false|false|WillDoNothing|0|0|0|0|false|false.PLAYERCORNERS|1|11,4,Settlement,false,false,General|12,3,City,true,false,General.PLAYEREDGES|1|10,6,Road,false|10,5,Road,false|9,7,Road,false|9,8,Road,false.PLAYERKNIGHTS|1|12,4,1,false,false,false.PLAYERPROGRESSCARDS|1.GAMEPROGRESSCARDS|TradeMonopoly|MerchantFleet|Printer|Alchemist|TradeMonopoly|Mining|Spy|Warlord|MasterMerchant|MerchantFleet|Smith|CommercialHarbor|Wedding|RoadBuilding|Deserter|Irrigation|RoadBuilding|Inventor|Spy|Inventor|Merchant|Diplomat|Irrigation|Merchant|ResourceMonopoly|Medicine|Wedding|Intrigue|Diplomat|Constitution|MasterMerchant|ResourceMonopoly|Merchant|Alchemist|Bishop|Mining|Deserter|Medicine|Crane|CommercialHarbor|Bishop|Saboteur|Intrigue|Merchant|Smith|ResourceMonopoly|Engineer|Merchant|ResourceMonopoly.GAMEFISHDECK|2|1|2|2|2|1|3|1|3|2|1|1|1|2|2|1|1|0|1|1|2|3|3|2|3|1|3|2|3|3.GAMEDATA|p2Turn|1|1|6|1|false|false|false|false|false|false|false|false|false|3"
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
