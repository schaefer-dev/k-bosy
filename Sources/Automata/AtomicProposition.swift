//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation


public class APList {
    private var mapping : [String : AP]
    
    
    public init() {
        mapping = [String : AP]()
    }
    
    public func addAP(ap: AP) {
        if (mapping[ap.id] != nil) {
            print("CRITICAL ERROR: tried to add already contained AP into APList")
            return
        }
        mapping[ap.id] = ap
    }
    
    public func lookupAP(apName: String) -> AP? {
        if let ap = mapping[apName] {
                return ap
            } else {
                print("CRITICAL ERROR: requested non-existant AP from APList")
                return nil
            }
    }
}

// make id and obs non-changable!
public class AP : Hashable {
    var id : String
    var obs : Bool
    
    public init(name: String, observable: Bool, list: APList) {
        id = name
        obs = observable
        list.addAP(ap: self)
    }
    
    public static func == (ap1: AP, ap2: AP) -> Bool {
        return ap1.id == ap2.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
