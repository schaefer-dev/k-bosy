//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 07.06.20.
//

import Foundation


// DNF Formula in BitsetRepresentation
public class BitsetDNFFormula : CustomStringConvertible{
    
    // Empty bitset corresponds to false
    
    private var conjunctions: [Bitset]
    private let ap_to_index_map: [String : Int]
    
    public var description: String {
        return conjunctions.description
    }
    
    public var isEmpty: Bool {
        if self.conjunctions.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    
    init(ap_index_map: [String: Int]) {
        self.conjunctions = []
        self.ap_to_index_map = ap_index_map
    }
    
    public func add_formula(bitset: Bitset) {
        self.conjunctions.append(bitset)
    }
    
    public func get_mapping() -> [String : Int] {
        return self.ap_to_index_map
    }
    
    
    /*
     Check if the given assumption_bs satisfies this DNF Formula
     */
    public func holdsUnderAssumption(assumption_bs: Bitset) -> Bool {
        for conj in self.conjunctions {
            if conj.holdsUnderAssumption(assumption_bs: assumption_bs) {
                return true
            }
        }
        
        return false
    }
    
    
    /**
     Inefficient because it has to turn dictionary around itself
     */
    public func _debug_get_formula_string() -> String {
        // build array that contains all APs in the order of their indices in the bitmap
        var bitset_ap_mapping = [String](repeating: "", count: ap_to_index_map.count)
        
        for (ap_str, ap_bitmap_index) in ap_to_index_map {
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
     Efficient because dict given
     */
    public func get_formula_string(bitset_ap_mapping: [String]) -> String {
        // build array that contains all APs in the order of their indices in the bitmap
        
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
    public static func bitAND(bf1: BitsetDNFFormula, bf2: BitsetDNFFormula) -> BitsetDNFFormula {
        var return_bitset_formula = BitsetDNFFormula(ap_index_map: bf1.ap_to_index_map)
        
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
                if self.conjunctions[j].holdsUnderAssumption(assumption_bs: self.conjunctions[bitset_index]) {
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
public func && (bf1: BitsetDNFFormula, bf2: BitsetDNFFormula) -> BitsetDNFFormula {
    return BitsetDNFFormula.bitAND(bf1: bf1, bf2: bf2)
}
