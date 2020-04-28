//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation


public struct Conjunction {
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
    
    public init(literalsContainedInConjunction: [Literal]) {
        literals = literalsContainedInConjunction
    }
}


/* Formula represented as Distjunctive Normal Form (DNF) */
public struct Formula {
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
    
    public init(containedConjunctions: [Conjunction]) {
        dnf = containedConjunctions
    }
}
