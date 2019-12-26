//
//  Images.swift
//  Pal Pad
//
//  Created by Jared Grimes on 12/26/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

func handleImageUrlExceptions(contents: [String: Any]) -> String {
    if contents["number"] as? String == "SM197" {
        return "https://assets.pokemon.com/assets/cms2/img/cards/web/DET/DET_EN_SM197.png"
    }
    return (contents["imageUrl"] as? String)!
}
