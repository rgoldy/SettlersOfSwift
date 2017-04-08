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
    
    var currentDisplayIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  MIGHT HAVE TO MODIFY BELOW CODE TO viewWillAppear(Bool) METHOD TO BE COMPATIBLE WITH SAVE LOADING
        gameDataReference = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! GameViewController
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentDisplayIndex = 0
        updateCardsDisplayWithStartingIndex(currentDisplayIndex)
    }

    func updateCardsDisplayWithStartingIndex(_ index: Int) {
        let player = gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex]
        if player.progressCards.count < 3 {
            switch player.progressCards.count {
                case 0:
                    firstCard.image = UIImage.init(named: "NoCard")
                    secondCard.image = UIImage.init(named: "NoCard")
                    thirdCard.image = UIImage.init(named: "NoCard")
                case 1:
                    firstCard.image = UIImage.init(named: "\(player.progressCards[0])")
                    secondCard.image = UIImage.init(named: "NoCard")
                    thirdCard.image = UIImage.init(named: "NoCard")
                case 2:
                    firstCard.image = UIImage.init(named: "\(player.progressCards[0])")
                    secondCard.image = UIImage.init(named: "\(player.progressCards[1])")
                    thirdCard.image = UIImage.init(named: "NoCard")
                default: break
            }
        } else {
            firstCard.image = UIImage.init(named: "\(player.progressCards[index % player.progressCards.count])")
            secondCard.image = UIImage.init(named: "\(player.progressCards[(index + 1) % player.progressCards.count])")
            thirdCard.image = UIImage.init(named: "\(player.progressCards[(index + 2) % player.progressCards.count])")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPreviousCards(_ sender: Any) {
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count <= 3 { updateCardsDisplayWithStartingIndex(0) }
        else {
            currentDisplayIndex += gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count - 1
            updateCardsDisplayWithStartingIndex(currentDisplayIndex)
    }   }
    
    @IBAction func showFollowingCards(_ sender: Any) {
        if gameDataReference.scenePort.players[gameDataReference.scenePort.myPlayerIndex].progressCards.count <= 3 { updateCardsDisplayWithStartingIndex(0) }
        else {
            currentDisplayIndex += 1
            updateCardsDisplayWithStartingIndex(currentDisplayIndex)
    }   }
    
    @IBAction func didInteractWithLeftCard(_ sender: Any) {
        //  IMPLEMENTATION OF USER INTERACTION WITH LEFT CARD
        //  RESET INDEX AND REFRESH
    }
    
    @IBAction func didInteractWithMiddleCard(_ sender: Any) {
        //  IMPLEMENTATION OF USER INTERACTION WITH MIDDLE CARD
        //  RESET INDEX AND REFRESH
    }
    
    @IBAction func didInteractWithRightCard(_ sender: Any) {
        //  IMPLEMENTATION OF USER INTERACTION WITH RIGHT CARD
        //  RESET INDEX AND REFRESH
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
