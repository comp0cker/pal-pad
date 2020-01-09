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

let testAppUnitID = "ca-app-pub-3940256099942544/2934735716"
let prodAppUnitID = "ca-app-pub-2502317044774140/8553416246"

// CHANGE THIS WHEN YOU HIT PROD
let appUnitID = prod ? prodAppUnitID : testAppUnitID

final private class BigAdBanner: UIViewControllerRepresentable  {

    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeLargeBanner)

        let viewController = UIViewController()
        view.adUnitID = appUnitID
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeLargeBanner.size)
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
    @State var showSettingsView: Bool = false
    
    @State var changedSomething: Bool = false
    
    @State var showAds: Bool = !(UserDefaults.standard.bool(forKey: "adsRemoved") || !prod)
    @State var leaksMode: Bool = UserDefaults.standard.bool(forKey: "leaksMode") || !prod

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
        showImportDeck = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showLimitlessView = true
        }
    }
    
    func importPtcgo() {
        showImportDeck = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showPtcgoView = true
        }
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
                        NavigationLink (destination: DeckView(deck: deck, title: deck.name, savedDecks: savedDecks, deckViewOn: $deckViewOn, changedSomething: $changedSomething, showAds: $showAds, leaksMode: $leaksMode, showSettingsView: $showSettingsView), isActive: $deckViewOn) {
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
                        
                        NavigationLink (destination: SettingsView(showAds: self.$showAds, leaksMode: self.$leaksMode), isActive: self.$showSettingsView) {
                                Text("⚙️ Settings")
                            }
                        .sheet(isPresented: self.$showImportDeck) {
                                Text("Choose an import mode")
                                    .font(.title)
                                    .fontWeight(.bold)
                                .padding()
                                Text("You can either import by pasting in a PTCGO style deck list, or by browsing decks compiled by Limitless TCG")
                                .padding()
                                Button(action: self.importPtcgo){
                                    Text("PTCGO import")
                                }.padding()
                                Button(action: self.importLimitless) {
                                    Text("Limitless import")
                                }
                        }

                }.navigationBarTitle("Pal Pad 📔")
                    showAds ? BigAdBanner().frame(width: UIScreen.main.bounds.width, height: 100, alignment: .center) : nil
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
