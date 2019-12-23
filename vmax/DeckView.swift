//
//  PageViewController.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI
import Combine

struct SaveDeck: View {
    @State private var deckName: String = ""
    @ObservedObject var deck: Deck
    
    func storeDeck() {
        let defaults = UserDefaults.standard
        var newDecks = [String: String]()
        if (!defaults.bool(forKey: "decks")) {
            newDecks = defaults.object(forKey: "decks") as? [String: String] ?? [String: String]()
        }

        newDecks[deckName] = deck.deckOutput()
        defaults.set(newDecks, forKey: "decks")
        
        UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
    }

    var body: some View {
        VStack {
            Text("Enter Input")
            TextField("Type text here", text: $deckName)
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
    }
}

struct DeckView: View {
    @State var showSearch: Bool = false
    @State var showSaveDeck: Bool = false
    @State private var saveDeckName: String = ""
    @ObservedObject var deck: Deck = Deck()
    
    @State private var firstPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    
    func searchOn() {
        showSearch = true
    }
    
    func rowCount() -> Int {
        print("row count" + String(self.deck.uniqueCardCount() / 3 + 1))
        return self.deck.uniqueCardCount() / 3 + 1
    }
    
    func colCount(rowNumber: Int) -> Int {
        if 3 + rowNumber > self.deck.uniqueCardCount() {
            print("col count" + String(self.deck.uniqueCardCount()))
            return self.deck.uniqueCardCount()
        }
        print("3")
        return 3
    }
    
    func saveDeck() {
        showSaveDeck = true
    }
    
    func incrCard(index: Int, incr: Int) {
        self.deck.objectWillChange.send()
        self.deck.changeCardCount(index: index, incr: incr)
    }
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    Text("Welcome to vmax!")
                    Text("Add some cards to get started")
                    Button(action: {
                        let alertHC = UIHostingController(rootView: SaveDeck(deck: self.deck))

                        alertHC.preferredContentSize = CGSize(width: 300, height: 200)
                        alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet

                        UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)

                    }) {
                        Text("Save Deck")
                    }
                    
                    Button(action: searchOn) {
                        Text("Add card")
                    }
                    NavigationLink (destination: SearchView(showSearch: $showSearch, deck: deck), isActive: $showSearch) {
                        EmptyView()
                    }
                    ScrollView {
                        VStack {
                            ForEach (0 ..< self.rowCount(), id: \.self) { rowNumber in
                                HStack {
                                    ForEach (0 ..< self.colCount(rowNumber: rowNumber), id: \.self) { columnNumber in
                                        ZStack {
                                            self.deck.getImage(index: rowNumber * 3 + columnNumber)
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 100, height: 50)
                                            Text(String(self.deck.cardCount(index: rowNumber * 3 + columnNumber)))
                                        }.gesture(DragGesture()
                                                .onChanged { value in
                                                    if self.firstPosition == .zero {
                                                        print("whoop")
                                                        self.firstPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                                                    }
                                            }   // 4.
                                                .onEnded { value in
                                                    self.newPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                                                    if (self.newPosition.height < self.firstPosition.height) {
                                                        print("ADD")
                                                        self.incrCard(index: rowNumber * 3 + columnNumber, incr: 1)
                                                    }
                                                    else if (self.newPosition.height > self.firstPosition.height) {
                                                        print("MINUS")
                                                        self.incrCard(index: rowNumber * 3 + columnNumber, incr: -1)
                                                    }
                                                    self.firstPosition = .zero
                                                })
                                    }
                                }
                            }
                        }
                    }
                }.navigationBarTitle("Deck Editor")
            }
        }
    }
}

struct DeckView_Previews: PreviewProvider {
    static var previews: some View {
        DeckView()
    }
}
