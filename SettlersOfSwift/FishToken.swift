//
//  FishToken.swift
//  SettlersOfSwift
//
//  Created by Riley Goldman on 3/21/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

class FishToken
{
    /* value:
        0 --> old boot
        1 --> 1 fish worth (x11)
        2 --> 2 fish worth (x10)
        3 --> 3 fish worth (x8)
     */
    var value : Int
    
    init (v : Int)
    {
        value = v
    }
}
