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
    
    
    /**
     Builds conjunction of 2 arrays of bitsets, representing 2 DNF Formula.
     TODO: test this function
     */
    public static func bitAND(bf1: BitsetFormula, bf2: BitsetFormula) -> BitsetFormula {
        var return_bitset_formula = BitsetFormula(ap_index_map: bf1.ap_index_map)
        
        for bs1 in bf1.conjunctions {
            for bs2 in bf2.conjunctions {
                let bs_new = bs1 && bs2
                if !bs_new.isEmpty {
                    return_bitset_formula.add_formula(bitset: bs_new)
                }
            }
        }
        
        return return_bitset_formula
    }
    
    
    /**
     Removes bitsets that are 'contained' in other bitsets that are also in this BitsetFormula. Idea is to make the formula easier to read
     */
    public func simplify_using_contains_check() {
        var bitset_index = 0
        
        while (bitset_index < self.conjunctions.count) {
            var j = 0
            while (j < self.conjunctions.count) {
                if (j == bitset_index) {
                    // skip comparison with same bitset
                    j += 1
                    continue
                }
                // formula at j is "stronger" than at `bitset_index` -> remove bitset index
                if self.conjunctions[j].logicallyContains(bs: self.conjunctions[bitset_index]) {
                    self.conjunctions.remove(at: bitset_index)
                    bitset_index -= 1
                    break
                }
                j += 1
            }
            bitset_index += 1
        }
    }
}


/**
 Binding to be able to use && operator on BitsetFormula
 */
public func && (bf1: BitsetFormula, bf2: BitsetFormula) -> BitsetFormula {
    return BitsetFormula.bitAND(bf1: bf1, bf2: bf2)
}
