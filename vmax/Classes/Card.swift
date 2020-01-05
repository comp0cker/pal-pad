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
    
    func getSupertype() -> String {
        return content["supertype"] as! String
    }
    
    func getSubtype() -> String {
        return content["subtype"] as! String
    }
    
    func ifBasicEnergy() -> Bool {
        return content["supertype"] as! String == "Energy" && content["subtype"] as! String == "Basic"
    }
    
    func getImageUrl(cardDict: [String: Any]) -> URL {
        var url = imageUrlBase
        
        if let setCode = cardDict["setCode"] as? String {
            url += setCode + "/"
        }
        if let number = cardDict["number"] as? String {
            url += number + ".png"
        }
        
        url = handleImageUrlExceptions(contents: cardDict)
        
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
