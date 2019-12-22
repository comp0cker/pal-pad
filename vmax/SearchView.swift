//
//  ContentView.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

class Deck {
    private var cards: [Card] = []
    private var cardss: [String] = []
    private var yuh: String = ""
    
    func addCard(card: Card) {
        let duplicateCard =  cards.contains {$0.content == card.content}
        if duplicateCard {
            print("duplicate card!")
            let index = cards.firstIndex {$0.content == card.content}
            cards[index!].addCard()
            // wtf????
        }
        else {
            cards.append(card)
        }
    }
    
    func getImage(index: Int) -> Image {
        return cards[index].image
    }
    
    func uniqueCardCount() -> Int {
        return self.cards.count
    }
    
    func cardCount(index: Int) -> Int {
        return cards[index].count
    }
    
    func jsonOutput() -> String {
        var dataStrings: [String] = []
        for card in self.cards {
            print(card.content)
            var ds = String(data: card.content, encoding: .utf8)!
            dataStrings.append(ds)
        }
        guard let data = try? JSONSerialization.data(withJSONObject: dataStrings, options: []) else {
            return ""
        }
        let string = String(data: data, encoding: String.Encoding.utf8)
        return string!
    }
}

class Card {
    var content: Data
    var image: Image
    var count: Int = 1
    
    init(content: Data, image: Image) {
        self.content = content
        self.image = image
    }
    
    func addCard() {
        count += 1
    }
}

struct SearchView: View {
    @State var image = Image(systemName: "card")
    @State var searchQuery = ""
    @State var searchResults: [Card] = []
    var urlBase = "https://api.pokemontcg.io/v1/"
    var imageUrlBase = "https://images.pokemontcg.io/"
    
    @State private var imageWidth: CGFloat = 0
    @State private var imageHeight: CGFloat = 0
    
    @Binding var showSearch: Bool
    @Binding var deck: Deck
    
    func fetchImage(url: String) {
        let imageUrl = URL(string: url)!
        let task = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if error == nil {
                var uiImage = UIImage(data: data!)!
                
                UIGraphicsBeginImageContext(CGSize(width: self.imageWidth, height: self.imageHeight))
                uiImage.draw(in: CGRect(x: 0, y: 0, width: self.imageWidth, height: self.imageHeight))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                var card = Card(content: data!, image: Image(uiImage: newImage!))
                self.searchResults.append(card)
            }
        }
        task.resume()
    }
    
    func searchCards() {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let heightToWidth: CGFloat = 343 / 246
        
        self.imageWidth = screenWidth / 4
        self.imageHeight = self.imageWidth * heightToWidth
        
        var url = URL(string: urlBase + "cards?name=" + searchQuery)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
//                print(json)
                if let dictionary = json as? [String: Any] {
                    if let cards = dictionary["cards"] as? [[String: Any]] {
                        for (card) in cards {
                            var url = self.imageUrlBase
                            
                            if let setCode = card["setCode"] as? String {
                                url += setCode + "/"
                            }
                            if let number = card["number"] as? String {
                                url += number + ".png"
                            }
                            self.fetchImage(url: url)
                        }
                    }
                }
            }
            else {
                print(error)
            }
        }
        task.resume()
    }
    
    func searchOff(card: Card) {
        var newDeck: Deck = deck
        newDeck.addCard(card: card)
        print("leggo")
        print(card)
        showSearch = false
    }

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    TextField("Card name", text: $searchQuery)
                    Button(action: searchCards) {
                        Text("Search")
                    }
                }

                VStack {
                    ForEach (0 ..< searchResults.count / 3, id: \.self) { rowNumber in
                        HStack {
                            ForEach (0 ..< 3, id: \.self) { columnNumber in
                                Button(action: {self.searchOff(card: self.searchResults[rowNumber * 3 + columnNumber])}) {
                                    self.searchResults[rowNumber * 3 + columnNumber].image.renderingMode(.original)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
