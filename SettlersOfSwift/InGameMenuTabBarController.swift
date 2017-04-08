//
//  InGameMenuTabBarController.swift
//  SettlersOfSwift
//
//  Created by YIFFY on 3/31/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

class InGameMenuTabBarController: UITabBarController {
    
    var gameDataReference: GameViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameDataReference = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! GameViewController
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//        self.tabBar.items?[0].isEnabled = gameDataReference.scenePort.myPlayerIndex == gameDataReference.scenePort.currentPlayer    //  disallows charts
//        self.tabBar.items?[1].isEnabled = gameDataReference.scenePort.myPlayerIndex == gameDataReference.scenePort.currentPlayer    //  disallows trade
//        self.tabBar.items?[2].isEnabled = gameDataReference.scenePort.myPlayerIndex == gameDataReference.scenePort.currentPlayer    //  disallows cards
//        self.selectedViewController = self.viewControllers?[3]
        //  CUSTOMIZE TAB BAR APPEARANCE HERE
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
