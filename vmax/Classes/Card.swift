//
//  Card.swift
//  vmax
//
//  Created by Jared Grimes on 12/25/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

class Card: ObservableObject {
    @Published var content: [String: Any]
    @Published var image: UIImage!
    @Published var count: Int
    @Published var id: String
    
    @Published var standardLegal: Bool = true
    @Published var expandedLegal: Bool = true
    @Published var standardBanned: Bool = false
    @Published var expandedBanned: Bool = false
    @Published var futureFormat: Bool = false
    
    // for limitless future format import
    init(name: String, imageUrl: String, cardType: String, id: String, setCode: String, number: String) {
        func getSuperTypeFromCardType(cardType: String) -> String {
            if cardType.contains("Pokemon") {
                return "Pokémon"
            }
            if cardType.contains("Trainer") {
                return "Trainer"
            }
            if cardType.contains("Energy") {
                return "Energy"
            }
            return ""
        }
        
        func getSubTypeFromCardType(cardType: String) -> String {
            if cardType.contains("Basic") {
                return "Basic"
            }
            if cardType.contains("Stage 1") {
                return "Stage 1"
            }
            if cardType.contains("Stage 2") {
                return "Stage 2"
            }
            if cardType.contains("Supporter") {
                return "Supporter"
            }
            if cardType.contains("Item") {
                return "Item"
            }
            if cardType.contains("Tool") {
                return "Pokémon Tool"
            }
            if cardType.contains("Stadium") {
                return "Stadium"
            }
            if cardType.contains("Energy") && cardType.contains("Basic") {
                return "Basic"
            }
            if cardType.contains("Energy") && cardType.contains("Special") {
                return "Special"
            }
            return ""
        }
        
        self.futureFormat = true
        self.standardLegal = false
        self.expandedLegal = false
        
        var content: [String: Any] = [:]
        content["name"] = name
        content["imageUrl"] = imageUrl
        content["supertype"] = getSuperTypeFromCardType(cardType: cardType)
        content["subtype"] = getSubTypeFromCardType(cardType: cardType)
        content["id"] = id // just in case
        
        self.content = content
        self.id = id
        
        self.count = 1
    }
    
    init(content: [String: Any]) {
        self.content = content
        
        self.id = ""
        if let id = content["id"] as? String {
            self.id = id
        }
        
        self.count = 1
    }
    
    init(content: [String: Any], count: Int) {
        self.content = content
        
        self.id = ""
        if let id = content["id"] as? String {
            self.id = id
        }
        
        self.count = count
    }
    
    func legality() -> String {
        if futureFormat {
            return "Future"
        }
        if standardLegal {
            return "Standard"
        }
        if expandedLegal {
            return "Expanded"
        }
        return "Unlimited"
    }
    
    func getName() -> String {
        return content["name"] as! String
    }

    func getSupertype() -> String {
        return content["supertype"] as! String
    }
    
    func getSubtype() -> String {
        return content["subtype"] as! String
    }
    
    func ifBasicEnergy() -> Bool {
        return content["supertype"] as! String == "Energy" && content["subtype"] as! String == "Basic"
    }
    
    func getImageUrl() -> URL {
        if self.futureFormat {
            print(content["imageUrl"] as! String)
            return URL(string: content["imageUrl"] as! String)!
        }
        
        var url = imageUrlBase
        
        if let setCode = content["setCode"] as? String {
            url += setCode + "/"
        }
        if let number = content["number"] as? String {
            url += number + ".png"
        }
        
        url = handleImageUrlExceptions(contents: content)
        
        return URL(string: url)!
    }
    
    func getImageFromData(data: Data) -> UIImage {
        let uiImage = UIImage(data: data)!
        
        UIGraphicsBeginImageContext(CGSize(width: imageWidth, height: imageHeight))
        uiImage.draw(in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func incrCount(incr: Int) {
        count += incr
    }
}
