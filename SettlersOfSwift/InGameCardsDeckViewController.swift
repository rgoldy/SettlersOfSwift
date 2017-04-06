//
//  InGameCardsDeckViewController.swift
//  SettlersOfSwift
//
//  Created by YIFFY on 3/31/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

class InGameCardsDeckViewController: UIViewController {

    @IBOutlet weak var firstCard: UIImageView!
    @IBOutlet weak var secondCard: UIImageView!
    @IBOutlet weak var thirdCard: UIImageView!
    
    var gameDataReference: GameViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  MIGHT HAVE TO MODIFY BELOW CODE TO viewWillAppear(Bool) METHOD TO BE COMPATIBLE WITH SAVE LOADING
        gameDataReference = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! GameViewController
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPreviousCards(_ sender: Any) {
        //  IMPLEMENTATION OF RIGHT SWIPE
    }
    
    @IBAction func showFollowingCards(_ sender: Any) {
        //  IMPLEMENTATION OF LEFT SWIPE
    }
    
    @IBAction func didInteractWithLeftCard(_ sender: Any) {
        //  IMPLEMENTATION OF USER INTERACTION WITH LEFT CARD
    }
    
    @IBAction func didInteractWithMiddleCard(_ sender: Any) {
        //  IMPLEMENTATION OF USER INTERACTION WITH MIDDLE CARD
    }
    
    @IBAction func didInteractWithRightCard(_ sender: Any) {
        //  IMPLEMENTATION OF USER INTERACTION WITH RIGHT CARD
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
