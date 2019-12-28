//
//  Deck.swift
//  vmax
//
//  Created by Jared Grimes on 12/25/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

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
        if standardLegal && expandedLegal {
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
        
        if cardContent["supertype"] as! String == "Pokémon" {
            let attacks = cardContent["attacks"] as! [Any]
            let secondAttacks = secondCardContent["attacks"] as! [Any]
            if attacks.count != secondAttacks.count {
                return false
            }
            for i in 0 ..< attacks.count {
                let attack = attacks[i] as! [String: Any]
                let secondAttack = secondAttacks[i] as! [String: Any]
                if attack["text"] as! String != secondAttack["text"] as! String {
                    return false
                }
            }
        }
        else {
            let text = cardContent["text"] as! [String]
            let secondText = secondCardContent["text"] as! [String]
            if text[0] != secondText[0] {
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
        let cardNameUrl = cardName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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
                                    }
                                    else {
                                        self.standardLegal = false
                                        self.expandedLegal = false
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
        
        let standardLegal: Bool = targetSet["standardLegal"] as! Bool
        let expandedLegal: Bool = targetSet["expandedLegal"] as! Bool
        
        if !standardLegal {
            self.checkReprintLegality(card: card, standard: true)
        }
        else if !expandedLegal {
            self.checkReprintLegality(card: card, standard: false)
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
}
