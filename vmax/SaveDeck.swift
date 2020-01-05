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
    @State var oldDeckName: String
    @State var initSet: Bool = true
    
    func storeDeck() {
        let defaults = UserDefaults.standard
        var newDecks = [String: String]()
        if (!defaults.bool(forKey: "decks")) {
            newDecks = defaults.object(forKey: "decks") as? [String: String] ?? [String: String]()
        }

        newDecks.removeValue(forKey: oldDeckName)
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
        return VStack {
            Text("Deck Name")
                .font(.title)
                .fontWeight(.bold)
            TextField("ex. Busted Broken Chandelure", text: $deckName)
            Divider()
            Button(action: storeDeck) {
                Text("Rename")
            }.padding()
        }.padding()
    }
}
