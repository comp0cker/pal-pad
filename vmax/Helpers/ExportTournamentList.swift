//
//  ExportTournamentList.swift
//  Pal Pad
//
//  Created by Jared Grimes on 1/8/20.
//  Copyright © 2020 Jared Grimes. All rights reserved.
//

import Foundation
import SwiftUI

func getDeckImage() -> UIImage? {
   let filePath = Bundle.main.url(forResource: "list", withExtension: "pdf")!
    return drawPDFfromURL(url: filePath)
}

func writeText(text: String, xpos: Int, ypos: Int, img: UIImage) {
    let fontSize: Int = 9
    let attributedString = NSAttributedString(string: text)

    attributedString.draw(with: CGRect(x: xpos, y: ypos, width: Int(img.size.width), height: Int(img.size.height)), options: .usesLineFragmentOrigin, context: nil)
}

func drawExportPDF(deck: Deck, name: String, playerId: String, dateOfBirth: String) -> UIImage {
    var img: UIImage = getDeckImage()!
    
    UIGraphicsBeginImageContext(img.size)
    img.draw(at: CGPoint.zero)

    // Get the current context
    let context = UIGraphicsGetCurrentContext()!
    
    if deck.standardLegal {
        writeText(text: "✔️", xpos: 182, ypos: 57, img: img)
    }
    else if deck.expandedLegal {
        writeText(text: "✔️", xpos: 237, ypos: 57, img: img)
    }
    
    writeText(text: name, xpos: 92, ypos: 93, img: img)
    writeText(text: playerId, xpos: 280, ypos: 93, img: img)
    
    let dobSplit = dateOfBirth.split(separator: "/")
    
    if dobSplit.count == 3 {
        writeText(text: String(dobSplit[0]), xpos: 495, ypos: 93, img: img)
        writeText(text: String(dobSplit[1]), xpos: 520, ypos: 93, img: img)
        writeText(text: String(dobSplit[2]), xpos: 548, ypos: 93, img: img)
        
        // JUNIORS
        if Int(String(dobSplit[2]))! >= juniorsCutoff {
            writeText(text: "✔️", xpos: 372, ypos: 112, img: img)
        }
        // MASTERS
        else if Int(String(dobSplit[2]))! <= mastersCutoff {
            writeText(text: "✔️", xpos: 372, ypos: 140, img: img)
        }
        // SENIORS
        else {
            writeText(text: "✔️", xpos: 372, ypos: 126, img: img)
        }

    }
    
    // duplicate code
    let supertypes = ["Pokémon", "Trainer", "Energy"]
    var supertypeCards: [[Card]] = []
    var supertypeCounts: [Int] = [0, 0, 0]
    
    var ctr = 0
    for supertype in supertypes {
        let filteredCards = deck.cards.filter { $0.getSupertype() == supertype }
        supertypeCards.append(filteredCards)
        
        for card in filteredCards {
            supertypeCounts[ctr] += card.count
        }
        
        ctr += 1
    }
    
    let trainerSubtypes = ["Supporter", "Item", "Pokémon Tool", "Stadium"]
    var trainerSubtypeCards: [[Card]] = []
    var trainerSubtypeCounts: [Int] = [0, 0, 0, 0]
    
    ctr = 0
    if supertypeCounts[1] > 0 {
        for trainerType in trainerSubtypes {
            let filteredCards = supertypeCards[1].filter { $0.getSubtype() == trainerType }
            trainerSubtypeCards.append(filteredCards)
            
            for card in filteredCards {
                trainerSubtypeCounts[ctr] += card.count
            }
            
            ctr += 1
        }
        
            trainerSubtypeCards[0] = trainerSubtypeCards[0].sorted(by: { $0.count > $1.count })
            trainerSubtypeCards[1] = trainerSubtypeCards[1].sorted(by: { $0.count > $1.count })
            trainerSubtypeCards[2] = trainerSubtypeCards[2].sorted(by: { $0.count > $1.count })
            
            // now rearrange the trainers
            supertypeCards[1] = trainerSubtypeCards[0] + trainerSubtypeCards[1] + trainerSubtypeCards[2] + trainerSubtypeCards[3]
        }
        
        supertypeCards[0] = supertypeCards[0].sorted(by: { $0.count > $1.count })
        supertypeCards[2] = supertypeCards[2].sorted(by: { $0.count > $1.count })
    
    let xoffset = 280
    var yoffset = 196
    
    var superCtr = 0
    for supertype in supertypes {
        if supertype == "Trainer" {
            yoffset = 371
        }
        
        if supertype == "Energy" {
            yoffset = 653
        }
        
        for card in supertypeCards[superCtr] {
            var text = String(card.count) + " " + (card.content["name"] as! String)
            
            if card.getSupertype() == "Pokémon" {
                text = String(card.count) + " " + (card.content["name"] as! String) + "\t" + setConvertToPtcgo(regularCode: card.content["setCode"] as! String) + " " + (card.content["number"] as! String)
            }
            
            writeText(text: text, xpos: xoffset, ypos: yoffset, img: img)
            yoffset += 11
        }
        superCtr += 1
    }
    
    // draw the app icon
    let image = UIImage(named: "AppIcon")!
    let appIconDimension = 25
    let appNamePadding = 20
    let appTextWidth = 20
    
    let fontSize: Int = 20

    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: CGFloat(fontSize)),
    ]

    let string = "Pal Pad"
    let attributedString = NSAttributedString(string: string, attributes: attrs)
    
    image.draw(in: CGRect(x: 36, y: 753, width: appIconDimension, height: appIconDimension))
    attributedString.draw(with: CGRect(x: 70, y: 757, width: 1000, height: 100), options: .usesLineFragmentOrigin, context: nil)
    
    // Save the context as a new UIImage
     let myImage = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     // Return modified image
     return myImage!
}

func drawPDFfromURL(url: URL) -> UIImage? {
    guard let document = CGPDFDocument(url as CFURL) else { return nil }
    guard let page = document.page(at: 1) else { return nil }

    let pageRect = page.getBoxRect(.mediaBox)
    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
    let img = renderer.image { ctx in
        UIColor.white.set()
        ctx.fill(pageRect)

        ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

        ctx.cgContext.drawPDFPage(page)
    }

    return img
}
