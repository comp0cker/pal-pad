//
//  PageViewController.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI
import Combine

struct DeckView: View {
    @State var showSaveDeck: Bool = false
    @State private var saveDeckName: String = ""
    @ObservedObject var deck: Deck
    @ObservedObject var savedDecks: SavedDecks
    
    @State private var firstPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    
    @State private var tooManyCardsAlert = false
    
    func rowCount(cards: [Card]) -> Int {
        return (cards.count - 1) / 3 + 1
    }
    
    func colCount(rowNumber: Int, cards: [Card]) -> Int {
        if cards.count % 3 == 0 && cards.count != 0 {
            return 3
        }
        return cards.count % 3
    }
    
    func saveDeck() {
        self.savedDecks.objectWillChange.send()
        showSaveDeck = true
    }
    
    func incrCard(index: Int, incr: Int) {
        self.deck.objectWillChange.send()
        self.deck.changeCardCount(index: index, incr: incr)
    }
    
    func cardView(rowNumber: Int, columnNumber: Int, cards: [Card]) -> some View {
        let selectedCard = cards[rowNumber * 3 + columnNumber]
//        print(selectedCard.content["name"] as! String)
        let index = self.deck.cards.firstIndex(where: {$0.id == selectedCard.id})!
        
        return ZStack {
            cards[rowNumber * 3 + columnNumber].image
            Circle()
                .frame(width: 40, height: 40)
                .padding(.top, 100)
                .overlay(
                  Circle()
                 .stroke(Color.black,lineWidth: 5)
                    .padding(.top, 100)
                ).foregroundColor(Color.white)
            
            Text(String(self.deck.cardCount(index: index)))
                .fontWeight(.bold)
                .padding(.top, 100)
        }.gesture(DragGesture()
                .onChanged { value in
                    if self.firstPosition == .zero {
                        self.firstPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                    }
            }   // 4.
                .onEnded { value in
                    self.newPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                    
                    if (self.newPosition.height < self.firstPosition.height) {
                        if (self.deck.cards[index].count == 4 && !self.deck.cards[index].ifBasicEnergy()) {
                            self.tooManyCardsAlert = true
                        }
                        else {
                            self.incrCard(index: index, incr: 1)
                        }
                    }
                    else if (self.newPosition.height > self.firstPosition.height) {
                        self.incrCard(index: index, incr: -1)
                    }
                    self.firstPosition = .zero
            })
        .alert(isPresented: $tooManyCardsAlert) {
            Alert(title: Text("Oops"), message: Text("You can't add more than 4 copies of a single card."), dismissButton: .default(Text("Got it!")))
        }
    }
    
    var body: some View {
        let supertypes = ["Pokémon", "Trainer", "Energy"]
        var supertypeCards: [[Card]] = []
        
        for supertype in supertypes {
            let filteredCards = self.deck.cards.filter { $0.getSupertype() == supertype }
            supertypeCards.append(filteredCards)
        }
        
        return VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        let alertHC = UIHostingController(rootView: SaveDeck(deck: self.deck, savedDecks: self.savedDecks))

                        alertHC.preferredContentSize = CGSize(width: 300, height: 200)
                        alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet

                        UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)

                    }) {
                        Text("Save Deck")
                    }
                    
                    Button(action: {
                        let alertHC = UIHostingController(rootView: SearchView(deck: self.deck))

                        alertHC.preferredContentSize = CGSize(width: 300, height: 200)
                        alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet

                        UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
                    }) {
                        Text("Add card")
                    }
                }
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach (0 ..< supertypes.count) { supertype in
                            Text(supertypes[supertype]).font(.title).fontWeight(.bold)
                            ForEach (0 ..< self.rowCount(cards: supertypeCards[supertype]), id: \.self) { rowNumber in
                                HStack {
                                    ForEach (0 ..< self.colCount(rowNumber: rowNumber, cards: supertypeCards[supertype]), id: \.self) { columnNumber in
                                        self.cardView(rowNumber: rowNumber, columnNumber: columnNumber, cards: supertypeCards[supertype])
                                    }
                                }
                            }
                        }
                    }
                }
            }.navigationBarTitle(self.deck.name)
        }
    }
