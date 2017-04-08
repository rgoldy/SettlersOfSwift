//
//  InGameStatisticsViewController.swift
//  SettlersOfSwift
//
//  Created by YIFFY on 3/31/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

class InGameStatisticsViewController: UIViewController {

    @IBOutlet weak var firstPlayerDescription: UITextView!
    @IBOutlet weak var secondPlayerDescription: UITextView!
    @IBOutlet weak var thirdPlayerDescription: UITextView!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let playerIndex = gameDataReference.scenePort.myPlayerIndex
        firstPlayerDescription.font = UIFont(name: "Avenir-Roman", size: 14)
        firstPlayerDescription.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        firstPlayerDescription.textColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        firstPlayerDescription.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        firstPlayerDescription.text = getPlayerDescription(playerIndex: playerIndex, isPlayer: true)
//        secondPlayerDescription.font = UIFont(name: "Avenir-Roman", size: 14)
//        secondPlayerDescription.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        secondPlayerDescription.textColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
//        secondPlayerDescription.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        secondPlayerDescription.text = getPlayerDescription(playerIndex: (playerIndex + 1) % 3, isPlayer: false)
//        thirdPlayerDescription.font = UIFont(name: "Avenir-Roman", size: 14)
//        thirdPlayerDescription.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        thirdPlayerDescription.textColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
//        thirdPlayerDescription.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        thirdPlayerDescription.text = getPlayerDescription(playerIndex: (playerIndex + 2) % 3, isPlayer: false)
    }
    
    func getPlayerDescription(playerIndex: Int, isPlayer: Bool) -> String {
        let somePlayer = gameDataReference.scenePort.players[playerIndex]
        var description = ""
        description += somePlayer.name + "(" + somePlayer.color.rawValue + ")\n\n"
        description += "{ . . . }"
        //  COMPOSE STRING TO RETURN WITH DETAILED PLAYER DESCRIPTION
        return description
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
