//
//  PageViewController.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI
import Combine

class SavedDecks: ObservableObject {
    @Published var list: [String: String] = UserDefaults.standard.object(forKey: "decks") as? [String: String] ?? [String: String]()
    
    func update() {
        self.objectWillChange.send()
        list = UserDefaults.standard.object(forKey: "decks") as? [String: String] ?? [String: String]()
        self.objectWillChange.send()
    }
}

struct ContentView: View {
    @State var deckViewOn: Bool = false
    @ObservedObject var savedDecks: SavedDecks = SavedDecks()
    @State var loadedDeck: String = ""
    @State var deck: Deck = Deck(name: "New Deck")

    func deckOn() {
        deckViewOn = true
    }
    
    func loadDeck(json: [[String: String]], name: String) {
        self.deck = Deck(name: name)
        
        for card in json {
            let content = card["content"]!
            let count = Int(card["count"]!)!
            
            let data = Data(content.utf8)
            do {
                // make sure this JSON is in the format we expect
                if let cardDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    var c = Card(content: cardDict)
                    // DUPLICATE CODE
                    let imageUrl = c.getImageUrl(cardDict: cardDict)
                    let task = URLSession.shared.dataTask(with: imageUrl) { (imgData, response, error) in
                        if error == nil {
                            c.image = c.getImageFromData(data: imgData!)
                            self.deck.addCard(card: c)
                        }
                    }
                    task.resume()
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        let names = self.savedDecks.list.map{$0.key}
        let decks = self.savedDecks.list.map {$0.value}
        
        return VStack {
            NavigationView {
                VStack(alignment: .leading) {
                    ForEach (0 ..< names.count, id: \.self) { pos in
                        Button(action: {
                            self.loadedDeck = decks[pos]
                            let name = names[pos]
                            let data = Data(self.loadedDeck.utf8)

                            do {
                                // make sure this JSON is in the format we expect
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] {
                                    self.loadDeck(json: json, name: name)
                                    // try to read out a string array

                                }
                            } catch let error as NSError {
                                print("Failed to load: \(error.localizedDescription)")
                            }
                            
                            self.deckOn()
                            
                        }) {
                            Text(names[pos])
                        }
                    }
                    Button(action: {
                        self.deck = Deck(name: "New Deck")
                        self.deckOn()
                    }) {
                        Text("New Deck")
                    }
                    Button(action: {
                        let defaults = UserDefaults.standard
                        defaults.set("", forKey: "decks")
                    }) {
                        Text("w i p e")
                    }
                    NavigationLink (destination: DeckView(deck: deck, savedDecks: savedDecks), isActive: $deckViewOn) {
                        EmptyView()
                    }
                }.navigationBarTitle("vmax")
            }
        }
    }
}
