//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 07.06.20.
//

import Foundation


public class BitsetFormula : CustomStringConvertible{
    
    private var formula: [Bitset]
    private let ap_index_map: [String : Int]
    
    public var description: String {
        return formula.description
    }
    
    
    init(ap_index_map: [String: Int]) {
        self.formula = []
        self.ap_index_map = ap_index_map
    }
    
    public func add_formula(bitset: Bitset) {
        self.formula.append(bitset)
    }
    
    public func get_mapping() -> [String : Int] {
        return self.ap_index_map
    }
}
