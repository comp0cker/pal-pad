//
//  ImportLimitlessView.swift
//  Pal Pad
//
//  Created by Jared Grimes on 12/25/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI
import SwiftSoup

struct ImportLimitlessView: View {
    let url = URL(string: "https://limitlesstcg.com/decks/")!
    @State var decks: [String] = []
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
                    guard let deckName = try? deck.text() else { return }
                    self.decks.append(deckName)
                }
                ctr += 1
            }

        }
        task.resume()
    }
    
    var body: some View {
        VStack {
            List(self.decks, id: \.self) { deck in
                Text(deck)
            }.onAppear { self.loadDecks() }
        }
    }
}

struct ImportLimitlessView_Previews: PreviewProvider {
    static var previews: some View {
        ImportLimitlessView()
    }
}
