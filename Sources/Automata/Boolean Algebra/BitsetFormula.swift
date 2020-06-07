//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 07.06.20.
//

import Foundation


public class BitsetFormula : CustomStringConvertible{
    
    private var conjunctions: [Bitset]
    private let ap_index_map: [String : Int]
    
    public var description: String {
        return conjunctions.description
    }
    
    
    init(ap_index_map: [String: Int]) {
        self.conjunctions = []
        self.ap_index_map = ap_index_map
    }
    
    public func add_formula(bitset: Bitset) {
        self.conjunctions.append(bitset)
    }
    
    public func get_mapping() -> [String : Int] {
        return self.ap_index_map
    }
    
    
    /**
     Inefficient because it has to turn dictionary around
     */
    public func get_formula_string() -> String {
        // build array that contains all APs in the order of their indices in the bitmap
        var bitset_ap_mapping = [String](repeating: "", count: ap_index_map.count)
        
        for (ap_str, ap_bitmap_index) in ap_index_map {
            bitset_ap_mapping[ap_bitmap_index] = ap_str
        }
        
        var conjunctions_index = 0
        var conjunction_string_array : [String] = []
        while conjunctions_index < self.conjunctions.count {
            conjunction_string_array.append(self.conjunctions[conjunctions_index].get_conjunction_string(bitset_ap_mapping: bitset_ap_mapping))
            
            conjunctions_index += 1
        }
        
        let returnString = conjunction_string_array.joined(separator: " ∨ ")
        
        return returnString
    }
}
