//
//  PageViewController.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var showSearch: Bool = false
    @State var showSaveDeck: Bool = false
    @State private var saveDeckName: String = ""
    @State var deck: [Card] = []
    
    func searchOn() {
        showSearch = true
    }
    
    func rowCount() -> Int {
        return self.deck.count / 3 + 1
    }
    
    func colCount(rowNumber: Int) -> Int {
        if 3 + rowNumber > self.deck.count {
            return self.deck.count
        }
        return 3
    }
    
    func saveDeck() {
        showSaveDeck = true
    }
    
    func cardCount(card: Card) -> String {
        return String(card.count)
    }
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
//                    HStack {
//                        Button(action: saveDeck) {
//                            Text("Save Deck")
//                        }
//                    }
                    Text("Welcome to vmax!")
                    Text("Add some cards to get started")
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
                                            self.deck[rowNumber * 3 + columnNumber].image
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 100, height: 50)
                                            Text(self.cardCount(card: self.deck[rowNumber * 3 + columnNumber]))
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
