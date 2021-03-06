//
//  File.swift
//
//
//  Created by Daniel Schäfer on 04.06.20.
//

import Foundation

public enum TValue: Int {
    case top = 1
    case bottom = 0
    case wildcard = 3
}

extension TValue: CustomStringConvertible {
    public var description: String {
        if rawValue == 1 {
            return "1"
        } else if rawValue == 0 {
            return "0"
        } else if rawValue == 3 {
            return "*"
        }
        return "INVALID TValue"
    }
}

/**
 An empty Bitset.data means that the condition is ALWAYS FALSE.
 */
public class Bitset: CustomStringConvertible {

    // Empty bitset corresponds to false
    public var data: [TValue]

    public var count: Int {
        return self.data.count
    }

    public var description: String {
        return self.data.description
    }

    public var isEmpty: Bool {
        return self.data.isEmpty
    }

    /**
     Constructs a human-readable form of this formula using the names given in the array bitset_ap_mapping
     */
    public func get_conjunction_string(bitsetAPMapping: [String]) -> String {
        if self.data == [] {
            return "(false)"
        }
        if !(self.data.contains(TValue.top) || self.data.contains(TValue.bottom)) {
            return "(true)"
        }
        var returnStringArray: [String] = []

        var bitsetIndex = 0

        while bitsetIndex < self.data.count {
            switch self.data[bitsetIndex] {
            case .top:
                returnStringArray.append(bitsetAPMapping[bitsetIndex])

            case .bottom:
                returnStringArray.append("¬" + bitsetAPMapping[bitsetIndex])

            case .wildcard:
                ()
            }
            bitsetIndex += 1
        }

        let returnString = "(" + returnStringArray.joined(separator: " ∧ ") + ")"

        return returnString
    }

    /**
     Increases a bitset by one. Does not support Bitsets that contain wildcards!
     
     Returns true if successful, false if already 'maximum' reached
     */
    public func increment() -> Bool {
        var negativeIndex = 0

        var foundFirstBottom = false

        // find the first .bottom to flip to a top
        while !foundFirstBottom && negativeIndex < self.data.count {
            let currentIterTValue = self.data[self.data.count - 1 - negativeIndex]
            switch currentIterTValue {
            case .bottom:
                self.data[self.data.count - 1 - negativeIndex] = .top
                foundFirstBottom = true
            case .top:
                // look further forwards to increment
                negativeIndex += 1
            case .wildcard:
                assert(false, "wildcard found in bitset that is being incremented, this is not allowed!")
            }
        }

        // no TValue could be flipped -> has to be maximum Bitset value already
        if !foundFirstBottom {
            return false
        }

        // every value at a index greater than the one we flipped from .bottom to .top has to be overwritten to .bottom
        var iter = 0
        let startingIndex = self.data.count - negativeIndex
        while startingIndex + iter < self.data.count {
            self.data[startingIndex + iter] = .bottom
            iter += 1
        }

        return true
    }

    /**
     Builds Formula representation with size amount of wildcards.
     */
    init(size: Int) {
        self.data = []

        var iter = 0
        while iter < size {
            self.data.append(.wildcard)
            iter += 1
        }
    }

    /**
     Builds Formula representation with size amount of truth-values
     */
    init(size: Int, truth_value: Bool) {
        self.data = []

        var iter = 0
        while iter < size {
            if truth_value == true {
                self.data.append(.top)
            } else {
                self.data.append(.bottom)
            }
            iter += 1
        }
    }

    public func addTrue() {
        self.data.append(.top)
    }

    public func addFalse() {
        self.data.append(.bottom)
    }

    public func addWildcard() {
        self.data.append(.wildcard)
    }

    /*
     Returns true if the passed bitset is stritly more limiting than self. This means that self covers all the truth values that would satisfy the passed bitset (and possibly more)
     */
    public func holdsUnderAssumption(assumptionBS: Bitset) -> Bool {
        assert(self.count == assumptionBS.count)
        var i = 0
        while i < self.count {
            switch self.data[i] {
            case .top:
                switch assumptionBS.data[i] {
                case .top:
                    // bs covers same truth values
                     ()
                case .bottom:
                    // bs covers different truth values
                    return false
                case .wildcard:
                    // bs covers more truth values
                    return false
                }

            case .bottom:
                switch assumptionBS.data[i] {
                case .bottom:
                    // bs covers same truth values
                    ()
                case .top:
                    // bs covers different truth values
                    return false
                case .wildcard:
                    // bs covers more truth values
                    return false
                }

            case .wildcard:
                ()
            }

            i += 1
        }

        return true
    }

    /*
     empties all the contained data
     */
    private func clear() {
        self.data.removeAll()
    }

    /*
    Operator definition for logic AND on Bitsets
     
     returns empty bitset if no solution
    */
    public static func bitAND(bs1: Bitset, bs2: Bitset) -> Bitset {
        if bs1.count == 0 || bs2.count == 0 {
            return Bitset(size: 0)
        }
        assert(bs1.count == bs2.count)

        let bsr = Bitset(size: 0)
        var i = 0
        while i < bs1.count {
            switch bs1.data[i] {
            case .top:
                // bs1 is true
                switch bs2.data[i] {
                case .top:
                    bsr.addTrue()
                case .bottom:
                    // true && false
                    return Bitset(size: 0)
                case .wildcard:
                    bsr.addTrue()
                }

            case .bottom:
                // bs1 is false
                switch bs2.data[i] {
                case .top:
                    // false && true
                    return Bitset(size: 0)
                case .bottom:
                    bsr.addFalse()
                case .wildcard:
                    bsr.addFalse()
                }

            case .wildcard:
                // bs1 is wildcard
                switch bs2.data[i] {
                case .top:
                    bsr.addTrue()
                case .bottom:
                    bsr.addFalse()
                case .wildcard:
                    bsr.addWildcard()
                }
            }

            i += 1
        }
        return bsr
    }
    
    
    /**
     merges to bitsets if one implies the other initially or otherwise only if ONE difference is found
     */
    public static func bitOR(bs1: Bitset, bs2: Bitset) -> [Bitset] {
        let bsr = Bitset(size: 0)
        var bitMerged = false
        
        if bs1.count == 0 || bs2.count == 0 {
            return [Bitset(size: 0)]
        }
        assert(bs1.count == bs2.count)

        /* If one is strictly weaker condition, return it */
        if bs1.holdsUnderAssumption(assumptionBS: bs2) {
            return [bs1]
        } else if bs2.holdsUnderAssumption(assumptionBS: bs1){
            return [bs2]
        }
        
        var i = 0
        while i < bs1.count {
            switch bs1.data[i] {
            case .top:
                // bs1 is true
                switch bs2.data[i] {
                case .top:
                    bsr.addTrue()
                case .bottom:
                    // true && false
                    if bitMerged {
                        return [bs1, bs2]
                    } else {
                        bitMerged = true
                        bsr.addWildcard()
                    }
                case .wildcard:
                    if bitMerged {
                        return [bs1, bs2]
                    } else {
                        bitMerged = true
                        bsr.addWildcard()
                    }
                }

            case .bottom:
                // bs1 is false
                switch bs2.data[i] {
                case .top:
                    // false && true
                    if bitMerged {
                        return [bs1, bs2]
                    } else {
                        bitMerged = true
                        bsr.addWildcard()
                    }
                case .bottom:
                    bsr.addFalse()
                case .wildcard:
                    if bitMerged {
                        return [bs1, bs2]
                    } else {
                        bitMerged = true
                        bsr.addWildcard()
                    }
                }

            case .wildcard:
                // bs1 is wildcard
                switch bs2.data[i] {
                case .top:
                    if bitMerged {
                        return [bs1, bs2]
                    } else {
                        bitMerged = true
                        bsr.addWildcard()
                    }
                case .bottom:
                    if bitMerged {
                        return [bs1, bs2]
                    } else {
                        bitMerged = true
                        bsr.addWildcard()
                    }
                case .wildcard:
                    bsr.addWildcard()
                }
            }

            i += 1
        }
        return [bsr]
    }

    public func size() -> Int {
        return data.capacity
    }

}

/**
 Binding to be able to use && operator on bitset
 */
public func && (bs1: Bitset, bs2: Bitset) -> Bitset {
    return Bitset.bitAND(bs1: bs1, bs2: bs2)
}
