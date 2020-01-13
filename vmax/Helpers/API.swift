//
//  API.swift
//  Pal Pad
//
//  Created by Jared Grimes on 12/27/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

let urlBase = "https://api.pokemontcg.io/v1/"
let imageUrlBase = "https://images.pokemontcg.io/"
let bannedCardsUrl = "https://www.pokemon.com/us/pokemon-tcg-banned-card-list/"

func fixUpQueryUrl(query: String) -> String {
    var q = query.replacingOccurrences(of: "’", with: "'")
    
    return q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
}

func fixUpNameQuery(query: String) -> String {
    if query.lowercased() == "n" {
        return "\"N\""
    }
    
    if query.lowercased().contains(" ex") {
        return query.lowercased().replacingOccurrences(of: " ex", with: "-ex")
    }
    if query.lowercased().contains(" gx") {
        return query.replacingOccurrences(of: " gx", with: "-gx")
    }
    
    if query.lowercased().contains(" prism star") {
        return query.lowercased().replacingOccurrences(of: " prism star", with: " ◇")
    }
    if query.lowercased().contains(" prism") {
        return query.lowercased().replacingOccurrences(of: " prism", with: " ◇")
    }
    
    return query
}
