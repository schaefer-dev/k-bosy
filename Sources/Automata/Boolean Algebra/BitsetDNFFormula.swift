//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 07.06.20.
//

import Foundation

// DNF Formula in BitsetRepresentation
public class BitsetDNFFormula: CustomStringConvertible {

    // Empty bitset corresponds to false

    public var conjunctions: [Bitset]?
    private let apToIndexMap: [String: Int]

    public var description: String {
        if conjunctions == nil {
            assert(false, "bitset structure is not yet initialized")
        }
        return conjunctions!.description
    }

    public var isEmpty: Bool {
        if conjunctions == nil {
            assert(false, "bitset structure is not yet initialized")
        }
        if self.conjunctions!.count == 0 {
            return true
        } else {
            return false
        }
    }

    init(ap_index_map: [String: Int]) {
        self.conjunctions = nil
        self.apToIndexMap = ap_index_map
    }

    public func initialize() {
        if self.conjunctions != nil {
            assert(false, "initialize was already called")
        }
        self.conjunctions = []
    }
    
    
    public func add_formula(bitset: Bitset) {
        if self.conjunctions == nil {
            self.initialize()
        }
        self.conjunctions!.append(bitset)
    }

    public func get_mapping() -> [String: Int] {
        return self.apToIndexMap
    }

    /*
     Check if the given assumption_bs satisfies this DNF Formula
     */
    public func holdsUnderAssumption(assumptionBS: Bitset) -> Bool {
        if conjunctions == nil {
            assert(false, "bitset structure is not yet initialized")
        }
        for conj in self.conjunctions! {
            if conj.holdsUnderAssumption(assumptionBS: assumptionBS) {
                return true
            }
        }

        return false
    }

    /**
     Inefficient because it has to turn dictionary around itself
     */
    public func debug_get_formula_string() -> String {
        // build array that contains all APs in the order of their indices in the bitmap
        if conjunctions == nil {
            assert(false, "bitset structure is not yet initialized")
        }

        var bitsetAPMapping = [String](repeating: "", count: apToIndexMap.count)

        for (apString, apBitmapIndex) in apToIndexMap {
            bitsetAPMapping[apBitmapIndex] = apString
        }

        var conjunctionsIndex = 0
        var conjunctionStringArray: [String] = []
        while conjunctionsIndex < self.conjunctions!.count {
            conjunctionStringArray.append(self.conjunctions![conjunctionsIndex].get_conjunction_string(bitsetAPMapping: bitsetAPMapping))

            conjunctionsIndex += 1
        }

        let returnString = conjunctionStringArray.joined(separator: " ∨ ")

        return returnString
    }

    /**
     Efficient because dict given
     */
    public func get_formula_string(bitsetAPMapping: [String]) -> String {
        if conjunctions == nil {
            assert(false, "bitset structure is not yet initialized")
        }

        var conjunctionsIndex = 0
        var conjunctionStringArray: [String] = []
        while conjunctionsIndex < self.conjunctions!.count {
            conjunctionStringArray.append(self.conjunctions![conjunctionsIndex].get_conjunction_string(bitsetAPMapping: bitsetAPMapping))

            conjunctionsIndex += 1
        }

        let returnString = conjunctionStringArray.joined(separator: " ∨ ")

        return returnString
    }

    /**
     Builds conjunction of 2 arrays of bitsets, representing 2 DNF Formula.
     TODO: test this function
     */
    public static func bitAND(bf1: BitsetDNFFormula, bf2: BitsetDNFFormula) -> BitsetDNFFormula {
        var returnBitsetFormula = BitsetDNFFormula(ap_index_map: bf1.apToIndexMap)
        returnBitsetFormula.initialize()

        for bs1 in bf1.conjunctions! {
            for bs2 in bf2.conjunctions! {
                let bsNew = bs1 && bs2
                if !bsNew.isEmpty {
                    returnBitsetFormula.add_formula(bitset: bsNew)
                }
            }
        }

        return returnBitsetFormula
    }

    /**
     Removes bitsets that are 'contained' in other bitsets that are also in this BitsetFormula. Idea is to make the formula easier to read
     */
    public func simplify_using_contains_check() {
        var bitsetIndex = 0
        assert(self.conjunctions != nil, "bitset structure is not yet initialized")

        while bitsetIndex < self.conjunctions!.count {
            var j = 0
            while j < self.conjunctions!.count {
                if j == bitsetIndex {
                    // skip comparison with same bitset
                    j += 1
                    continue
                }
                // formula at j is "stronger" than at `bitset_index` -> remove bitset index
                if self.conjunctions![j].holdsUnderAssumption(assumptionBS: self.conjunctions![bitsetIndex]) {
                    self.conjunctions!.remove(at: bitsetIndex)
                    bitsetIndex -= 1
                    break
                }
                j += 1
            }
            bitsetIndex += 1
        }
    }
    
    /**
     Reduces size of this bitset by intelligently combining cases
     */
    public func reduce() {
        assert(self.conjunctions != nil, "Bitset must exist first, before being reduced")
        /* Can not reduce with size 0 or 1 */
        if self.conjunctions!.count < 2 {
            return
        }
        
        var newBitset = Bitset.bitOR(bs1: self.conjunctions![0], bs2: self.conjunctions![1])
        
        /* First merge into newBitset */
        var iter = 2
        while ( iter < self.conjunctions!.count ) {
            let newBitsetLast = newBitset.popLast()!
            newBitset += Bitset.bitOR(bs1: newBitsetLast, bs2: self.conjunctions![iter])
            iter += 1
        }
        
        // TODO: do the main work here with comparisons in newBitset to reduce its size
        var round = 0
        while round < newBitset.count {
            var iter2 = 0
            while(iter2 < newBitset.count - 1 ) {
                let newBitsetLast = newBitset.popLast()
                let compareBitset = newBitset.remove(at: iter2)
                newBitset += Bitset.bitOR(bs1: compareBitset, bs2:newBitsetLast!)
            }
            // shuffle bitsets around
            let newBitsetLast = newBitset.popLast()
            newBitset = [newBitsetLast!] + newBitset
            
            round += 1
        }
        
        self.conjunctions! = newBitset
    }
}

/**
 Binding to be able to use && operator on BitsetFormula
 */
public func && (bf1: BitsetDNFFormula, bf2: BitsetDNFFormula) -> BitsetDNFFormula {
    return BitsetDNFFormula.bitAND(bf1: bf1, bf2: bf2)
}
