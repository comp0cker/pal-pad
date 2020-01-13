//
//  Sets.swift
//  Pal Pad
//
//  Created by Jared Grimes on 12/26/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

let energyVersion = "sm1"
let energyPtcgoSetCode = "SMEnergy"

func setConvert(ptcgoCode: String) -> String {
    // if it's an energy, import it as SM energy
    if ptcgoCode == energyPtcgoSetCode {
        return energyPtcgoSetCode
    }
    
    let defaults = UserDefaults.standard
    let sets: [[String: Any]] = defaults.object(forKey: "sets") as! [[String: Any]]
    
    if ptcgoCode == "smp" {
        return "smp"
    }
    
    print(ptcgoCode)
    let code = ptcgoCode.uppercased()
    let target = sets.filter { set in
        let grabbedPtcgoCode = set["ptcgoCode"] as? String
        return code == grabbedPtcgoCode
    }
    
    // if it's an invalid set, return empty string
    if target.count == 0 {
        return ""
    }
    
    return (target[0]["code"] as? String)!
}

func setConvertToPtcgo(card: Card) -> String {
    if card.getSubtype() == "Basic" && card.getSupertype() == "Energy" {
        return energyPtcgoSetCode
    }
    
    return setConvertToPtcgo(regularCode: card.content["setCode"] as! String)
}

func setConvertToPtcgo(regularCode: String) -> String {
    let defaults = UserDefaults.standard
    let sets: [[String: Any]] = defaults.object(forKey: "sets") as! [[String: Any]]

    let code = regularCode.lowercased()
    let target = sets.filter { set in
        let grabbedCode = set["code"] as? String
        return code == grabbedCode
    }[0]
    return (target["ptcgoCode"] as! String).uppercased()
}

func energyNumberConvert(name: String, number: String) -> String {
    if name == "Grass Energy" {
        return "1"
    }
    if name == "Fire Energy" {
        return "2"
    }
    if name == "Water Energy" {
        return "3"
    }
    if name == "Lightning Energy" {
        return "4"
    }
    if name == "Psychic Energy" {
        return "5"
    }
    if name == "Fighting Energy" {
        return "6"
    }
    if name == "Darkness Energy" {
        return "7"
    }
    if name == "Metal Energy" {
        return "8"
    }
    if name == "Fairy Energy" {
        return "9"
    }
    
    return number
}
