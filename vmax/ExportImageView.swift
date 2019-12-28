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
    
    @Binding var showExportImageView: Bool
    @ObservedObject var deck: Deck
    @Binding var title: String
    
    var body: some View {
        VStack {
            Toggle(isOn: self.$portraitMode) {
                Text("Portrait mode (up and down ways image)")
            }.padding()
            
            Toggle(isOn: self.$stacked) {
                Text("Visible stacking of cards in image as opposed to a number on each card")
            }.padding()
            
            Toggle(isOn: self.$newTypeLines) {
                Text("New lines for Pokemon, Trainer, Energy types (usually makes cards smaller)")
            }.padding()
            
            Toggle(isOn: self.$showTitle) {
                Text("Shows title at the top (also makes cards smaller)")
            }.padding()
            
            Button(action: {
                self.showExportImageView = false
                self.deck.name = self.title
                
                let uiImage = UIImage.imageByMergingImages(deck: self.deck, stacked: self.stacked, portraitMode: self.portraitMode, newTypeLines: self.newTypeLines, showTitle: self.showTitle)
                
                let vc = UIActivityViewController(activityItems: [uiImage], applicationActivities: [])
                UIApplication.shared.windows[1].rootViewController?.present(vc, animated: true)
            }) {
                ZStack {
                    Text("Generate output")
                }

            }
        }
    }
}
