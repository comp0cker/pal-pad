//
//  Images.swift
//  Pal Pad
//
//  Created by Jared Grimes on 12/26/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

func handleImageUrlExceptions(contents: [String: Any]) -> String {
    if contents["number"] as? String == "SM197" {
        return "https://assets.pokemon.com/assets/cms2/img/cards/web/DET/DET_EN_SM197.png"
    }
    return (contents["imageUrl"] as? String)!
}

struct frameSize {
    var height: Int
    var width: Int
}

struct testingParams {
    var imageFactor: Int
    var additionalYpadding: Int
}

func drawCardImage(deck: Deck, stacked: Bool, portraitMode: Bool, newTypeLines: Bool, showTitle: Bool, testing: Bool, imageFactor: Int, additionalYPadding: Int) -> testingParams {
    var width: Int = 1920
    var height: Int = 1080
    
    if portraitMode {
        height = 1920
        width = 1080
    }
    
    let size = CGSize(width: width, height: height)
    
    if !testing {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    }
        
    let imageWidth = width / imageFactor
    let imageHeight = imageWidth * 343 / 246
    let stackedOffset = 20
    
    let Xpadding = 20
    let Ypadding = 20
    
    var currentX = Xpadding
    var currentY = Ypadding + additionalYPadding
    
    if showTitle {
        let fontSize: Int = 76

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: CGFloat(fontSize)),
        ]

        let string = deck.name
        let attributedString = NSAttributedString(string: string, attributes: attrs)

        if !testing {
            attributedString.draw(with: CGRect(x: currentX, y: currentY, width: width, height: fontSize), options: .usesLineFragmentOrigin, context: nil)
        }

        currentY += fontSize + Ypadding
    }
    // additionalYPadding is missing FIX
    
    let supertypes = ["Pokémon", "Trainer", "Energy"]
    for supertype in supertypes {
        var filteredCards = deck.cards.filter { $0.getSupertype() == supertype }
        
        if supertype == "Trainer" && filteredCards.count > 0 {
            let trainerSubtypes = ["Supporter", "Item", "Stadium"]
            var trainerSubtypeCards: [[Card]] = []

            for trainerType in trainerSubtypes {
                let filteredCards = filteredCards.filter { $0.getSubtype() == trainerType }
                trainerSubtypeCards.append(filteredCards)
            }
            
            // now rearrange the trainers
            filteredCards = trainerSubtypeCards[0] + trainerSubtypeCards[1] + trainerSubtypeCards[2]
        }
        
        for card in filteredCards {
            var expectedWidth = imageWidth
            
            if stacked {
                expectedWidth += card.count * stackedOffset
            }
            
            // start a new row
            if currentX + expectedWidth >= width {
                currentX = Xpadding
                currentY += imageHeight + Ypadding
            }
            
            if stacked {
                for _ in 0 ..< card.count {
                    if !testing {
                        card.image.draw(in: CGRect(x: currentX, y: currentY, width: imageWidth, height: imageHeight))
                    }
                    currentX += stackedOffset
                }
                currentX += imageWidth
            }
            else {
                if !testing {
                    card.image.draw(in: CGRect(x: currentX, y: currentY, width: imageWidth, height: imageHeight))
                    
                    let countX = currentX - stackedOffset + 5 + imageWidth / 2
                    let countY = currentY + imageHeight * 2 / 3
                    
                    // draw the card count
                    let circleSize = 75
                    
                    let context = UIGraphicsGetCurrentContext()!
                    context.setLineWidth(10.0)
                    context.setStrokeColor(UIColor.black.cgColor)
                    context.setFillColor(UIColor.white.cgColor)
                    context.addEllipse(in: CGRect(x: countX - 22, y: countY - 5, width: circleSize, height: circleSize))
                    context.drawPath(using: .fillStroke) // or .fillStroke if need filling
                    
                    let fontSize: Int = 52
                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: CGFloat(fontSize)),
                    ]

                    let string = String(card.count)
                    let attributedString = NSAttributedString(string: string, attributes: attrs)
                    
                    attributedString.draw(with: CGRect(x: countX, y: countY, width: width, height: fontSize), options: .usesLineFragmentOrigin, context: nil)
                }
                currentX += imageWidth + stackedOffset
            }
        }
        if (newTypeLines) {
            currentX = Xpadding
            currentY += imageHeight + Ypadding
        }
    }
    
    let image = UIImage(named: "AppIcon")!
    let appIconDimension = portraitMode ? width / 10 : height / 10
    let appNamePadding = portraitMode ? width / 40 : height / 40
    let appTextWidth = portraitMode ? width / 4 : height / 4
    
    let fontSize: Int = 76

    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: CGFloat(fontSize)),
    ]

    let string = "Pal Pad"
    let attributedString = NSAttributedString(string: string, attributes: attrs)
    
    if !testing {
        image.draw(in: CGRect(x: width - appTextWidth - appNamePadding - appIconDimension, y: height - appIconDimension - appNamePadding, width: appIconDimension, height: appIconDimension))
        attributedString.draw(with: CGRect(x: width - appTextWidth / 2 - appNamePadding - appIconDimension, y: height - appIconDimension, width: width, height: fontSize), options: .usesLineFragmentOrigin, context: nil)
    }
    
    currentY += appIconDimension
    
    if !newTypeLines {
        currentY += imageHeight + Ypadding
    }

    if currentY < height {
        return testingParams(imageFactor: imageFactor, additionalYpadding: (height - currentY) / 2)
    }
    return testingParams(imageFactor: -1, additionalYpadding: 0)
}

extension UIImage {

    static func imageByMergingImages(deck: Deck, stacked: Bool, portraitMode: Bool, newTypeLines: Bool, showTitle: Bool) -> UIImage {
        let imageFactorRange = 5...20 // just in case...
        var imageFactor: Int = -1
        var additionalYPadding: Int = 0
        
        for fct in imageFactorRange {
            print("trying factor " + String(fct))
            let t: testingParams = drawCardImage(deck: deck, stacked: stacked, portraitMode: portraitMode, newTypeLines: newTypeLines, showTitle: showTitle, testing: true, imageFactor: fct, additionalYPadding: 0)
            
            imageFactor = t.imageFactor
            if imageFactor > 0 {
                additionalYPadding = t.additionalYpadding
                break
            }
        }
        drawCardImage(deck: deck, stacked: stacked, portraitMode: portraitMode, newTypeLines: newTypeLines, showTitle: showTitle, testing: false, imageFactor: imageFactor, additionalYPadding: additionalYPadding)
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

}

class ActivityViewController : UIViewController {

    var uiImage:UIImage!

    @objc func shareImage() {
        let vc = UIActivityViewController(activityItems: [uiImage!], applicationActivities: [])
        vc.excludedActivityTypes =  [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo
        ]
        present(vc,
                animated: true,
                completion: nil)
        vc.popoverPresentationController?.sourceView = self.view
    }
}

struct SwiftUIActivityViewController : UIViewControllerRepresentable {

    let activityViewController = ActivityViewController()

    func makeUIViewController(context: Context) -> ActivityViewController {
        activityViewController
    }
    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {
        //
    }
    func shareImage(uiImage: UIImage) {
        activityViewController.uiImage = uiImage
        activityViewController.shareImage()
    }
}
