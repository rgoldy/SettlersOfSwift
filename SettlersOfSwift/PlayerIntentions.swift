//
//  PlayerIntentions.swift
//  SettlersOfSwift
//
//  Created by YIFFY on 4/4/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

//  IN PROGRESS
//  EACH PLAYER SHOULD HOLD A PROPERTY OF THIS TYPE
//  VALUE OF PROPERTY IS SET IN FLIP CHART SCREEN AND CLEARED AT START OF EACH TURN
//  VALUE IS PROCESSED BY GAME BOARD'S TOUCH HANDLING METHOD TO DETERMINE COURSE OF ACTION

enum PlayerIntentions : String {
    case WillDoNothing
    case WillBuildRoad
    case WillBuildRoadForFree
    case WillBuildShip
    case WillBuildShipForFree
    case WillBuildSettlement
    case WillBuildCity
    case WillBuildWall
    case WillBuildKnight
    case WillBuildKnightForFree
    case WillDisplaceKnight
    case WillPromoteKnight
    case WillActivateKnight
    case WillBuildMetropolis
    case WillRemoveMetropolis
    case WillRemoveOutlaw
    case WillMoveShip
    case WillMoveKnight
    case WillMoveOutlaw
    case WillDestroyCity
}
