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

func drawCardImage(deck: Deck, stacked: Bool, portraitMode: Bool, newTypeLines: Bool, testing: Bool, imageFactor: Int, additionalYPadding: Int) -> testingParams {
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
    
    
//    let fontSize: Int = 76
//
//    let attrs: [NSAttributedString.Key: Any] = [
//        .font: UIFont.boldSystemFont(ofSize: CGFloat(fontSize)),
//    ]
//
//    let string = deck.name
//    let attributedString = NSAttributedString(string: string, attributes: attrs)
//
//    if !testing {
//        attributedString.draw(with: CGRect(x: currentX, y: currentY, width: width, height: fontSize), options: .usesLineFragmentOrigin, context: nil)
//    }

//    currentY += fontSize + additionalYPadding + Ypadding
    
    let supertypes = ["Pokémon", "Trainer", "Energy"]
    for supertype in supertypes {
        let filteredCards = deck.cards.filter { $0.getSupertype() == supertype }
        
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
                }
                currentX += imageWidth
            }
        }
        if (newTypeLines) {
            currentX = Xpadding
            currentY += imageHeight + Ypadding
        }
    }
    
    if !newTypeLines {
        currentY += imageHeight + Ypadding
    }


    if currentY < height {
        return testingParams(imageFactor: imageFactor, additionalYpadding: (height - currentY) / 2)
    }
    return testingParams(imageFactor: -1, additionalYpadding: 0)
}

extension UIImage {

    static func imageByMergingImages(deck: Deck, stacked: Bool, portraitMode: Bool, newTypeLines: Bool) -> UIImage {
        let imageFactorRange = 5...20 // just in case...
        var imageFactor: Int = -1
        var additionalYPadding: Int = 0
        
        for fct in imageFactorRange {
            print("trying factor " + String(fct))
            let t: testingParams = drawCardImage(deck: deck, stacked: stacked, portraitMode: portraitMode, newTypeLines: newTypeLines, testing: true, imageFactor: fct, additionalYPadding: 0)
            
            imageFactor = t.imageFactor
            if imageFactor > 0 {
                additionalYPadding = t.additionalYpadding
                break
            }
        }
        drawCardImage(deck: deck, stacked: stacked, portraitMode: portraitMode, newTypeLines: newTypeLines, testing: false, imageFactor: imageFactor, additionalYPadding: additionalYPadding)
        
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
