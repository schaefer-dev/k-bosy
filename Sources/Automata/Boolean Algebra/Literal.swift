//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation

public protocol Literal: CustomStringConvertible {
    var neg: Bool { get }

    var description: String {get}

    var isConstant: Bool {get}

    var alwaysTrue: Bool {get}
    var alwaysFalse: Bool {get}

    // TODO: make sure references to state are always passed so we don't copy the state over and over while calling this method repeatedly
    func eval(truthValues: CurrentTruthValues) -> Bool

    func isObservable() -> Bool
    func isOutput() -> Bool

    /**
     returns nil in case of constant
     */
    func getAP() -> AP?
}

public struct Variable: Literal, CustomStringConvertible {
    public var neg: Bool

    private var ap: AP

    public var description: String {
        if neg {
            return ("¬" + ap.name)
        } else {
            return (ap.name)
        }
    }

    public var alwaysTrue: Bool {
        return false
    }

    public var alwaysFalse: Bool {
        return false
    }

    public var isConstant: Bool {
        return false
    }

    public init(negated: Bool, atomicProposition: AP) {
        ap = atomicProposition
        neg = negated
    }

    public func isObservable() -> Bool {
        if ap.obs {
            return true
        }
        return false
    }

    public func isOutput() -> Bool {
        if ap.output {
            return true
        }
        return false
    }

    public func eval(truthValues: CurrentTruthValues) -> Bool {
        let truthValue = truthValues.give_value(ap: ap)

        if neg {
            return !truthValue
        } else {
            return truthValue
        }
    }

    public func getAP() -> AP? {
        return self.ap
    }

}

public struct Constant: Literal, CustomStringConvertible {
    public var neg: Bool

    public var value: Bool

    public var isConstant: Bool {
        return true
    }

    public var description: String {
        if neg {
            if value {
                return ("¬true")
            } else {
                return ("¬false" )
            }
        } else {
            if value {
                return ("true")
            } else {
                return ("false" )
            }
        }
    }

    public var alwaysTrue: Bool {
        if self.neg {
            if self.value {
                return false
            } else {
                return true
            }
        } else {
            if self.value {
                return true
            } else {
                return false
            }
        }
    }

    public var alwaysFalse: Bool {
        if self.neg {
            if self.value {
                return true
            } else {
                return false
            }
        } else {
            if self.value {
                return false
            } else {
                return true
            }
        }
    }

    public func isObservable() -> Bool {
        return true
    }

    public func isOutput() -> Bool {
        return false
    }

    public init(negated: Bool, truthValue: Bool) {
        value = truthValue
        neg = negated
    }

    public func getAP() -> AP? {
        return nil
    }

    public func eval(truthValues: CurrentTruthValues) -> Bool {
        if neg {
            if value {
                return false
            } else {
                return true
            }
        } else {
            if value {
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
