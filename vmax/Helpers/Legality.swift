//
//  Legality.swift
//  Pal Pad
//
//  Created by Jared Grimes on 12/28/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

struct bannedCard {
    var name: String
    var set: String = ""
    var number: String = ""
    
    func cardEqual(card: [String: Any]) -> Bool {
        if set == "" && number == "" {
            return name == card["name"] as! String
        }
        return name == card["name"] as! String && set == card["setCode"] as! String &&  number == card["number"] as! String
    }
}

func ifBanned(card: [String: Any], format: String) -> Bool {
    let standardBannedCards: [bannedCard] = []
    let expandedBannedCards: [bannedCard] = [
        bannedCard(name: "Archeops", set: "bw3", number: "67"),
        bannedCard(name: "Archeops", set: "bw5", number: "110"),
        bannedCard(name: "Chip-Chip-Ice"),
        bannedCard(name: "Delinquent"),
        bannedCard(name: "Flabébé", set: "sm6", number: "83"),
        bannedCard(name: "Forest of Giant Plants"),
        bannedCard(name: "Ghetsis"),
        bannedCard(name: "Hex Maniac"),
        bannedCard(name: "Island Challenge Amulet"),
        bannedCard(name: "Jessie & James"),
        bannedCard(name: "Lt. Surge's Strategy"),
        bannedCard(name: "Lusamine"),
        bannedCard(name: "Lysandre's Trump Card"),
        bannedCard(name: "Marshadow", set: "sm35", number: "45"),
        bannedCard(name: "Marshadow", set: "smp", number: "sm85"),
        bannedCard(name: "Maxie's Hidden Ball Trick"),
        bannedCard(name: "Mismagius", set: "sm10", number: "78"),
        bannedCard(name: "Puzzle of Time"),
        bannedCard(name: "Red Card"),
        bannedCard(name: "Reset Stamp"),
        bannedCard(name: "Unown", set: "sm8", number: "90"),
        bannedCard(name: "Unown", set: "sm8", number: "91"),
        bannedCard(name: "Wally")
    ]
    
    if format == "Standard" {
        return standardBannedCards.filter {$0.cardEqual(card: card)}.count > 0
    }
    if format == "Expanded" {
        return expandedBannedCards.filter {$0.cardEqual(card: card)}.count > 0
    }
    
    return false
}

func ifCardPromoLegal(card: [String: Any]) -> Bool {
    let series = "SM"
    let number = 94
    var cardNumber = card["number"] as! String
    if cardNumber.prefix(2) != series {
        return true
    }
    
    // it means the number is > 2 digits
    if cardNumber.count > 4 {
        return true
    }
    if cardNumber.count < 4 {
        return false
    }
    
    let cardNumberVal = Int(String(cardNumber.suffix(2)))!
    return cardNumberVal >= number
}
