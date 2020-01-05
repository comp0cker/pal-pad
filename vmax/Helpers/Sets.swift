//
//  Sets.swift
//  Pal Pad
//
//  Created by Jared Grimes on 12/26/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

let energyVersion = "sm1"

func setConvert(ptcgoCode: String) -> String {
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
