//
//  ProgressCards.swift
//  SettlersOfSwift
//
//  Created by YIFFY on 4/6/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

enum ProgressCardsCategory {
    case Politics
    case Sciences
    case Trades
}

enum ProgressCardsType: String {
    case Alchemist
    case Crane
    case Engineer
    case Inventor
    case Irrigation
    case Medicine
    case Mining
    case Printer
    case RoadBuilding
    case Smith
    case Bishop
    case Constitution
    case Deserter
    case Diplomat
    case Intrigue
    case Saboteur
    case Spy
    case Warlord
    case Wedding
    case CommercialHarbor
    case MasterMerchant
    case Merchant
    case MerchantFleet
    case ResourceMonopoly
    case TradeMonopoly
    
    static func getCategoryOfCard(_ card: ProgressCardsType) -> ProgressCardsCategory {
        switch card {
            case Alchemist: fallthrough
            case Crane: fallthrough
            case Engineer: fallthrough
            case Inventor: fallthrough
            case Irrigation: fallthrough
            case Medicine: fallthrough
            case Mining: fallthrough
            case Printer: fallthrough
            case RoadBuilding: fallthrough
            case Smith: return .Sciences
            case Bishop: fallthrough
            case Constitution: fallthrough
            case Deserter: fallthrough
            case Diplomat: fallthrough
            case Intrigue: fallthrough
            case Saboteur: fallthrough
            case Spy: fallthrough
            case Warlord: fallthrough
            case Wedding: return .Politics
            case CommercialHarbor: fallthrough
            case MasterMerchant: fallthrough
            case Merchant: fallthrough
            case MerchantFleet: fallthrough
            case ResourceMonopoly: fallthrough
            case TradeMonopoly: return .Trades
    }   }
    
    static func generateNewGameDeck() -> [ProgressCardsType?] {
        var deck = Array<ProgressCardsType?>(repeating: nil, count: 54)
        deck[00] = .Alchemist;          deck[01] = .Alchemist;
        deck[02] = .Crane;              deck[03] = .Crane;
        deck[04] = .Engineer;
        deck[05] = .Inventor;           deck[06] = .Inventor;
        deck[07] = .Irrigation;         deck[08] = .Irrigation;
        deck[09] = .Medicine;           deck[10] = .Medicine;
        deck[11] = .Mining;             deck[12] = .Mining;
        deck[13] = .Printer;
        deck[14] = .RoadBuilding;       deck[15] = .RoadBuilding;
        deck[16] = .Smith;              deck[17] = .Smith;
        deck[18] = .Bishop;             deck[19] = .Bishop;
        deck[20] = .Constitution;
        deck[21] = .Deserter;           deck[22] = .Deserter;
        deck[23] = .Diplomat;           deck[24] = .Diplomat;
        deck[25] = .Intrigue;           deck[26] = .Intrigue;
        deck[27] = .Saboteur;           deck[28] = .Saboteur;
        deck[29] = .Spy;                deck[30] = .Spy;                deck[31] = .Spy;
        deck[32] = .Warlord;            deck[33] = .Warlord;
        deck[34] = .Wedding;            deck[35] = .Wedding;
        deck[36] = .CommercialHarbor;   deck[37] = .CommercialHarbor;
        deck[38] = .MasterMerchant;     deck[39] = .MasterMerchant;
        deck[40] = .Merchant;           deck[41] = .Merchant;           deck[42] = .Merchant;           deck[43] = .Merchant;           deck[44] = .Merchant;   deck[45] = .Merchant;
        deck[46] = .MerchantFleet;      deck[47] = .MerchantFleet;
        deck[48] = .ResourceMonopoly;   deck[49] = .ResourceMonopoly;   deck[50] = .ResourceMonopoly;   deck[51] = .ResourceMonopoly;
        deck[52] = .TradeMonopoly;      deck[53] = .TradeMonopoly;
        for _ in 0..<216 {
            let first = Int(arc4random() % 54)
            let second = Int(arc4random() % 54)
            let temporaryCard = deck[first]
            deck[first] = deck[second]
            deck[second] = temporaryCard
        }
        return deck
    }
    
    static func getNextCardOfCategory(_ category: ProgressCardsCategory, fromDeck: inout [ProgressCardsType?]) -> ProgressCardsType? {
        for index in 0..<54 {
            if fromDeck[index] != nil && ProgressCardsType.getCategoryOfCard(fromDeck[index]!) == category {
                let removedCard = fromDeck.remove(at: index)
                return removedCard
        }   }
        return nil  //  no more cards remaining in deck
    }
    
    static func getDescriptionOf(deck: inout [ProgressCardsType?]) -> String {
        var descriptionString = "deckDescription"
        for index in 0..<54 { descriptionString += "." + (deck[index] == nil ? "nil" : deck[index]!.rawValue)  }
        return descriptionString
    }
    
    static func reconstructFrom(description: String) -> [ProgressCardsType?] {
        let components = description.components(separatedBy: ".")
        var deck = [ProgressCardsType?]()
        for index in 1...54 { deck.append(components[index] == "nil" ? nil : ProgressCardsType(rawValue: components[index])) }
        return deck
    }
    
}
