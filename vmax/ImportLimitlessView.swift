//
//  ImportLimitlessView.swift
//  Pal Pad
//
//  Created by Jared Grimes on 12/25/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI
import SwiftSoup

let limitlessUrlBase = "https://limitlesstcg.com"

struct LimitlessArchetype: Hashable {
    var name: String
    var href: String
}

struct LimitlessCard: Hashable {
    var name: String
    var set: String
    var number: String
    var count: String
}

struct ImportLimitlessView: View {
    let url = URL(string: limitlessUrlBase + "/decks/")!
    @State var decks: [LimitlessArchetype] = []
    @Binding var deckViewOn: Bool
    @Binding var limitlessViewOn: Bool
    @Binding var deck: Deck
    @Binding var changedSomething: Bool
    
    func loadDecks() {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in  guard let data = data else {
            print("data was nil")
            return
          }
        guard let html = String(data: data, encoding: .utf8) else {
            print("couldn't cast data into String")
            return
          }
            
            guard let doc: Document = try? SwiftSoup.parse(html) else { return }
            guard let table = try? doc.getElementsByClass("rankingtable").first() else { return }
            guard let decks = try? table.select("tr") else { return }
            
            var ctr = 0
            for deck in decks {
                if ctr > 0 {
                    guard let deckLink = try? deck.select("a") else { return }
                    guard let deckHref: String = try? deckLink.attr("href") else { return }
                    guard let deckName = try? deckLink.text() else { return }
                    
                    let arch = LimitlessArchetype(name: deckName, href: deckHref)
                    self.decks.append(arch)
                }
                ctr += 1
            }

        }
        task.resume()
    }
    
    var body: some View {
        NavigationView {
            List(self.decks, id: \.self) { deck in
                NavigationLink(destination: LimitlessArchetypeView(name: deck.name, href: deck.href, deckViewOn: self.$deckViewOn, limitlessViewOn: self.$limitlessViewOn, deck: self.$deck, changedSomething: self.$changedSomething)) {
                    Text(deck.name)
                }
            }.onAppear { self.loadDecks() }
            .navigationBarTitle("Archetypes")
        }
    }
}

struct LimitlessArchetypeView: View {
    var name: String
    var href: String
    @State var decks: [LimitlessArchetype] = []
    @State var cards: [LimitlessCard] = []
    @Binding var deckViewOn: Bool
    @Binding var limitlessViewOn: Bool
    @Binding var deck: Deck
    @Binding var changedSomething: Bool
    @State var sets: [[String: Any]] = []
    
    func loadDecks() {
        let url = URL(string: limitlessUrlBase + href + "&view=results")!
        print(limitlessUrlBase + href + "&view=results")
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in  guard let data = data else {
            print("data was nil")
            return
          }
        guard let html = String(data: data, encoding: .utf8) else {
            print("couldn't cast data into String")
            return
          }
            print("yuhyuh")
            guard let doc: Document = try? SwiftSoup.parse(html) else { return }
            guard let table = try? doc.getElementsByClass("rankingtable").first() else { return }
            guard let decks = try? table.select("tr") else { return }

            var first = true
            for deck in decks {
                if !first {
                    guard let deckName = try? deck.text() else { return }
                    guard let deckLink = try? deck.select("[href*=/decks/]") else { return }
                    guard let deckHref: String = try? deckLink.attr("href") else { return }
                    let arch = LimitlessArchetype(name: deckName, href: deckHref)
                    self.decks.append(arch)
                }
                first = false
            }

        }
        task.resume()
    }
    
    func getSets(href: String) {
        // this immediately calls getDeck on execution
        if self.sets.count > 0 {
            self.getDeck(href: href)
            return
        }
        
        let setLegalityUrl = URL(string: urlBase + "sets")!
        let initTask = URLSession.shared.dataTask(with: setLegalityUrl) { (data, response, error) in
            if error == nil {
               let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let dict = json as? [String: Any] {
                    if let sets = dict["sets"] as? [[String: Any]] {
                        self.sets = sets
                        self.getDeck(href: href)
                    }
                }
                else {
                    print("oh no")
                }
            }
        }
        initTask.resume()
    }
    
    func getDeck(href: String) {
        changedSomething = true
        self.deck.clear()
        
        // scrape limitless
        let url = URL(string: limitlessUrlBase + href)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in  guard let data = data else {
            print("data was nil")
            return
          }
        guard let html = String(data: data, encoding: .utf8) else {
            print("couldn't cast data into String")
            return
          }
            guard let doc: Document = try? SwiftSoup.parse(html) else { return }
            guard var cards = try? doc.select("[href*=/cards/]") else { return }
            
            var ctr = 0
            for card in cards {
                if ctr >= 4 {
                    try? print(card.text())
                    guard var arr = try? card.text().components(separatedBy: " ") else { return }
                    let cardCount = arr[0]
                    arr.removeFirst()
                    let cardName = arr.joined(separator: " ")
                    
                    guard let cardHref: String = try? card.attr("href") else { return }
                    let hrefSplit = cardHref.components(separatedBy: "/")
                    let cardSet = setConvert(ptcgoCode: hrefSplit[2])
                    let cardNumber: String = hrefSplit[3]
                    var urlString = urlBase

                    if cardName.contains("Unit Energy") {
                        urlString += "cards?name=Unit Energy"
                    }
                    else {
                        urlString += "cards?name=" + cardName
                    }
                    
                    
                    // normal cards + promos
                    if "0"..."9" ~= cardNumber.prefix(1) || "sm" == cardNumber.prefix(2) {
                        urlString += "&setCode=" + cardSet + "&number=" + cardNumber
                    }
                    // shiny vault
                    else if "sv" == cardNumber.prefix(2) {
                        urlString += "&number=" + cardNumber
                    }
                    // everything else should be basic energy
                    else {
                        urlString += "&setCode=" + energyVersion
                    }
                    
                    urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    
                    if urlString.contains("%20%E2%99%A2") {
                        let arr = urlString.components(separatedBy: "%20%E2%99%A2")
                        urlString = arr.joined()
                    }
                    
                    print(urlString)
                    
                    // get card query
                    let url = URL(string: urlString)!
                    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if error == nil {
                            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                            if let dictionary = json as? [String: Any] {
                                if let cards = dictionary["cards"] as? [[String: Any]] {
                                    print(urlString)
                                    print(cardName)
                                    let content = cards[0]
                                    let c = Card(content: content, count: Int(cardCount)!)
                                    
                                    let imageUrl = c.getImageUrl(cardDict: content)
                                    let task = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                                        if error == nil {
                                            c.image = c.getImageFromData(data: data!)
                                            self.deck.addLimitlessCard(card: c)
                                        }
                                    }
                                    task.resume()
                                }
                            }
                        }
                        else {
                            print(error)
                        }
                    }
                    task.resume()
                }
                ctr += 1
            }
            self.deck.name = "New Deck"
            self.limitlessViewOn = false
            self.deckViewOn = true
        }
        task.resume()
    }
    var body: some View {
        List(self.decks, id: \.self) { deck in
            Button(action: {self.getSets(href: deck.href) }) {
                Text(deck.name)
            }.disabled(deck.href == "")
        }.onAppear { self.loadDecks() }
            .navigationBarTitle(self.name)
    }
}
