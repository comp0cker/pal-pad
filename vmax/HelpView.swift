//
//  HelpView.swift
//  Pal Pad
//
//  Created by Jared Grimes on 1/3/20.
//  Copyright © 2020 Jared Grimes. All rights reserved.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            Group {
                Spacer() 
                Text("Welcome to Pal Pad!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text("The best (and only) deck builder app on the App Store! This app was designed with simplicity in mind, so naturally things are a bit hard to use at first.")
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            }
            
            Divider()
            
            Group {
                Text("Making a Deck")
                    .font(.title)
                    .fontWeight(.bold)
                .padding()
                
                Text("Come on, who makes decks from scratch anymore? Well if you insist, there is a New Deck option you can hit to start a deck from scratch. Otherwise, Import Deck allows you to import a deck via a PTCGO output, or grab a list from Limitless right though the app (because let's be real, that's what goes on most of the time anyways). In the Limitless view, simply navigate through the archetype you'd like and select the deck you'd like to load into Pal Pad. Regardless of PTCGO or Limitless import, both will import all of the cards into a new deck, for you to rename to whatever spicy name you want.")
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            }
            
            Divider()
            
            Group {
                Text("Adding a Card")
                    .font(.title)
                    .fontWeight(.bold)
                .padding()
                
                Text("To add a card to your deck, hit the \"Add Card\" button at the top of the screen. You'll be able to search for the card you want by name. Once you click on the card, it will be added to your deck.")
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            }
            
            Divider()
            
            Group {
                Text("Change Card Count")
                    .font(.title)
                    .fontWeight(.bold)
                .padding()
                
                Text("To modify card count, hold on any card in your deck to instantiate Edit Mode. Once you are in edit view, the Editing... header will appear on the top of the screen. Then, you can swipe right on a card to add a copy, or swipe left on it to remove a copy. To leave Edit Mode, hold on any card.")
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            }
            
            Divider()
            
            Group {
                Text("Sharing Your Deck")
                    .font(.title)
                    .fontWeight(.bold)
                .padding()
                
                Text("By default, decks are saved onto your phone's local storage. To leak your deck to your friends, you can either export by PTCGO list or to an image. Both options are shown present in the Export menu, which is found on the top of your deck view page. You can change various settings for image export such as which orientation the image is exported in, if the cards should show as stacked or not, and others. Once you generate an image, you can use the social menu that pops up to send your busted deck to your friends, or hit Save Image to download the image to your Photos.")
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
