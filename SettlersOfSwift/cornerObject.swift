//
//  cornerObject.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-03-02.
//  Copyright © 2017 Comp361. All rights reserved.
//

enum cornerType : String {
    case Settlement
    case City
    case Knight
}

//class that will represent a piece on a hex corner and its attributes
class cornerObject {
    var name : String = ""
    var type : cornerType
    var owner: Int
    
    // Vars pertaining only to knights
    var strength : Int
    var isActive : Bool
    var hasBeenUpgradedThisTurn : Bool
    var hasBeenActivatedThisTurn : Bool
    
    // Var pertaining only to cities
    var hasCityWall : Bool
    
    init (cornerType : cornerType, owner: Int) {
        type = cornerType
        self.owner = owner
        
        isActive = false
        strength = 1
        hasBeenUpgradedThisTurn = false
        hasBeenActivatedThisTurn = false
        
        hasCityWall = false
    }
}
