//
//  PageViewController.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var deckViewOn: Bool = false
    @State var savedDecks: [String: String] = UserDefaults.standard.object(forKey: "decks") as? [String: String] ?? [String: String]()
    @State var loadedDeck: String = ""

    func deckOn() {
        deckViewOn = true
    }
    
    func loadDeck(json: [[String: String]]) {
        print("hi")
    }
    
    var body: some View {
        let names = self.savedDecks.map{$0.key}
        let decks = self.savedDecks.map {$0.value}
        
        return VStack {
            NavigationView {
                VStack {
                    ForEach (0 ..< names.count, id: \.self) { pos in
                        Button(action: {
                            self.loadedDeck = decks[pos]
                            let data = Data(self.loadedDeck.utf8)

                            do {
                                // make sure this JSON is in the format we expect
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] {
                                    self.loadDeck(json: json)
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
                    Button(action: deckOn) {
                        Text("New Deck")
                    }
                    NavigationLink (destination: DeckView(), isActive: $deckViewOn) {
                        EmptyView()
                    }
                }.navigationBarTitle("vmax")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
