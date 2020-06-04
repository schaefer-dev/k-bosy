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
    
    public var capacity: Int {
        return data.capacity
    }
    
    public var description: String {
        return self.data.description
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
    
    
    public static func bitOR(bs1: Bitset, bs2: Bitset) -> Bitset {
        // TODO
        
        return bs1
    }
    
    public static func bitAND(bs1: Bitset, bs2: Bitset) -> Bitset {
        // TODO
        
        return bs1
    }
    
    public func size() -> Int {
        return data.capacity
    }


}


/**
 Binding to be able to use && operator on bitset
 */
public func || (bs1: Bitset, bs2: Bitset) -> Bitset {
    return Bitset.bitOR(bs1: bs1, bs2: bs2)
}

/**
 Binding to be able to use && operator on bitset
 */
public func && (bs1: Bitset, bs2: Bitset) -> Bitset {
    return Bitset.bitAND(bs1: bs1, bs2: bs2)
}
