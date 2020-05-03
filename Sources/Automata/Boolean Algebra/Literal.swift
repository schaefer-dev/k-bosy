//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation

public protocol Literal {
    var neg : Bool { get }
    
    func toString() -> String
    
    // TODO: make sure references to state are always passed so we don't copy the state over and over while calling this method repeatedly
    func eval(state: CurrentState) -> Bool
}

public struct Variable : Literal {
    public var neg: Bool
    
    private var ap: AP
    
    
    public init(negated: Bool, atomicProposition: AP) {
        ap = atomicProposition
        neg = negated
    }
    
    public func toString() -> String {
        if (neg) {
            return ("¬" + ap.id)
        } else {
            return (ap.id)
        }
    }
    
    
    public func eval(state: CurrentState) -> Bool {
        let truthValue = state.give_value(ap: ap)
        
        if (neg) {
            return !truthValue
        } else {
            return truthValue
        }
    }
    
}

public struct Constant : Literal {
    public var neg: Bool
    
    public var value: Bool
    
    public init(negated: Bool, truthValue: Bool) {
        value = truthValue
        neg = negated
    }
    
    public func toString() -> String {
        if (neg) {
            if (value) {
                return ("¬true")
            } else {
                return ("¬false" )
            }
        } else {
            if (value) {
                return ("true")
            } else {
                return ("false" )
            }
        }
    }
    
    public func eval(state: CurrentState) -> Bool {
        if (neg) {
            if (value) {
                return false
            } else {
                return true
            }
        } else {
            if (value) {
                return true
            } else {
                return false
            }
        }
    }
}


public func parseLiteral(str_literal: String, apList: APList) -> Literal? {
    var negated = false
    // check if negated
    var literal_str = str_literal
    
    if (literal_str.count == 0) {
        print("Tried to parse empty literal")
        return nil
    }
    
    if (literal_str.character(at: 0) == "!") || (literal_str.character(at: 0) == "¬") {
        negated = true
        // remove negation character, such that only AP remains
        literal_str.remove(at: str_literal.startIndex)
    }
    
    if (literal_str.count == 0) {
        print("Tried to parse empty literal with only negation")
        return nil
    }
    
    
    // parse string of Literal, which can be either AP (Variable) or Constant
    if literal_str == "true" {
        let constant = Constant(negated: negated, truthValue: true)
        return constant
        
    } else if literal_str == "false" {
        let constant = Constant(negated: negated, truthValue: false)
        return constant
        
    } else {
        let apOpt = apList.lookupAP(apName: literal_str)
        
        if (apOpt == nil) {
            return nil
        }
        
        let literal = Variable(negated: negated, atomicProposition: apOpt!)
        return literal
    }
}


// String Extension to get a character at a specific position given as int
extension String {
 
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
 
    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
}
