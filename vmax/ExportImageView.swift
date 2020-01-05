//
//  ExportImageView.swift
//  Pal Pad
//
//  Created by Jared Grimes on 12/27/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

struct ExportImageView: View {
    @State var portraitMode: Bool = true
    @State var stacked: Bool = true
    @State var newTypeLines: Bool = false
    @State var showTitle: Bool = false
    @State var showDeckCopied: Bool = false
    
    @Binding var showExportImageView: Bool
    @ObservedObject var deck: Deck
    @Binding var title: String
    
    var body: some View {
        VStack {
            Text("Image Output")
                .font(.title)
                .fontWeight(.bold)
            
            Toggle(isOn: self.$portraitMode) {
                Text("Portrait mode (up and down ways image)")
            }.padding()
            
            Toggle(isOn: self.$stacked) {
                Text("Visible stacking of cards in image")
                .lineLimit(nil)
            }.padding()
            
            Toggle(isOn: self.$newTypeLines) {
                Text("New lines for Pokemon, Trainer, Energy")
                .lineLimit(nil)
            }.padding()
            
            Toggle(isOn: self.$showTitle) {
                Text("Show title at the top")
            }.padding()
            
            Button(action: {
                self.showExportImageView = false
                self.deck.name = self.title
                
                let uiImage = UIImage.imageByMergingImages(deck: self.deck, stacked: self.stacked, portraitMode: self.portraitMode, newTypeLines: self.newTypeLines, showTitle: self.showTitle)
                
                let vc = UIActivityViewController(activityItems: [uiImage], applicationActivities: [])
                UIApplication.shared.windows[1].rootViewController?.present(vc, animated: true)
            }) {
                ZStack {
                    Text("Generate")
                }
            }
            
            Divider()
            
            Text("PTCGO Output")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            Text("Generates a text list of your deck for import in PTCGO. Copies list to clipboard.")
                .padding()
            Button(action: {
                let pasteboard = UIPasteboard.general
                pasteboard.string = self.deck.ptcgoOutput()
                self.showDeckCopied = true
            }) {
                Text("Generate")
            }.alert(isPresented: $showDeckCopied) {
                Alert(title: Text("Deck list copied!"), message: Text("Paste anywhere for use."), dismissButton: .default(Text("Got it!")))
            }
        }
    }
}
