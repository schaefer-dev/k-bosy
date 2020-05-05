//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation

public protocol Literal: CustomStringConvertible {
    var neg : Bool { get }
    
    var description: String {get}
    
    // TODO: make sure references to state are always passed so we don't copy the state over and over while calling this method repeatedly
    func eval(state: CurrentState) -> Bool
}

public struct Variable : Literal, CustomStringConvertible {
    public var neg: Bool
    
    private var ap: AP
    
    public var description: String {
        if (neg) {
            return ("¬" + ap.id)
        } else {
            return (ap.id)
        }
    }
    
    
    public init(negated: Bool, atomicProposition: AP) {
        ap = atomicProposition
        neg = negated
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

public struct Constant : Literal, CustomStringConvertible {
    public var neg: Bool
    
    public var value: Bool
    
    public var description: String {
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
    
    public init(negated: Bool, truthValue: Bool) {
        value = truthValue
        neg = negated
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
