//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation

/* Formula represented as Distjunctive Normal Form (DNF) */
public struct Formula: Equatable, CustomStringConvertible {
    var dnf: [Conjunction]?
    var bitsetRepresentation: BitsetDNFFormula

    public var description: String {
        if self.dnf != nil {
            let dnf = self.dnf!
            if dnf.count == 0 {
                return ""
            }

            var outputString = ""

            var conjunctionIndex = 0
            while true {
                outputString += dnf[conjunctionIndex].description
                conjunctionIndex += 1
                if conjunctionIndex > (dnf.count - 1) {
                    break
                }
                outputString += " ∨ "
            }

            return outputString
        } else {
            return bitsetRepresentation.description
        }
     }

    public var isEmpty: Bool {
        return self.bitsetRepresentation.isEmpty
    }

    public init(containedConjunctions: [Conjunction], bitset_ap_mapping: [String: Int]) {
        self.dnf = containedConjunctions
        self.bitsetRepresentation = BitsetDNFFormula(ap_index_map: bitset_ap_mapping)
     }
    
    /**
     Only used during optimization
     */
    public init(bitsetRepresentation: BitsetDNFFormula) {
        self.bitsetRepresentation = bitsetRepresentation
        self.dnf = nil
    }

    public func getStringFromBitsetRepresentation(index_to_ap_map: [String]) -> String {
        return bitsetRepresentation.get_formula_string(bitsetAPMapping: index_to_ap_map)
    }

    /**
    simplify this formula, all non-output APs that are true are contained in 'true_aps'. Every other non-output AP can be assumed to evaluate to false.
    */
    public mutating func simplifyWithConstants(trueAPs: [AP]) {
        if self.dnf == nil {
            assert(false, "this method can not be called on optimized structures")
        }
        var conjunctionIndex = 0

        while conjunctionIndex < dnf!.count {
            self.dnf![conjunctionIndex].simplifyWithConstants(trueAPs: trueAPs)
            conjunctionIndex += 1
        }
    }

    public mutating func simplifyTautologies() {
        if self.dnf == nil {
            assert(false, "this method can not be called on optimized structures")
        }
        var conjunctionIndex = 0

        // simplify the conjunctions
        while conjunctionIndex < dnf!.count {
            self.dnf![conjunctionIndex].simplifyTautologies()
            conjunctionIndex += 1
        }

        simplifyTautologiesFurther()
    }

    public mutating func simplifyTautologiesFurther() {
        var conjunctionIndex = 0
        // simplify the conjunctions
        while conjunctionIndex < dnf!.count {
            // if just one element in that conjunction look at it closer if we can maybe remove it
            if self.dnf![conjunctionIndex].literals.count == 1 {
                if self.dnf![conjunctionIndex].literals[0].alwaysTrue {
                    // one single True in the Disjunction results in just true being returned
                    self.dnf! = [Conjunction(literalsContainedInConjunction: [Constant(negated: false, truthValue: true)])]
                    break
                } else if self.dnf![conjunctionIndex].literals[0].alwaysFalse {
                    // every occurance of False in the Disjunction is just skipped
                    self.dnf!.remove(at: conjunctionIndex)
                    continue
                }
            }
            conjunctionIndex += 1
        }

        if self.dnf!.count == 0 {
            self.dnf! = [Conjunction(literalsContainedInConjunction: [Constant(negated: false, truthValue: false)])]
        }
    }

    /**
     Builds the bitset representation of that particular formla
     Make sure this is only called once.
     */
    public mutating func buildBitsetRepresentation() {
        if self.dnf == nil {
            assert(false, "this method can not be called on optimized structures")
        }
        // cover special cases if only one literal part of entire formula
        if self.dnf!.count == 1 && self.dnf![0].literals.count == 1 {
            if self.dnf![0].literals[0].alwaysFalse {
                print("WARNING: Transition that is always false, this has to be filtered because no bitset exists here! Currently empty bitset means that never true")
            }
        }

        self.bitsetRepresentation.initialize()
        for conj in self.dnf! {
            let conj_bitset = conj.asBitset(ap_index_map: self.bitsetRepresentation.get_mapping())
            self.bitsetRepresentation.add_formula(bitset: conj_bitset)
        }

        // remove dnf mapping because we are now in 'bitset-mode'
        self.dnf = nil
    }

    public func eval(truthValues: CurrentTruthValues) -> Bool {
        if self.dnf == nil {
            // TODO
            assert(false, "TODO: implement this with bitset")
        }
        // empty formula is true
        if self.dnf!.count == 0 {
            return true
        }
        for conj in dnf! {
            // whenever one conjunction is true, then DNF-Formula must be true
            if conj.eval(truthValues: truthValues) {
                return true
            }
        }
        return false
    }

    // Equality definition on formulas, if all subformulas are equal
    public static func == (f1: Formula, f2: Formula) -> Bool {
        if f1.dnf == nil || f1.dnf == nil {
            return (f1.bitsetRepresentation.description == f2.bitsetRepresentation.description)
        }

        // if not same length of dnf can not be equal
        if f1.dnf!.count != f2.dnf!.count {
            return false
        }
        for iter in 0...(f1.dnf!.count - 1) {
            // if any pair in dnf not equal return false
            if f1.dnf![iter] != f2.dnf![iter] {
                return false
            }
        }

        return true
    }
}

public struct Conjunction: Equatable, CustomStringConvertible {
    var literals: [Literal]

    public var description: String {
         if literals.count == 0 {
             return ""
         }
         var outputString = "("
         var litIndex = 0
         while true {
             outputString += self.literals[litIndex].description
             litIndex += 1
             if litIndex > (self.literals.count - 1) {
                 break
             }
             outputString += " ∧ "
         }
         outputString += ")"

         return outputString
     }

    public init(literalsContainedInConjunction: [Literal]) {
        literals = literalsContainedInConjunction
    }

    /**
    simplify this conjunction, all non-output APs that are true are contained in 'true_aps'. Every other non-output AP can be assumed to evaluate to false.
    */
    public mutating func simplifyWithConstants(trueAPs: [AP]) {
        var litIndex = 0
        while litIndex < self.literals.count {
            let currentLit = self.literals[litIndex]

            // do not touch output APs or constants at all
            if currentLit.isOutput() || currentLit.isConstant {
                litIndex += 1
                continue
            }

            let varAP = currentLit.getAP()!

            if trueAPs.contains(varAP) {
                // if AP is part of true apps replace with true and keep negation if it was previously negated
                self.literals[litIndex] = Constant(negated: currentLit.neg, truthValue: true)

            } else {
                // if AP is not part of true apps replace with false and keep negation if it was previously negated
                self.literals[litIndex] = Constant(negated: currentLit.neg, truthValue: false)
            }

            litIndex += 1
        }
    }

    public mutating func simplifyTautologies() {
        var litIndex = 0

        while litIndex < self.literals.count {
            // if false is contained somewhere the entire thing will always be false
            if self.literals[litIndex].alwaysFalse {
                self.literals = [Constant(negated: false, truthValue: false)]
                break
            } else if self.literals[litIndex].alwaysTrue {
                // if true value is contained somewhere remove it and continue with rest of formula
                self.literals.remove(at: litIndex)
                continue
            }
            litIndex += 1
        }

        // if entire conjunction has been removed (everything has been true) replace it with constant true
        if self.literals.isEmpty {
            self.literals = [Constant(negated: false, truthValue: true)]
        }
    }

    /**
     Returns bitset representation of this conjunction.
     If formula coontains contradiction (=is always false) then the empty bitset is returned.
     */
    public func asBitset(ap_index_map: [String: Int]) -> Bitset {
        // build bitset with only wildcards
        let bitset = Bitset(size: ap_index_map.count)

        for lit in self.literals {
            if lit.alwaysFalse {
                // in always false case return empty bitset
                return Bitset(size: 0)
            }

            if lit.alwaysTrue {
                continue
            }

            // now cover cases in which APs occur and not constants
            let literalAPString = lit.getAP()!.name
            let bitsetAPIndex = ap_index_map[literalAPString]!

            if lit.neg {
                // case of ap occuring in negated form
                // make sure that positive form was not contained already, in that case return empty bitset because always false
                if bitset.data[bitsetAPIndex] == TValue.top {
                    return Bitset(size: 0)
                } else {
                    // bitset now indicates that value of that ap has to be true
                    bitset.data[bitsetAPIndex] = TValue.bottom
                }
            } else {
                // case of ap occuring in positive form
                // make sure that negative form was not contained already, in that case return empty bitset because always false
                if bitset.data[bitsetAPIndex] == TValue.bottom {
                    return Bitset(size: 0)
                } else {
                    // bitset now indicates that value of that ap has to be true
                    bitset.data[bitsetAPIndex] = TValue.top
                }
            }
        }

        return bitset
    }

    public func eval(truthValues: CurrentTruthValues) -> Bool {
        if self.literals.count == 0 {
            print("WARNING: empty Conjunction evaluated, this should never happen!")
            return true
        }
        for literal in literals {
            // whenever one literal not true, conjunction can no longer be true
            if !(literal.eval(truthValues: truthValues)) {
                return false
            }
        }
        return true
    }

    public static func == (c1: Conjunction, c2: Conjunction) -> Bool {
        // if not same length of dnf can not be equal
        if c1.literals.count != c2.literals.count {
            return false
        }
        for i in 0...(c1.literals.count - 1) {
            // if any pair in dnf not equal return false
            if c1.literals[i].description != c2.literals[i].description {
                return false
            }
        }

        return true
    }

}

/**
 Binding to be able to use && operator on BitsetFormula
 
 Does NOT create old conjunctions structure for the newly created Formula!!!
 */
public func && (f1: Formula, f2: Formula) -> Formula {
    var return_formula = Formula(containedConjunctions: [], bitset_ap_mapping: f1.bitsetRepresentation.get_mapping())

    return_formula.bitsetRepresentation.initialize()

    return_formula.bitsetRepresentation = f1.bitsetRepresentation && f2.bitsetRepresentation

    // simplify the returned formula by eliminating contained subformulae
    return_formula.bitsetRepresentation.simplify_using_contains_check()

    return return_formula
}
