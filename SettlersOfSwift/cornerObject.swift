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
}

//class that will represent a piece on a hex corner and its attributes
class cornerObject {
    var name : String = ""
    var type : cornerType
    
    init (cornerType : cornerType) {
        type = cornerType
    }
}
