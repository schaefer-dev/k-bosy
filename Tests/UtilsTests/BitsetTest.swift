//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 04.06.20.
//

import Foundation

import XCTest

import Foundation

@testable import Utils

class BitsetTest: XCTestCase {
    
    func testBitsetCreation() {
        var bs1 = Bitset()
        var bs2 = Bitset()
        
        bs1.addTrue()
        bs2.addTrue()
        bs1.addTrue()
        bs2.addFalse()
        bs1.addTrue()
        bs2.addWildcard ()
        
        var bs3 = bs2 && bs1
        
        XCTAssertEqual(bs3.description, "test")
    }

}
