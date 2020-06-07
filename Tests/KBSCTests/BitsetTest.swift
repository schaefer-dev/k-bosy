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
        let bs1 = Bitset(size: 0)
        let bs2 = Bitset(size: 0)
        
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
        let bs1 = Bitset(size: 0)
        let bs2 = Bitset(size: 0)
        
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
        let bs1 = Bitset(size: 0)
        let bs2 = Bitset(size: 0)
        
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
        let bs1 = Bitset(size: 0)
        let bs2 = Bitset(size: 0)
        
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
    
    
    
    func testFormulaAsBitset() {
        let globalAPList = APList()
        
        // Create Sample APs
        let _ = AP(name: "a", observable: true, list: globalAPList, output: true)
        let _ = AP(name: "b", observable: true, list: globalAPList, output: true)
        let _ = AP(name: "c", observable: true, list: globalAPList, output: true)
        let _ = AP(name: "d", observable: true, list: globalAPList, output: true)
        let _ = AP(name: "o1", observable: true, list: globalAPList, output: true)
        let _ = AP(name: "o2", observable: true, list: globalAPList, output: true)
       
        
        var formula3_0 = FormulaParser.parseDNFFormula(input_str: "((a ∧ ¬c ∧ ¬false) ∨ (b ∧ b) ∨ (¬d))", apList: globalAPList)
        let true_aps : [AP] = []
        formula3_0!.simplifyWithConstants(true_aps: true_aps)
        XCTAssertEqual(formula3_0!.description, "(a ∧ ¬c ∧ ¬false) ∨ (b ∧ b) ∨ (¬d)")
        formula3_0!.simplifyTautologies()
        XCTAssertEqual(formula3_0!.description, "(a ∧ ¬c) ∨ (b ∧ b) ∨ (¬d)")
        formula3_0!.buildBitsetRepresentation()
        XCTAssertEqual(formula3_0!.bitset_representation.description, "[[1, *, 0, *, *, *], [*, 1, *, *, *, *], [*, *, *, 0, *, *]]")
        XCTAssertEqual(formula3_0!.bitset_representation.get_formula_string(), "(a ∧ ¬c) ∨ (b) ∨ (¬d)")
        
        var formula4_0 = FormulaParser.parseDNFFormula(input_str: "((o2 ∧ ¬o1 ∧ ¬false) ∨ (d ∧ b) ∨ (¬a))", apList: globalAPList)
        formula4_0!.simplifyWithConstants(true_aps: true_aps)
        XCTAssertEqual(formula4_0!.description, "(o2 ∧ ¬o1 ∧ ¬false) ∨ (d ∧ b) ∨ (¬a)")
        formula4_0!.simplifyTautologies()
        XCTAssertEqual(formula4_0!.description, "(o2 ∧ ¬o1) ∨ (d ∧ b) ∨ (¬a)")
        formula4_0!.buildBitsetRepresentation()
        XCTAssertEqual(formula4_0!.bitset_representation.description, "[[*, *, *, *, 0, 1], [*, 1, *, 1, *, *], [0, *, *, *, *, *]]")
        XCTAssertEqual(formula4_0!.bitset_representation.get_formula_string(), "(¬o1 ∧ o2) ∨ (b ∧ d) ∨ (¬a)")
        
        
        
        var formula5_0 = FormulaParser.parseDNFFormula(input_str: "((o2 ∧ ¬o1 ∧ false) ∨ (true ∧ b) ∨ (¬true))", apList: globalAPList)
        formula5_0!.simplifyTautologies()
        XCTAssertEqual(formula5_0!.description, "(b)")
        formula5_0!.buildBitsetRepresentation()
        XCTAssertEqual(formula5_0!.bitset_representation.description, "[[*, 1, *, *, *, *]]")
        XCTAssertEqual(formula5_0!.bitset_representation.get_formula_string(), "(b)")
        
        
        var formula6_0 = FormulaParser.parseDNFFormula(input_str: "(false) ∨ (false)", apList: globalAPList)
        formula6_0!.simplifyTautologies()
        XCTAssertEqual(formula6_0!.description, "(false)")
        formula6_0!.buildBitsetRepresentation()
        XCTAssertEqual(formula6_0!.bitset_representation.description, "[[]]")
        XCTAssertEqual(formula6_0!.bitset_representation.get_formula_string(), "false")
        
        var formula7_0 = FormulaParser.parseDNFFormula(input_str: "(true) ∨ (false)", apList: globalAPList)
        formula7_0!.simplifyTautologies()
        XCTAssertEqual(formula7_0!.description, "(true)")
        formula7_0!.buildBitsetRepresentation()
        XCTAssertEqual(formula7_0!.bitset_representation.description, "[[*, *, *, *, *, *]]")
        XCTAssertEqual(formula7_0!.bitset_representation.get_formula_string(), "true")
        

    }

}
