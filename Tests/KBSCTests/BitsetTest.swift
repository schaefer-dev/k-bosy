//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 04.06.20.
//

import Foundation

import XCTest

import Foundation

@testable import Automata

class BitsetTest: XCTestCase {
    
    func testBitsetCreation() {
        let bs1 = Bitset()
        let bs2 = Bitset()
        
        bs1.addTrue()
        bs2.addTrue()
        bs1.addTrue()
        bs2.addFalse()
        bs1.addTrue()
        bs2.addWildcard ()
        
        XCTAssertEqual(bs1.description, "[1, 1, 1]")
        XCTAssertEqual(bs2.description, "[1, 0, *]")
    }
    
    
    func testBitsetANDempty() {
        let bs1 = Bitset()
        let bs2 = Bitset()
        
        bs1.addTrue()
        bs2.addTrue()
        bs1.addTrue()
        bs2.addFalse()
        bs1.addTrue()
        bs2.addWildcard ()
        
        let bs3 = bs1 && bs2
        
        XCTAssertEqual(bs3.isEmpty, true)
    }
    
    func testBitsetAND() {
        let bs1 = Bitset()
        let bs2 = Bitset()
        
        bs1.addTrue()
        bs2.addTrue()
        bs1.addFalse()
        bs2.addFalse()
        bs1.addTrue()
        bs2.addWildcard ()
        bs1.addWildcard()
        bs2.addFalse ()
        bs1.addWildcard()
        bs2.addWildcard()
        
        let bs3 = bs1 && bs2
        
        XCTAssertEqual(bs3.description, "[1, 0, 1, 0, *]")
    }
    
    
    func testLogicallyContains() {
        let bs1 = Bitset()
        let bs2 = Bitset()
        
        bs1.addTrue()
        bs2.addTrue()
        bs1.addFalse()
        bs2.addFalse()
        bs1.addWildcard()
        bs2.addWildcard ()
        bs1.addWildcard()
        bs2.addFalse ()
        bs1.addWildcard()
        bs2.addWildcard()
        
        XCTAssertEqual(bs1.logicallyContains(bs: bs2), true)
        XCTAssertEqual(bs2.logicallyContains(bs: bs1), false)
    }

}
