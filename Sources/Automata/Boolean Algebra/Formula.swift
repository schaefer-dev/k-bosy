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
    
    public func eval(state: CurrentState) -> Bool {
        // empty formula is true
        if (self.dnf.count == 0) {
            return true
        }
        
        
        for conj in dnf {
            // whenever one conjunction is true, then DNF-Formula must be true
            if (conj.eval(state: state)){
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
    
    public init(containedConjunctions: [Conjunction]) {
        dnf = containedConjunctions
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
    
    public func eval(state: CurrentState) -> Bool {
        if (self.literals.count == 0) {
            print("WARNING: empty Conjunction evaluated, this should never happen!")
            return true
        }
        
        for literal in literals {
            // whenever one literal not true, conjunction can no longer be true
            if !(literal.eval(state: state)){
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
    
    public init(literalsContainedInConjunction: [Literal]) {
        literals = literalsContainedInConjunction
    }
 
}
