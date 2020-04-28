//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation


// make id and obs non-changable!
public class AP : Hashable {
    var id : String
    var obs : Bool
    
    public init(name: String, observable: Bool) {
        id = name
        obs = observable
    }
    
    public static func == (ap1: AP, ap2: AP) -> Bool {
        return ap1.id == ap2.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
