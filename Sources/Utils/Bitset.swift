//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 04.06.20.
//

import Foundation


private enum TValue: Int {
    case top = 1
    case bottom = 0
    case wildcard = 3
}

extension TValue: CustomStringConvertible {
    var description: String {
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


public class Bitset: CustomStringConvertible {
    // TODO: maybe save order of AP-constraints somewhere (array of string with same length? could be global and static because never changes)
    
    
    private var data: [TValue]
    
    public var count: Int {
        return self.data.count
    }
    
    public var description: String {
        return self.data.description
    }
    
    public var isEmpty: Bool {
        return self.data.isEmpty
    }
    
    
    init() {
        self.data = []
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
    public func logicallyContains(bs: Bitset) -> Bool {
        var i = 0
        while (i < self.count) {
            switch self.data[i] {
            case .top:
                switch bs.data[i] {
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
                switch bs.data[i] {
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
        assert(bs1.count == bs2.count)
        
        let bsr = Bitset()
        var i = 0
        while (i < bs1.count) {
            switch bs1.data[i] {
            case .top:
                // bs1 is true
                switch bs2.data[i] {
                case .top:
                    bsr.addTrue()
                case .bottom:
                    // true && false
                    return Bitset()
                case .wildcard:
                    bsr.addTrue()
                }
                
            case .bottom:
                // bs1 is false
                switch bs2.data[i] {
                case .top:
                    // false && true
                    return Bitset()
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
