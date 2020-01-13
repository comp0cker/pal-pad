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
    
    @Binding var leaksMode: Bool
    @Binding var showSettingsView: Bool
    @Binding var showDeckView: Bool
    
    @State var name: String = ""
    @State var playerId: String = ""
    @State var dateOfBirth: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                Group {
                    Text("Image")
                        .foregroundColor(leaksMode ? .primary : .gray)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Toggle(isOn: self.$portraitMode) {
                        Text("Portrait mode (up and down ways image)")
                        .foregroundColor(leaksMode ? .primary : .gray)
                    }.padding()
                    
                    Toggle(isOn: self.$stacked) {
                        Text("Visible stacking of cards in image")
                            .foregroundColor(leaksMode ? .primary : .gray)
                        .lineLimit(nil)
                    }.padding()
                    
                    Toggle(isOn: self.$newTypeLines) {
                        Text("New lines for Pokémon, Trainer, Energy")
                            .foregroundColor(leaksMode ? .primary : .gray)
                        .lineLimit(nil)
                    }.padding()
                    
                    Toggle(isOn: self.$showTitle) {
                        Text("Show title at the top")
                        .foregroundColor(leaksMode ? .primary : .gray)
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
                }.disabled(!leaksMode)
                
    //            Image(uiImage: getDeckImage()!)
                
                Divider()
                
                Group {
                    Text("Tournament Decklist")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(leaksMode ? .primary : .gray)
                        .padding()
                    Text("Generates a list of your deck for use in sanctioned Pokémon tournaments. Exports as an image.")
                        .foregroundColor(leaksMode ? .primary : .gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    TextField("Name", text: self.$name).padding()
                    TextField("POP ID", text: self.$playerId).padding()
                    TextField("Date of Birth (MM/DD/YYYY)", text: self.$dateOfBirth).padding()
                    
                    Button(action: {
                        self.showExportImageView = false
                        self.deck.name = self.title
                        
                        let uiImage = drawExportPDF(deck: self.deck, name: self.name, playerId: self.playerId, dateOfBirth: self.dateOfBirth)
                        
                        let vc = UIActivityViewController(activityItems: [uiImage], applicationActivities: [])
                        UIApplication.shared.windows[1].rootViewController?.present(vc, animated: true)
                    })
                    {
                        Text("Generate")
                        .padding()
                    }
                }.disabled(!leaksMode)
                
                if !leaksMode {
                    Button(action: {
                        self.showExportImageView = false
                        self.showDeckView = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showSettingsView = true
                        }
                    })
                    {
                        Text("Want these modes enabled? Buy the Leaks Package here.")
                        .padding()
                    }
                }
                
                Divider()
                
                Group {
                    Text("PTCGO")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    Text("Generates a text list of your deck for import in PTCGO. Copies list to clipboard.")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    Button(action: {
                        let pasteboard = UIPasteboard.general
                        pasteboard.string = self.deck.ptcgoOutput()
                        self.showDeckCopied = true
                    }) {
                        Text("Generate")
                    }.alert(isPresented: $showDeckCopied) {
                        Alert(title: Text("Deck list copied!"), message: Text("Paste anywhere for use."), dismissButton: .default(Text("Got it!")))
                    }.padding()
                }
            }
        }
    }
}
