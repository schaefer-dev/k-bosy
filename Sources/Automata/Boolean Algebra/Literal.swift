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
            return ("!" + ap.id)
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
                return ("!true")
            } else {
                return ("!false" )
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
