//
//  ContentView.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI
import Combine

let urlBase = "https://api.pokemontcg.io/v1/"
let imageUrlBase = "https://images.pokemontcg.io/"

let imageWidth: CGFloat = UIScreen.main.bounds.width / 4
let imageHeight: CGFloat = imageWidth * 343 / 246

func json(from object:Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return nil
    }
    return String(data: data, encoding: String.Encoding.utf8)
}

class Deck: ObservableObject {
    @Published var cards: [Card] = []
    
    func addCard(card: Card) {
        let duplicateCard =  cards.contains {$0.id == card.id}
        if duplicateCard {
            print("duplicate card!")
            let index = cards.firstIndex {$0.id == card.id}
            cards[index!].count += 1
        }
        else {
            cards.append(card)
        }
    }
    
    func changeCardCount(index: Int, incr: Int) {
        cards[index].incrCount(incr: incr)
        
        // if card count less than zero outta here
        if cards[index].count <= 0 {
            cards.remove(at: index)
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
    
    func deckOutput() -> String {
        var out: [[String: String]] = []
        for card in self.cards {
            var cardOutput = [String: String]()
            cardOutput["content"] = json(from: card.content)!
            cardOutput["count"] = String(card.count)
            out.append(cardOutput)
        }
        return json(from: out)!
    }
}

class Card: ObservableObject {
    @Published var content: [String: Any]
    @Published var image: Image
    @Published var count: Int
    @Published var id: String
    
    init(content: [String: Any], image: Image) {
        self.content = content
        self.image = image
        
        self.id = ""
        if let id = content["id"] as? String {
            self.id = id
        }
        
        self.count = 1
    }
    
    func incrCount(incr: Int) {
        count += incr
    }
}

func getImageFromData(data: Data) -> Image {
    let uiImage = UIImage(data: data)!
    
    UIGraphicsBeginImageContext(CGSize(width: imageWidth, height: imageHeight))
    uiImage.draw(in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return Image(uiImage: newImage!)
}

struct SearchView: View {
    @State var image = Image(systemName: "card")
    @State var searchQuery = ""
    @State var searchResults: [Card] = []
    
    @Binding var showSearch: Bool
    @ObservedObject var deck: Deck
    
    func addCardToSearch(card: [String: Any]) {
        var url = imageUrlBase
        
        if let setCode = card["setCode"] as? String {
            url += setCode + "/"
        }
        if let number = card["number"] as? String {
            url += number + ".png"
        }
        
        let imageUrl = URL(string: url)!
        let task = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if error == nil {
                let image = getImageFromData(data: data!)
                
                let card = Card(content: card, image: image)
                self.searchResults.append(card)
            }
        }
        task.resume()
    }
    
    func searchCards() {
        let url = URL(string: urlBase + "cards?name=" + searchQuery)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
//                print(json)
                if let dictionary = json as? [String: Any] {
                    if let cards = dictionary["cards"] as? [[String: Any]] {
                        for (card) in cards {
                            self.addCardToSearch(card: card)
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
