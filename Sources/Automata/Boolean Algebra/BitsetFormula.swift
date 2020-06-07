//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 07.06.20.
//

import Foundation


public class BitsetFormula {
    
    private var formula: [Bitset]
    private let ap_index_map: [String : Int]
    
    
    
    init(ap_index_map: [String: Int]) {
        self.formula = []
        self.ap_index_map = ap_index_map
    }
    
    public func add_formula(bitset: Bitset) {
        self.formula.append(bitset)
    }
}
