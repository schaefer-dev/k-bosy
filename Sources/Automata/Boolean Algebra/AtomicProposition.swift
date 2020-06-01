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
            assert(false, "CRITICAL ERROR: tried to add already contained AP into APList")
            return
        }
        mapping[ap.id] = ap
    }
    
    public func lookupAP(apName: String) -> AP? {
        if let ap = mapping[apName] {
                return ap
            } else {
                return nil
            }
    }
    
    
    /**
     returns all APs that are part of this Automata structure sorted by AP name
     */
    public func get_allAPs() -> [AP] {
        var ap_list: [AP] = []
        
        for ap in self.mapping {
            ap_list.append(ap.value)
        }
        
        // sorting happens to guarantee deterministic behaviour of Assumptions-generation which improves ability to test in these cases
        let ap_list_sorted = ap_list.sorted { $0.id < $1.id }
        
        return ap_list_sorted
    }
    
    
    /**
     returns all obversable APs that are part of this Automata structure sorted by AP name
     */
    public func get_allObservableAPs() -> [AP] {
        var ap_list: [AP] = []
        
        for ap in self.mapping {
            if ap.value.obs {
                ap_list.append(ap.value)
            }
        }
        
        // sorting happens to guarantee deterministic behaviour of Assumptions-generation which improves ability to test in these cases
        let ap_list_sorted = ap_list.sorted { $0.id < $1.id }
        
        return ap_list_sorted
    }
    
    
    /**
     returns all obversable APs that are part of this Automata structure sorted by AP name
     */
    public func get_allOutputAPs() -> [AP] {
        var ap_list: [AP] = []
        
        for ap in self.mapping {
            if ap.value.output {
                ap_list.append(ap.value)
            }
        }
        
        // sorting happens to guarantee deterministic behaviour of Assumptions-generation which improves ability to test in these cases
        let ap_list_sorted = ap_list.sorted { $0.id < $1.id }
        
        return ap_list_sorted
    }
}

// make id and obs non-changable!
public class AP : Hashable, CustomStringConvertible {
    var id : String
    var obs : Bool
    var output : Bool
    
    public var description: String {
         return id
     }
    
    public init(name: String, observable: Bool, list: APList, output: Bool = false) {
        self.id = name
        self.obs = observable
        self.output = output
        
        // ERROR if already contained
        assert(list.lookupAP(apName: name) == nil, "ERROR: added AP " + name + " which was already contained in List.")
        
        list.addAP(ap: self)
    }
    
    public static func == (ap1: AP, ap2: AP) -> Bool {
        return ap1.id == ap2.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
