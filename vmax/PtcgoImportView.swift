//
//  PtcgoImportView.swift
//  Pal Pad
//
//  Created by Jared Grimes on 1/4/20.
//  Copyright © 2020 Jared Grimes. All rights reserved.
//

import SwiftUI

struct PtcgoImportView: View {
    @State var text: String = ""
    @Binding var deckViewOn: Bool
    @Binding var ptcgoViewOn: Bool
    @Binding var deck: Deck
    @Binding var changedSomething: Bool
    
    func importPtcgoList() {
        changedSomething = true
        self.deck.clear()
        
        for lineSub in self.text.split(separator: "\n") {
            var line = String(lineSub)
            
            if line.prefix(2) == "* " {
                line = String(line.suffix(line.count - 2))
            }
            
            // if it's not a number starting the line we don't care
            // (ie it's probably a garbage line like Trainers - 35)
            if line.prefix(1) < "0" || line.prefix(1) > "9" {
                continue
            }
            
            var lineSplit = line.split(separator: " ")
            
            // if there are less than 4 things delimited by spaces, it's
            // not in the format COUNT NAME SET NUMBER, so we don't care
            if lineSplit.count < 4 {
                continue
            }
            
            var cardArr = lineSplit
            cardArr.remove(at: cardArr.count - 1)
            cardArr.remove(at: cardArr.count - 1)
            cardArr.remove(at: 0)
            
            let cardName = String(cardArr.joined(separator: " "))
            let cardCount = Int(lineSplit[0])
            let ptcgoCardSet = String(lineSplit[lineSplit.count - 2])
            let cardSet = setConvert(ptcgoCode: ptcgoCardSet)
            
            // if an invalid set is inputted, we don't care
            if cardSet == "" {
                continue
            }
            
            let cardNumber = String(lineSplit[lineSplit.count - 1])
            
            var urlString = urlBase
            
            if cardSet == energyPtcgoSetCode {
                urlString += "cards?name=" + cardName + "&setCode=" + energyVersion
                urlString = fixUpQueryUrl(query: urlString)
            }
            else {
                urlString += "cards?setCode=" + cardSet + "&number=" + cardNumber
            }
            print(urlString)
            
            // get card query
            let url = URL(string: urlString)!
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    if let dictionary = json as? [String: Any] {
                        if let cards = dictionary["cards"] as? [[String: Any]] {
                            // if the card + number combination we put in is invalid, we don't care
                            if cards.count == 0 {
                                return
                            }
                            let content = cards[0]
                            let c = Card(content: content, count: cardCount!)
                            
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
        self.deck.name = "New Deck"
        self.ptcgoViewOn = false
        self.deckViewOn = true
    }
    
    var body: some View {
        VStack {
            Text("Please paste in a PTCGO Deck list.").padding()
            Button(action: importPtcgoList) {
                Text("Enter")
            }
            TextView(
                text: $text
            ).padding()
        }
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {

        let myTextView = UITextView()
        myTextView.delegate = context.coordinator

        myTextView.font = UIFont(name: "HelveticaNeue", size: 15)
        myTextView.isScrollEnabled = true
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
        myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)

        return myTextView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var parent: TextView

        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            print("text now: \(String(describing: textView.text!))")
            self.parent.text = textView.text
        }
    }
}
