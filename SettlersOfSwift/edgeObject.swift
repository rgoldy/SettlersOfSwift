//
//  edgeObject.swift
//  SettlersOfSwift
//
//  Created by Mario Youssef on 2017-03-02.
//  Copyright © 2017 Comp361. All rights reserved.
//

enum edgeType : String {
    case Road
    case Boat
}

//class that will represent a piece on a hex edge and its attributes
class edgeObject {
    var name : String = ""
    var type : edgeType

    init (edgeType : edgeType) {
        type = edgeType
    }
}
