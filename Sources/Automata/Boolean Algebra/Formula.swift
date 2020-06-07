//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation



/* Formula represented as Distjunctive Normal Form (DNF) */
public struct Formula : Equatable, CustomStringConvertible {
    var dnf: [Conjunction]
    var bitset_representation: BitsetFormula?
    
    public var description: String {
         if dnf.count == 0 {
             return ""
         }
         
         var output_string = ""
         
         var conj_index = 0
         while (true) {
             output_string += self.dnf[conj_index].description
             conj_index += 1
             if (conj_index > (self.dnf.count - 1)) {
                 break
             }
             output_string += " ∨ "
         }
         
         return output_string
     }
    
    
    public init(containedConjunctions: [Conjunction]) {
        self.dnf = containedConjunctions
        self.bitset_representation = nil
     }
    
    
    /**
    simplify this formula, all non-output APs that are true are contained in 'true_aps'. Every other non-output AP can be assumed to evaluate to false.
    */
    public mutating func simplifyWithConstants(true_aps: [AP]) {
        var conj_index = 0
        
        while conj_index < dnf.count {
            self.dnf[conj_index].simplifyWithConstants(true_aps: true_aps)
            conj_index += 1
        }
    }
    
    public mutating func simplifyTautologies() {
        var conj_index = 0
        
        // simplify the conjunctions
        while conj_index < dnf.count {
            self.dnf[conj_index].simplifyTautologies()
            conj_index += 1
        }
        
        _simplifyTautologiesFurther()
    }
    
    
    public mutating func _simplifyTautologiesFurther() {
        var conj_index = 0
        // simplify the conjunctions
        while conj_index < dnf.count {
            // if just one element in that conjunction look at it closer if we can maybe remove it
            if self.dnf[conj_index].literals.count == 1 {
                if (self.dnf[conj_index].literals[0].alwaysTrue) {
                    // one single True in the Disjunction results in just true being returned
                    self.dnf = [Conjunction(literalsContainedInConjunction: [Constant(negated: false, truthValue: true)])]
                    break
                } else if (self.dnf[conj_index].literals[0].alwaysFalse) {
                    // every occurance of False in the Disjunction is just skipped
                    self.dnf.remove(at: conj_index)
                    continue
                }
            }
            conj_index += 1
        }
        
        if self.dnf.count == 0 {
            self.dnf = [Conjunction(literalsContainedInConjunction: [Constant(negated: false, truthValue: false)])]
        }
    }
    
    public func eval(truthValues: CurrentTruthValues) -> Bool {
        // empty formula is true
        if (self.dnf.count == 0) {
            return true
        }
        for conj in dnf {
            // whenever one conjunction is true, then DNF-Formula must be true
            if (conj.eval(truthValues: truthValues)){
                return true
            }
        }
        return false
    }
    
    
    // Equality definition on formulas, if all subformulas are equal
    public static func == (f1: Formula, f2: Formula) -> Bool {
        // if not same length of dnf can not be equal
        if f1.dnf.count != f2.dnf.count {
            return false
        }
        for i in 0...(f1.dnf.count - 1) {
            // if any pair in dnf not equal return false
            if (f1.dnf[i] != f2.dnf[i]) {
                return false
            }
        }
        
        return true
    }
}


public struct Conjunction : Equatable, CustomStringConvertible {
    var literals : [Literal]
    
    public var description: String {
         if literals.count == 0 {
             return ""
         }
         var output_string = "("
         var lit_index = 0
         while (true) {
             output_string += self.literals[lit_index].description
             lit_index += 1
             if (lit_index > (self.literals.count - 1)) {
                 break
             }
             output_string += " ∧ "
         }
         output_string += ")"
         
         return output_string
     }
    
    public init(literalsContainedInConjunction: [Literal]) {
        literals = literalsContainedInConjunction
    }
    
    /**
    simplify this conjunction, all non-output APs that are true are contained in 'true_aps'. Every other non-output AP can be assumed to evaluate to false.
    */
    public mutating func simplifyWithConstants(true_aps: [AP]) {
        var lit_index = 0
        while lit_index < self.literals.count {
            let current_lit = self.literals[lit_index]
            
            // do not touch output APs or constants at all
            if current_lit.isOutput() || current_lit.isConstant {
                lit_index += 1
                continue
            }
            
            let var_ap = current_lit.getAP()!
            
            if true_aps.contains(var_ap) {
                // if AP is part of true apps replace with true and keep negation if it was previously negated
                self.literals[lit_index] = Constant(negated: current_lit.neg, truthValue: true)
                
            } else {
                // if AP is not part of true apps replace with false and keep negation if it was previously negated
                self.literals[lit_index] = Constant(negated: current_lit.neg, truthValue: false)
            }
            
            lit_index += 1
        }
    }
    
    public mutating func simplifyTautologies() {
        var lit_index = 0
        
        while lit_index < self.literals.count {
            // if false is contained somewhere the entire thing will always be false
            if self.literals[lit_index].alwaysFalse {
                self.literals = [Constant(negated: false, truthValue: false)]
                break
            } else if self.literals[lit_index].alwaysTrue {
                // if true value is contained somewhere remove it and continue with rest of formula
                self.literals.remove(at: lit_index)
                continue
            }
            lit_index += 1
        }
        
        // if entire conjunction has been removed (everything has been true) replace it with constant true
        if self.literals.isEmpty {
            self.literals = [Constant(negated: false, truthValue: true)]
        }
    }
    
    
    public func eval(truthValues: CurrentTruthValues) -> Bool {
        if (self.literals.count == 0) {
            print("WARNING: empty Conjunction evaluated, this should never happen!")
            return true
        }
        for literal in literals {
            // whenever one literal not true, conjunction can no longer be true
            if !(literal.eval(truthValues: truthValues)){
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
            if (c1.literals[i].description != c2.literals[i].description) {
                return false
            }
        }
        
        return true
    }
 
}
