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
    
    var q = query.lowercased()
    
    q = q.replacingOccurrences(of: " ex", with: "-ex")
    q = q.replacingOccurrences(of: " gx", with: "-gx")
    q = q.replacingOccurrences(of: " prism star", with: " ◇")
    q = q.replacingOccurrences(of: " prism", with: " ◇")
    q = q.replacingOccurrences(of: " prism", with: " ◇")
    
    if q.suffix(2) == " v" {
        q = q.replacingOccurrences(of: " v", with: "-v")
    }
    
    if q.suffix(5) == " vmax" {
        q = q.replacingOccurrences(of: " vmax", with: "-vmax")
    }
    return q
}
