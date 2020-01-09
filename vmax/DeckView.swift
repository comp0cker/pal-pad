//
//  PageViewController.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI
import Combine
import GoogleMobileAds

final private class SmallAdBanner: UIViewControllerRepresentable  {

    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeBanner)

        let viewController = UIViewController()
        view.adUnitID = appUnitID
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)
        view.load(GADRequest())

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct DeckView: View {
    @State var showSaveDeck: Bool = false
    @State var showDeleteDeck: Bool = false
    @State private var saveDeckName: String = ""
    @ObservedObject var deck: Deck
    @State var title: String
    @ObservedObject var savedDecks: SavedDecks
    @Binding var deckViewOn: Bool
    @State var showExportImageView: Bool = false
    
    @State private var firstPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    
    @State private var tooManyCardsAlert = false
    @State private var showBannedAlert = false
    @State private var showNotEnoughCards = false
    
    @Binding var changedSomething: Bool
    @State var cardsLoaded: Bool = false
    
    @State var editingMode: Bool = false
    @State var animationAmount: CGFloat = 1
    
    @Binding var showAds: Bool
    @Binding var leaksMode: Bool
    @Binding var showSettingsView: Bool
    
    func rowCount(cards: [Card]) -> Int {
        return (cards.count - 1) / 3 + 1
    }
    
    func saveDeck() {
        self.savedDecks.objectWillChange.send()
        showSaveDeck = true
    }
    
    func incrCard(index: Int, incr: Int) {
        self.deck.objectWillChange.send()
        self.deck.changeCardCount(index: index, incr: incr)
        
        // because if we remove all the cards then editing mode
        // should be off so our users don't get anxious about
        // not being able to turn off that mode :]
        if self.deck.cardCount() == 0 {
            self.editingMode = false
        }
        
        self.changedSomething = true
    }
    
    func cardBanned(index: Int) -> Bool {
        return (self.deck.cards[index].standardBanned && self.deck.legality() != "Expanded") || (self.deck.cards[index].expandedBanned && self.deck.legality() != "Standard")
    }
    
    func cardCountView(index: Int) -> some View {
        return ZStack {
            Circle()
                .frame(width: 40, height: 40)
                .padding(.top, 100)
                .overlay(
                  Circle()
                 .stroke(Color.black,lineWidth: 5)
                    .padding(.top, 100)
                ).foregroundColor(Color.white)
            
            if cardBanned(index: index) {
                Button(action: {
                    self.showBannedAlert = true
                })
                {
                    Text("❗")
                        .font(.title)
                        .padding(.top, 100)
                        .padding(.leading, 25)
                }
                .alert(isPresented: $showBannedAlert) {
                    Alert(title: Text("Banned Card"), message: Text(self.deck.cards[index].content["name"] as! String + " is banned. Please delete this card for your deck to be Standard or Expanded legal."), primaryButton: .destructive(Text("Delete")) {
                        self.changedSomething = true
                        self.deck.removeCard(index: index)
                        },
                        secondaryButton: .default(Text("I'll pass")))
                }
                
            }
            
            Text(String(self.deck.cardCount(index: index)))
                .foregroundColor(Color.black)
                .fontWeight(.bold)
                .padding(.top, 100)
        }
    }
    
    func cardView(rowNumber: Int, columnNumber: Int, cards: [Card]) -> some View {
        if rowNumber * 3 + columnNumber >= cards.count {
            return AnyView(EmptyView())
        }
        let selectedCard = cards[rowNumber * 3 + columnNumber]
//        print(selectedCard.content["name"] as! String)
        let index = self.deck.cards.firstIndex(where: {$0.id == selectedCard.id})!
        
        if editingMode {
        return AnyView(
            ZStack {
                Image(uiImage: cards[rowNumber * 3 + columnNumber].image)
                self.cardCountView(index: index)
                }
                 .onLongPressGesture() {
                    self.editingMode = !self.editingMode
                    // bzzt
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                 }
                .simultaneousGesture(DragGesture()
                .onChanged { value in
                    if self.firstPosition == .zero {
                        self.firstPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                    }
            }   // 4.
                .onEnded { value in
                    print("HI")
                    self.newPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                    
                    let newWidth = Int(self.newPosition.width)
                    let firstWidth = Int(self.firstPosition.width)
                    
                    if (newWidth > firstWidth + swipeLRTolerance) {
                        if (self.deck.cards[index].count == 4 && !self.deck.cards[index].ifBasicEnergy()) {
                            self.tooManyCardsAlert = true
                            
                            // bzzt
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                        }
                        else {
                            self.incrCard(index: index, incr: 1)
                            
                            // bzzt
                            let generator = UISelectionFeedbackGenerator()
                            generator.selectionChanged()
                        }
                    }
                    else if (newWidth + swipeLRTolerance < firstWidth) {
                        self.incrCard(index: index, incr: -1)
                        
                        // bzzt
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                    }
                    self.firstPosition = .zero
                })
        .alert(isPresented: $tooManyCardsAlert) {
            Alert(title: Text("Oops"), message: Text("You can't add more than 4 copies of a single card."), dismissButton: .default(Text("Got it!")))
        }
        )
        }
        return AnyView(
            ZStack {
                Image(uiImage: cards[rowNumber * 3 + columnNumber].image)
                self.cardCountView(index: index)
                }

            .onTapGesture {
                
            }
            .onLongPressGesture() {
                // bzzt
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
               self.editingMode = !self.editingMode
            }
        )
    }
    
    func save() -> some View {
        return self.changedSomething ? AnyView(Button(action: {
            // if this is an already saved deck, when we save just override what's
            // in there for the deck of this name
            if self.deck.name != "New Deck" {
                let defaults = UserDefaults.standard
                var newDecks = defaults.object(forKey: "decks") as? [String: String] ?? [String: String]()

                newDecks[self.deck.name] = self.deck.deckOutput()
                defaults.set(newDecks, forKey: "decks")
                self.savedDecks.update()
                
                // bzzt
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                self.changedSomething = false
                
                return
            }
            else {
                self.editDeck()
            }
        })
        {
            Text("Save")
            })
            : AnyView(Text("Saved ✅").foregroundColor(Color.green))
    }
    
    func edit() -> some View {
        return AnyView(Button(action: {
            self.editDeck()
        })
        {
            Text("Rename")
        })
    }
    
    func editDeck() {
        let oldDeckName = self.title
        self.title = ""
        let alertHC = UIHostingController(rootView: SaveDeck(deck: self.deck, savedDecks: self.savedDecks, deckName: self.$title, oldDeckName: oldDeckName))

        alertHC.preferredContentSize = CGSize(width: 300, height: 200)
        alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet

        UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
    }
    
    func delete() -> some View {
        return Button(action: {
            self.showDeleteDeck = true
        }) {
            Text("Delete")
                .foregroundColor(Color.red)
        }.actionSheet(isPresented: self.$showDeleteDeck) {
            ActionSheet(title: Text("Are you sure you want to delete " + self.deck.name + "?"), message: Text("Deleting will remove all data."),
                        buttons: [.default(Text("Cancel")),
                                  .destructive(Text("Delete"), action: self.deleteDeck)])
        }
    }
    
    func editMode() -> some View {
        return Button(action: {
            self.showDeleteDeck = true
        }) {
            Text("Edit Card")
                .foregroundColor(Color.red)
        }.actionSheet(isPresented: self.$showDeleteDeck) {
            ActionSheet(title: Text("Are you sure you want to delete " + self.deck.name + "?"), message: Text("Deleting will remove all data."),
                        buttons: [.default(Text("Cancel")),
                                  .destructive(Text("Delete"), action: self.deleteDeck)])
        }
    }
    
    func deleteDeck() {
        let defaults = UserDefaults.standard
        var newDecks = defaults.object(forKey: "decks") as? [String: String] ?? [String: String]()

        newDecks.removeValue(forKey: self.deck.name)
        defaults.set(newDecks, forKey: "decks")
        self.savedDecks.update()
        
        // bzzt
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        self.saveDeckName = ""
        self.deckViewOn = false
    }
    
    func export() -> some View{
        return AnyView( Button(action: {
            self.showExportImageView = true
        }) {
            Text("Export")
        })
        .sheet(isPresented: $showExportImageView) {
            ExportImageView(showExportImageView: self.$showExportImageView, deck: self.deck, title: self.$title, leaksMode: self.$leaksMode, showSettingsView: self.$showSettingsView, showDeckView: self.$deckViewOn)
        }
    }
    
    func cardsView(cards: [Card]) -> some View {
        return AnyView (
            ForEach (0 ..< self.rowCount(cards: cards), id: \.self) { rowNumber in
            HStack {
                ForEach (0 ..< 3, id: \.self) { columnNumber in
                    self.cardView(rowNumber: rowNumber, columnNumber: columnNumber, cards: cards)
                }
            }
        }
        )
    }
    
    var body: some View {
        // duplicate code
        let supertypes = ["Pokémon", "Trainer", "Energy"]
        var supertypeCards: [[Card]] = []
        var supertypeCounts: [Int] = [0, 0, 0]
        
        var ctr = 0
        for supertype in supertypes {
            let filteredCards = self.deck.cards.filter { $0.getSupertype() == supertype }
            supertypeCards.append(filteredCards)
            
            for card in filteredCards {
                supertypeCounts[ctr] += card.count
            }
            
            ctr += 1
        }
        
        let trainerSubtypes = ["Supporter", "Item", "Pokémon Tool", "Stadium"]
        var trainerSubtypeCards: [[Card]] = []
        var trainerSubtypeCounts: [Int] = [0, 0, 0, 0]
        
        ctr = 0
        if supertypeCounts[1] > 0 {
            for trainerType in trainerSubtypes {
                let filteredCards = supertypeCards[1].filter { $0.getSubtype() == trainerType }
                trainerSubtypeCards.append(filteredCards)
                
                for card in filteredCards {
                    trainerSubtypeCounts[ctr] += card.count
                }
                
                ctr += 1
            }
            
            // now rearrange the trainers
            supertypeCards[1] = trainerSubtypeCards[0] + trainerSubtypeCards[1] + trainerSubtypeCards[2] + trainerSubtypeCards[3]
        }
        
        var subtitle = String(self.deck.cardCount()) + " cards"
        
        let subtitleView = HStack {
            Text(subtitle)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            if self.deck.cardCount() != 60 {
                Button(action: {
                    self.showNotEnoughCards = true
                }) {
                    Text("⚠️")
                }
                .alert(isPresented: $showNotEnoughCards) {
                    Alert(title: Text("Illegal Deck"), message: Text("Your deck must have exactly 60 cards to be legal."), dismissButton: .default(Text("Got it!")))
                }
            }
            else {
                Text("✔️")
            }

        }
        
        let legality = deck.standardLegal ? "Standard" : deck.expandedLegal ? "Expanded" : "Unlimited"
        
        let formatView = Text(legality)
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(.gray)
        
        let editingModeText = Text("Editing...")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(.gray)
        
        return VStack(alignment: .leading) {
            HStack {
                subtitleView
                formatView
            }

            self.editingMode ? editingModeText : nil
                HStack {
                    self.save()
                    self.edit()
                    self.delete()
                    self.export()
                    
                    Button(action: {
                        let alertHC = UIHostingController(rootView: SearchView(deck: self.deck, changedSomething: self.$changedSomething, showAds: self.$showAds))

                        alertHC.preferredContentSize = CGSize(width: 1000, height: 1000)
                        alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet

                        UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
                    }) {
                        Text("Add card")
                    }
                }
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach (0 ..< supertypes.count) { supertype in
                            Text(supertypes[supertype] + " (" + String(supertypeCounts[supertype]) + ")")
                                .font(.title)
                                .fontWeight(.bold)
                            self.cardsView(cards: supertypeCards[supertype])
                        }
                        HStack {
                            Spacer()
                        }
                    }
                }
            showAds ? SmallAdBanner().frame(width: UIScreen.main.bounds.width, height: 50, alignment: .center) : nil
            
        }.navigationBarTitle(self.title)
            .padding(.leading, showAds ? 40 : 20)
        }
    }
