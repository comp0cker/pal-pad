//
//  ContentView.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI
import Combine

let imageWidth: CGFloat = UIScreen.main.bounds.width / 4
let imageHeight: CGFloat = imageWidth * 343 / 246

func json(from object:Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return nil
    }
    return String(data: data, encoding: String.Encoding.utf8)
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SearchView: View {
    @State var image = Image(systemName: "card")
    @State var searchQuery = ""
    @ObservedObject var searchResults: Deck = Deck(name: "New Deck")
    @ObservedObject var deck: Deck
    @State var sets: [[String: Any]] = []
    @State var searchResultsLoaded = false
    @Binding var changedSomething: Bool
    
    @State var onlyShowLegalities: Bool = true
    
    func addCardToSearch(card: [String: Any]) {
        // DUPLICATE CODE
        let c = Card(content: card)
        let imageUrl = c.getImageUrl(cardDict: card)
        let task = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if error == nil {
                c.image = c.getImageFromData(data: data!)
                self.searchResults.addCard(card: c, legality: true)
            }
        }
        task.resume()
    }
    
    // this is where we actually search cards, called by searchCards()
    func actuallySearchCards() {
        self.searchResults.clear()
        let fixedQuery = fixUpNameQuery(query: self.searchQuery)
        
        
        let searchQueryUrl = fixedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlBase + "cards?name=" + searchQueryUrl)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
//                print(json)
                if let dictionary = json as? [String: Any] {
                    if let cards = dictionary["cards"] as? [[String: Any]] {
                        for (card) in cards {
                            self.addCardToSearch(card: card)
                        }
                    }
                }
                self.searchResultsLoaded = true
            }
            else {
                print(error)
            }
        }
        task.resume()
    }
    
    func searchCards() {
        self.searchResults.objectWillChange.send()
        UIApplication.shared.endEditing()
        
        let defaults = UserDefaults.standard
        
        // if we've never searched for cards before load the legalities into
        // local memory, then actually search cards (we only do this ONCE EVER)
        if (!defaults.bool(forKey: "sets")) {
            let setLegalityUrl = URL(string: urlBase + "sets")!
            let initTask = URLSession.shared.dataTask(with: setLegalityUrl) { (data, response, error) in
                if error == nil {
                   let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    if let dict = json as? [String: Any] {
                        if let sets = dict["sets"] as? [[String: Any]] {
                            defaults.set(dict["sets"], forKey: "sets")
                            
                            self.sets = sets
                            print("success!")
                            self.actuallySearchCards()
                            print("DONE!")
                        }
                    }
                    else {
                        print("oh no")
                    }
                }
            }
            initTask.resume()
        }
        else {
            sets = defaults.object(forKey: "sets") as? [[String: Any]] ?? [[String: Any]]()
            print("NICE")
            // OH NO FIX THIS
        }
    }
    
    func searchOff(card: Card) {
        // bzzt
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        var newDeck: Deck = deck
        newDeck.addCard(card: card, legality: true)
        changedSomething = true
        UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
    }
    
    func searchResultView(rowNumber: Int, columnNumber: Int, cards: [Card]) -> some View {
        return Button(action: {
            self.searchOff(card: rowNumber * 3 + columnNumber >= cards.count ? cards[0] : cards[rowNumber * 3 + columnNumber])})
        {
            rowNumber * 3 + columnNumber >= cards.count ? Image(systemName: "card") : Image(uiImage: cards[rowNumber * 3 + columnNumber].image).renderingMode(.original)
        }
    }
    
    func ifCardLegal(card: Card, legality: String) -> Bool {
        if legality == "Standard" {
            return card.standardLegal
        }
        if legality == "Expanded" {
            return card.expandedLegal && !card.standardLegal
        }
        if legality == "Unlimited" {
            return !card.expandedLegal && !card.standardLegal
        }

        return false
    }
    
    func rowCount(cards: [Card]) -> Int {
        return (cards.count - 1) / 3 + 1
    }

    var body: some View {
        var legalities = ["Standard", "Expanded", "Unlimited"]
        var legalCards: [[Card]] = []
        
        let newDeck: Deck = deck

        // we add newDeck.cardCount() > 0 because we want to show all
        // cards on the initial search
        if onlyShowLegalities == true && newDeck.cards.count > 0 {
            if self.deck.standardLegal {
                legalities = ["Standard"]
            }
            else if self.deck.expandedLegal {
                legalities = ["Standard", "Expanded"]
            }
        }
        
        for legality in legalities {
            let filteredCards = self.searchResults.cards.filter { self.ifCardLegal(card: $0, legality: legality) }
            legalCards.append(filteredCards)
            
            print(legality + String(filteredCards.count))
        }
        return VStack {
                HStack {
                    TextField("Card name", text: $searchQuery)
                    Button(action: searchCards) {
                        Text("Search")
                    }
                }.padding()
            
                Toggle(isOn: self.$onlyShowLegalities) {
                    Text("Only show legal cards for your deck")
                }.padding()
                
                !searchResultsLoaded ? nil : ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer()
                        }
                        ForEach (0 ..< legalities.count, id: \.self) { legality in
                            VStack(alignment: .leading) {
                                HStack {
                                    Spacer()
                                }
                                Text(legalities[legality])
                                    .font(.title)
                                    .fontWeight(.bold)
                                ForEach (0 ..< self.rowCount(cards: legalCards[legality]), id: \.self) { rowNumber in
                                    HStack {
                                        ForEach (0 ..< 3, id: \.self) { columnNumber in
                                            self.searchResultView(rowNumber: rowNumber, columnNumber: columnNumber, cards: legalCards[legality])
                                        }
                                    }
                                }
                            }
                        }
                    }.padding()
                }
            }
        }
    }

