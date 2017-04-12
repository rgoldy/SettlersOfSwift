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
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "menuBackground")!)
        let playerIndex = gameDataReference.scenePort.myPlayerIndex
        firstPlayerDescription.font = UIFont(name: "Avenir-Roman", size: 12)
        firstPlayerDescription.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        firstPlayerDescription.textColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        firstPlayerDescription.backgroundColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.75)
        firstPlayerDescription.text = getPlayerDescription(playerIndex: playerIndex, isPlayer: true)
        secondPlayerDescription.font = UIFont(name: "Avenir-Roman", size: 12)
        secondPlayerDescription.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        secondPlayerDescription.textColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
secondPlayerDescription.backgroundColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.75)
        secondPlayerDescription.text = getPlayerDescription(playerIndex: (playerIndex + 1) % 3, isPlayer: false)
        thirdPlayerDescription.font = UIFont(name: "Avenir-Roman", size: 12)
        thirdPlayerDescription.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        thirdPlayerDescription.textColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
thirdPlayerDescription.backgroundColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.75)
        thirdPlayerDescription.text = getPlayerDescription(playerIndex: (playerIndex + 2) % 3, isPlayer: false)
    }
    
    func getPlayerDescription(playerIndex: Int, isPlayer: Bool) -> String {
        let somePlayer = gameDataReference.scenePort.players[playerIndex]
        
        //  COMPOSE STRING TO RETURN WITH DETAILED PLAYER DESCRIPTION
        var description = ""
        description += somePlayer.name + "\n(" + somePlayer.color.rawValue + " Player)\n"
        description += "Victory Points: \(somePlayer.victoryPoints)\n\n"
        
        var numSet = 0
        var numCit = 0
        var numMet = 0
        for corner in gameDataReference.scenePort.players[playerIndex].ownedCorners {
            if corner.cornerObject?.type == .Settlement {
                numSet += 1
            }
            else if corner.cornerObject?.type == .City {
                numCit += 1
            }
            else {
                numMet += 1
            }
        }
        description += "Number of Settlements: \(numSet)\n"
        description += "Number of Cities: \(numCit)\n"
        description += "Number of Metropolis: \(numMet)\n"
        
        var numKnight = 0
        var totalStrength = 0
        var activeStrength = 0
        for knight in gameDataReference.scenePort.players[playerIndex].ownedKnights {
            numKnight += 1
            if (knight.cornerObject?.isActive == true) {
                activeStrength += (knight.cornerObject?.strength)!
            }
            totalStrength += (knight.cornerObject?.strength)!
        }
        description += "Number of Knights: \(numKnight)\n"
        description += "Active Knight Strength: \(activeStrength)\n"
        description += "Total Knight Strength: \(totalStrength)\n"
        
        description += "Longest Road: \(somePlayer.longestRoad)\n\n"
        
        description += "Politics Improvement Level: \(somePlayer.politicsImprovementLevel + 1)\n"
        description += "Sciences Improvement Level: \(somePlayer.sciencesImprovementLevel + 1)\n"
        description += "Trades Improvement Level: \(somePlayer.tradesImprovementLevel + 1)\n\n"
        
        description += "Barbarian Distance: \(gameDataReference.scenePort.barbariansDistanceFromCatan)\n"
        
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
