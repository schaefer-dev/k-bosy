//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation

public class CurrentTruthValues {
    private var map : [AP : Bool]
    
    // TODO: require to add all possible APs into this state on construction, afterwards keys are not allowed to be added!
    public init() {
        map = [AP : Bool]()
    }
    
    public func update_value(ap: AP, value: Bool) {
        map[ap] = value
    }
    
    public func give_value(ap: AP) -> Bool {
        if let truthValue = map[ap] {
            return truthValue
        } else {
            print("CRITICAL ERROR: requested state value of AP that was not contained in state")
            return false
        }
    }
}
