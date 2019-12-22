//
//  PageViewController.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

struct SaveDeck: View {
    @State private var deckName: String = ""
    @Binding var deck: Deck
    
    func storeDeck() {
        let defaults = UserDefaults.standard
        defaults.set(self.deckName, forKey: deck.jsonOutput())
        
        UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
        
        if let stringOne = defaults.string(forKey: self.deckName) {
            print(stringOne) // Some String Value
        }
    }

    var body: some View {
        VStack {
            Text("Enter Input")

            TextField("Type text here", text: $deckName)
            Divider()
            HStack {
                Spacer()
                Button(action: storeDeck) {
                    Text("Done")
                }
                Spacer()
                Divider()
                Spacer()
                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                }) {
                    Text("Cancel")
                }
                Spacer()
            }.padding(0)


            }.background(Color(white: 0.9))
    }
}

struct ContentView: View {
    @State var showSearch: Bool = false
    @State var showSaveDeck: Bool = false
    @State private var saveDeckName: String = ""
    @State var deck: Deck = Deck()
    
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
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    Text("Welcome to vmax!")
                    Text("Add some cards to get started")
                    Button(action: {
                        let d = self.$deck
                        let alertHC = UIHostingController(rootView: SaveDeck(deck: d))

                        alertHC.preferredContentSize = CGSize(width: 300, height: 200)
                        alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet

                        UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)

                    }) {
                        Text("Save Deck")
                    }
                    
                    Button(action: searchOn) {
                        Text("Add card")
                    }
                    NavigationLink (destination: SearchView(showSearch: $showSearch, deck: $deck), isActive: $showSearch) {
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
                                        }
                                    }
                                }
                            }
                        }
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
