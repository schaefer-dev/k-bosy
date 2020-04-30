//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation


public struct Conjunction : Equatable {
    var literals : [Literal]
    
    public func eval(state: CurrentState) -> Bool {
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
            if (c1.literals[i].toString() != c2.literals[i].toString()) {
                return false
            }
        }
        
        return true
    }
    
    public init(literalsContainedInConjunction: [Literal]) {
        literals = literalsContainedInConjunction
    }
}


/* Formula represented as Distjunctive Normal Form (DNF) */
public struct Formula : Equatable {
    var dnf: [Conjunction]
    
    public func eval(state: CurrentState) -> Bool {
        for conj in dnf {
            // whenever one conjunction is true, then DNF-Formula must be true
            if (conj.eval(state: state)){
                return true
            }
        }
        return false
    }
    
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
