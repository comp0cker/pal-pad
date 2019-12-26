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
    
    init(name: String) {
        self.name = name
        self.cards = []
    }
    
    func clear() {
        cards = []
    }
    
    func addCard(card: Card) {
        let duplicateCard =  cards.contains {$0.id == card.id}
        if duplicateCard {
            print("duplicate card!")
            let index = cards.firstIndex {$0.id == card.id}
            cards[index!].count += 1
        }
        else {
            cards.append(card)
        }
    }
    
    func addCard(card: Card, count: Int) {
        for _ in 0 ..< count {
            cards.append(card)
        }
    }
    
    func addLimitlessCard(card: Card) {
        let duplicateCard =  cards.contains {$0.id == card.id}
        if duplicateCard {
            print("duplicate card!")
            let index = cards.firstIndex {$0.id == card.id}
        }
        else {
            cards.append(card)
        }
    }
    
    func changeCardCount(index: Int, incr: Int) {
        cards[index].incrCount(incr: incr)
        
        // if card count less than zero outta here
        if cards[index].count <= 0 {
            cards.remove(at: index)
        }
    }
    
    func getImage(index: Int) -> Image {
        return cards[index].image
    }
    
    func uniqueCardCount() -> Int {
        return self.cards.count
    }
    
    func cardCount(index: Int) -> Int {
        return cards[index].count
    }
    
    func deckOutput() -> String {
        var out: [[String: String]] = []
        for card in self.cards {
            var cardOutput = [String: String]()
            cardOutput["content"] = json(from: card.content)!
            cardOutput["count"] = String(card.count)
            out.append(cardOutput)
        }
        return json(from: out)!
    }
}
