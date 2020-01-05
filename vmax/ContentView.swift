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
import UIKit

final private class BannerVC: UIViewControllerRepresentable  {

    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeBanner)

        let viewController = UIViewController()
        view.adUnitID = bannerID
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)
        view.load(GADRequest())

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct HomeView {
    var name: String
    var legality: String
    var deck: String
}

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
    
    @State var showImportDeck: Bool = false
    @State var showLimitlessView: Bool = false
    @State var showPtcgoView: Bool = false
    @State var showHelpView: Bool = false
    
    @State var changedSomething: Bool = false

    func deckOn() {
        deckViewOn = true
    }
    
    func loadDeck(json: [[String: String]], name: String) {
        self.deck = Deck(name: name)
        var actuallyRun = false
        
        for card in json {
            if actuallyRun {
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
                                c.count = count
                                self.deck.addCard(card: c, legality: true)
                            }
                        }
                        task.resume()
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
            actuallyRun = true
        }
    }
    
    func importLimitless() {
        showLimitlessView = true
    }
    
    func importPtcgo() {
        showPtcgoView = true
    }
    
    func getLegality(deck: String) -> String {
        let data = Data(deck.utf8)
        do {
            // make sure this JSON is in the format we expect
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] {
                let legality = json[0]["legality"]
                return legality!
            }
            else {
                print("poop")
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        return "null"
    }
    
    var body: some View {
        var decks: [HomeView] = self.savedDecks.list.map {HomeView(name: $0.key, legality: getLegality(deck: $0.value), deck: $0.value)}
        var legalities = ["Standard", "Expanded", "Unlimited"]
        var legalityDecks: [[HomeView]] = []
        for legality in legalities {
            legalityDecks.append(decks.filter{$0.legality == legality})
        }
        
        let realDecks = legalityDecks.filter{$0.count > 0}
        
        // hides those DISGUSTING LINES
        UITableView.appearance().separatorColor = .clear

        return VStack {
            NavigationView {
                VStack(alignment: .leading) {
                    List {
                        NavigationLink (destination: DeckView(deck: deck, title: deck.name, savedDecks: savedDecks, deckViewOn: $deckViewOn, changedSomething: $changedSomething), isActive: $deckViewOn) {
                            Text("Most Recent: " + deck.name)
                        }
                        ForEach (0 ..< realDecks.count, id: \.self) { legalityPos in
                            Group {
                                Text(realDecks[legalityPos][0].legality)
                                .font(.title)
                                .fontWeight(.bold)
                                
                                ForEach (0 ..< realDecks[legalityPos].count, id: \.self) { pos in
                                    Button(action: {
                                        self.loadedDeck = realDecks[legalityPos][pos].deck
                                        let name = realDecks[legalityPos][pos].name
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
                                        Text(realDecks[legalityPos][pos].name)
                                    }
                                }
                            }

                        }

                        Button(action: {
                            self.deck = Deck(name: "New Deck")
                            self.deckOn()
                        }) {
                            Text("➕ New Deck")
                        }
                        .sheet(isPresented: $showLimitlessView) {
                            ImportLimitlessView(deckViewOn: self.$deckViewOn, limitlessViewOn: self.$showLimitlessView, deck: self.$deck, changedSomething: self.$changedSomething)
                        }
                        
                        Button(action: {
                            self.showImportDeck = true
                        }) {
                            Text("⬇️ Import Deck")
                        }.actionSheet(isPresented: self.$showImportDeck) {
                        ActionSheet(title: Text("How would you like to import deck?"), message: Text("You can either import by pasting in a PTCGO style deck list, or by browsing decks on limitlesstcg.com."),
                                    buttons: [.default(Text("PTCGO import"), action: {self.importPtcgo()}),
                                              .default(Text("Limitless import"), action: {self.importLimitless()})])
                    }
                        .sheet(isPresented: $showPtcgoView) {
                            PtcgoImportView(deckViewOn: self.$deckViewOn, ptcgoViewOn: self.$showPtcgoView, deck: self.$deck, changedSomething: self.$changedSomething)
                        }
                        
                            Button(action: {
                                self.showHelpView = true
                            }) {
                                Text("ℹ️ Help")
                            }
                            .sheet(isPresented: $showHelpView) {
                                HelpView()
                            }
//                    Button(action: {
//                        let defaults = UserDefaults.standard
//                        defaults.set("", forKey: "decks")
//                    }) {
//                        Text("w i p e")
//                    }
                }.navigationBarTitle("Pal Pad 📔")
            }
            }.navigationViewStyle(StackNavigationViewStyle())
                .onAppear() {
                let defaults = UserDefaults.standard
                if !defaults.bool(forKey: "sets") {
                    let setLegalityUrl = URL(string: urlBase + "sets")!
                    let initTask = URLSession.shared.dataTask(with: setLegalityUrl) { (data, response, error) in
                        if error == nil {
                           let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                            if let dict = json as? [String: Any] {
                                if let sets = dict["sets"] as? [[String: Any]] {
                                    defaults.set(sets, forKey: "sets")
                                }
                            }
                            else {
                                print("oh no")
                            }
                        }
                    }
                    initTask.resume()
                }
            }
    }
}
}
