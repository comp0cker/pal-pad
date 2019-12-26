//
//  SaveDeck.swift
//  vmax
//
//  Created by Jared Grimes on 12/23/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

struct SaveDeck: View {
    @ObservedObject var deck: Deck
    @ObservedObject var savedDecks: SavedDecks
    @Binding var deckName: String
    
    func storeDeck() {
        let defaults = UserDefaults.standard
        var newDecks = [String: String]()
        if (!defaults.bool(forKey: "decks")) {
            newDecks = defaults.object(forKey: "decks") as? [String: String] ?? [String: String]()
        }

        newDecks[deckName] = deck.deckOutput()
        defaults.set(newDecks, forKey: "decks")
        
        // updating the original view with saved deck
        self.savedDecks.update()
        
        // bzzt
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
    }

    var body: some View {
        VStack {
            Text("Please enter a deck name")
            TextField("Deck name", text: $deckName)
            Divider()
                HStack {
                    Button(action: storeDeck) {
                        Text("Done")
                    }
                    Button(action: {
                        UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                    }) {
                        Text("Cancel")
                    }
                    Spacer()
                }
            }.background(Color(white: 1))
        .padding()
    }
}
