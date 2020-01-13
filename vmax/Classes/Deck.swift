//
//  Deck.swift
//  vmax
//
//  Created by Jared Grimes on 12/25/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI
import SwiftSoup

class Deck: ObservableObject {
    @Published var cards: [Card]
    @Published var name: String
    @Published var standardLegal: Bool = true
    @Published var expandedLegal: Bool = true
    
    init(name: String) {
        self.name = name
        self.cards = []
    }
    
    func legality() -> String {
        if standardLegal {
            return "Standard"
        }
        if expandedLegal {
            return "Expanded"
        }
        return "Unlimited"
    }
    
    func clear() {
        cards = []
    }
    
    func cardsSame(cardContent: [String: Any], secondCardContent: [String: Any]) -> Bool {
        
        // if they don't have the EXACT same name they're not the same card
        if cardContent["name"] as! String != secondCardContent["name"] as! String {
            return false
        }
        
        // yes these cards are the same, but since they're from the same set
        // we literally don't care at all
        if cardContent["setCode"] as! String == secondCardContent["setCode"] as! String {
            return false
        }
        
        if cardContent["supertype"] as! String == "Pokémon" {
            if cardContent["attacks"] == nil {
                return false
            }
            let attacks = cardContent["attacks"] as! [Any]
            
            if secondCardContent["attacks"] == nil {
                return false
            }
            
            let secondAttacks = secondCardContent["attacks"] as! [Any]
            if attacks.count != secondAttacks.count {
                return false
            }
            for i in 0 ..< attacks.count {
                let attack = attacks[i] as! [String: Any]
                let secondAttack = secondAttacks[i] as! [String: Any]
                if (attack["name"] as! String != secondAttack["name"] as! String) || (attack["damage"] as! String != secondAttack["damage"] as! String) {
                    return false
                }
            }
        }
        else {
            let text = cardContent["name"] as! String
            let secondText = secondCardContent["name"] as! String
            if text != secondText {
                return false
            }
        }
        return true
    }
    
    func checkReprintLegality(card: Card, standard: Bool) {
        let originalCardContent = card.content
        let defaults = UserDefaults.standard
        let sets: [[String: Any]] = defaults.object(forKey: "sets") as! [[String: Any]]
        let cardName = card.content["name"] as! String
        let cardNameUrl = fixUpQueryUrl(query: cardName)
        // wait i'm not so sure make sure it doesn't have a reprint
        let url = URL(string: urlBase + "cards?name=" + cardNameUrl)!
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if error == nil {
                        let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                        if let dictionary = json as? [String: Any] {
                            if let cards = dictionary["cards"] as? [[String: Any]] {
                                var tempLegal = false
                                for (card) in cards {
                                    let targetSet = sets.filter { set in
                                        let grabbedCode = set["code"] as? String
                                        return card["setCode"] as? String == grabbedCode
                                    }[0]
                                    let legal: Bool = standard ? targetSet["standardLegal"] as! Bool : targetSet["expandedLegal"] as! Bool
                                    let sameCard: Bool = self.cardsSame(cardContent: card, secondCardContent: originalCardContent)
                                    if legal && sameCard {
                                        tempLegal = true
                                        break
                                    }
                                }
                                if !tempLegal {
                                    if standard {
                                        self.standardLegal = false
                                        card.standardLegal = false
                                        // print("EXPANDED CARD")
                                    }
                                    else {
                                        self.expandedLegal = false
                                        card.expandedLegal = false
                                        
                                        card.standardLegal = false
                                    }
                                }
                            }
                        }
                    }
                    else {
                        print(error)
                    }
                }
                task.resume()
    }
    
    func recalculateLegalities() {
        self.standardLegal = true
        self.expandedLegal = true
        
        for card in self.cards {
            updateLegality(card: card)
        }
    }
    
    func updateLegality(card: Card) {
        if card.content["subtype"] as! String == "Basic" && card.content["supertype"] as! String == "Energy" {
            return
        }
        
        let defaults = UserDefaults.standard
        let sets: [[String: Any]] = defaults.object(forKey: "sets") as! [[String: Any]]
        let targetSet = sets.filter { set in
            let grabbedCode = set["code"] as? String
            return card.content["setCode"] as? String == grabbedCode
        }[0]
        
        // first, we check if the set is legal
        let standardLegal: Bool = targetSet["standardLegal"] as! Bool
        let expandedLegal: Bool = targetSet["expandedLegal"] as! Bool
        
        // if the card is banned in standard, the deck is not standard legal,
        // and the card itself is not standard legal
        if ifBanned(card: card.content, format: "Standard") {
            self.standardLegal = false
            card.standardLegal = false
            card.standardBanned = true
        }
        
        // if the card is banned in expanded, the deck is not expanded legal,
        // and the card itself is not expanded legal
        if ifBanned(card: card.content, format: "Expanded") {
            self.expandedLegal = false
            card.expandedLegal = false
            card.expandedBanned = true
        }
        
        
        // if it's a standard promo but not in the promo range legal, it's not
        // legal for standard
        if standardLegal && !ifCardPromoLegal(card: card.content) {
            self.standardLegal = false
            card.standardLegal = false
        }
        
        // if it's not expanded legal, we check to see if there's a reprint legal
        // in expanded. if so, set the legaity back to true.
        if !expandedLegal {
            self.checkReprintLegality(card: card, standard: false)
        }
        
        // if it's not standard legal, we check to see if there's a reprint legal
        // in standard. if so, set the legaity back to true.
        if !standardLegal {
            self.checkReprintLegality(card: card, standard: true)
        }
    }
    
    func addCard(card: Card, legality: Bool) {
        let duplicateCard =  cards.contains {$0.id == card.id}
        if duplicateCard {
            let index = cards.firstIndex {$0.id == card.id}
            cards[index!].count += 1
        }
        else {
            if legality {
                updateLegality(card: card)
            }
            cards.append(card)
            print(card.content["name"] as! String + " appended")
        }
    }
    
    func addCard(card: Card, count: Int) {
        for _ in 0 ..< count {
            updateLegality(card: card)
            cards.append(card)
        }
    }
    
    func addLimitlessCard(card: Card) {
        let duplicateCard =  cards.contains {$0.id == card.id}
        if !duplicateCard {
            updateLegality(card: card)
            cards.append(card)
        }
    }
    
    func removeCard(index: Int) {
        cards.remove(at: index)
        recalculateLegalities()
    }
    
    func changeCardCount(index: Int, incr: Int) {
        cards[index].incrCount(incr: incr)
        
        // if card count less than zero outta here
        if cards[index].count <= 0 {
            cards.remove(at: index)
            
            // just recalculate the legality of all of them
            // the one removed could be the cause of illegality or not
            // we have no idea
            recalculateLegalities()
        }
    }
    
    func getImage(index: Int) -> UIImage {
        return cards[index].image
    }
    
    func uniqueCardCount() -> Int {
        return self.cards.count
    }
    
    func cardCount() -> Int {
        var ctr = 0
        for card in self.cards {
            ctr += card.count
        }
        return ctr
    }
    
    func cardCount(index: Int) -> Int {
        return cards[index].count
    }
    
    func deckOutput() -> String {
        var out: [[String: String]] = []
        
        var meta = [String: String]()
        meta["legality"] = legality()
        out.append(meta)
        
        for card in self.cards {
            var cardOutput = [String: String]()
            cardOutput["content"] = json(from: card.content)!
            cardOutput["count"] = String(card.count)
            out.append(cardOutput)
        }
        
        return json(from: out)!
    }
    
    func ptcgoOutput() -> String {
        var output = ""
        
        // copied code
        let supertypes = ["Pokémon", "Trainer", "Energy"]
        var supertypeCards: [[Card]] = []
        var supertypeCounts: [Int] = [0, 0, 0]
        
        var ctr = 0
        for supertype in supertypes {
            let filteredCards = self.cards.filter { $0.getSupertype() == supertype }
            supertypeCards.append(filteredCards)
            for card in filteredCards {
                supertypeCounts[ctr] += card.count
            }
            
            ctr += 1
        }
        
        let trainerSubtypes = ["Supporter", "Item", "Pokémon Tool", "Stadium"]
        var trainerSubtypeCards: [[Card]] = []
        var trainerSubtypeCounts: [Int] = [0, 0, 0, 0]
        
        ctr = 0
        if supertypeCounts[1] > 0 {
            for trainerType in trainerSubtypes {
                let filteredCards = supertypeCards[1].filter { $0.getSubtype() == trainerType }
                trainerSubtypeCards.append(filteredCards)
                
                for card in filteredCards {
                    trainerSubtypeCounts[ctr] += card.count
                }
                
                ctr += 1
            }
            
            // now rearrange the trainers
            supertypeCards[1] = trainerSubtypeCards[0] + trainerSubtypeCards[1] + trainerSubtypeCards[2] + trainerSubtypeCards[3]
        }
        
        ctr = 0
        for supertype in supertypes {
            output += supertype + " - " + String(supertypeCounts[ctr]) + "\n"
            for card in self.cards.filter({ $0.getSupertype() == supertype }) {
                let ptcgoSetCode: String = setConvertToPtcgo(card: card)
                output += "* " + String(card.count) + " " + (card.content["name"] as! String)
                
                output += " " + ptcgoSetCode
                if ptcgoSetCode != energyPtcgoSetCode {
                    output += " " + (card.content["number"] as! String) + "\n"
                }
                else {
                    output += " " + energyNumberConvert(name: (card.content["name"] as! String), number: (card.content["number"] as! String)) + "\n"
                }
            }
            ctr += 1
        }
        return output
    }
}
