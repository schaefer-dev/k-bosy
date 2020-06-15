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
        bs2.addWildcard()

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
        bs2.addWildcard()

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
        bs2.addWildcard()
        bs1.addWildcard()
        bs2.addFalse()
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
        bs2.addWildcard()
        bs1.addWildcard()
        bs2.addFalse()
        bs1.addWildcard()
        bs2.addWildcard()

        // bs1: [1, 0, *, *, *]
        // bs2: [1, 0, *, 0, *]
        XCTAssertEqual(bs1.holdsUnderAssumption(assumptionBS: bs2), true)
        XCTAssertEqual(bs2.holdsUnderAssumption(assumptionBS: bs1), false)
    }

    func testFormulaAsBitset() {
        let globalAPList = APList()

        // Create Sample APs
        _ = AP(name: "a", observable: true, list: globalAPList, output: true)
        _ = AP(name: "b", observable: true, list: globalAPList, output: true)
        _ = AP(name: "c", observable: true, list: globalAPList, output: true)
        _ = AP(name: "d", observable: true, list: globalAPList, output: true)
        _ = AP(name: "o1", observable: true, list: globalAPList, output: true)
        _ = AP(name: "o2", observable: true, list: globalAPList, output: true)

        var formula3_0 = FormulaParser.parseDNFFormula(inputString: "((a ∧ ¬c ∧ ¬false) ∨ (b ∧ b) ∨ (¬d))", apList: globalAPList)
        let true_aps: [AP] = []
        formula3_0!.simplifyWithConstants(trueAPs: true_aps)
        XCTAssertEqual(formula3_0!.description, "(a ∧ ¬c ∧ ¬false) ∨ (b ∧ b) ∨ (¬d)")
        formula3_0!.simplifyTautologies()
        XCTAssertEqual(formula3_0!.description, "(a ∧ ¬c) ∨ (b ∧ b) ∨ (¬d)")
        formula3_0!.buildBitsetRepresentation()
        XCTAssertEqual(formula3_0!.bitsetRepresentation.description, "[[1, *, 0, *, *, *], [*, 1, *, *, *, *], [*, *, *, 0, *, *]]")
        XCTAssertEqual(formula3_0!.bitsetRepresentation.debug_get_formula_string(), "(a ∧ ¬c) ∨ (b) ∨ (¬d)")

        var formula4_0 = FormulaParser.parseDNFFormula(inputString: "((o2 ∧ ¬o1 ∧ ¬false) ∨ (d ∧ b) ∨ (¬a))", apList: globalAPList)
        formula4_0!.simplifyWithConstants(trueAPs: true_aps)
        XCTAssertEqual(formula4_0!.description, "(o2 ∧ ¬o1 ∧ ¬false) ∨ (d ∧ b) ∨ (¬a)")
        formula4_0!.simplifyTautologies()
        XCTAssertEqual(formula4_0!.description, "(o2 ∧ ¬o1) ∨ (d ∧ b) ∨ (¬a)")
        formula4_0!.buildBitsetRepresentation()
        XCTAssertEqual(formula4_0!.bitsetRepresentation.description, "[[*, *, *, *, 0, 1], [*, 1, *, 1, *, *], [0, *, *, *, *, *]]")
        XCTAssertEqual(formula4_0!.bitsetRepresentation.debug_get_formula_string(), "(¬o1 ∧ o2) ∨ (b ∧ d) ∨ (¬a)")

        var formula5_0 = FormulaParser.parseDNFFormula(inputString: "((o2 ∧ ¬o1 ∧ false) ∨ (true ∧ b) ∨ (¬true))", apList: globalAPList)
        formula5_0!.simplifyTautologies()
        XCTAssertEqual(formula5_0!.description, "(b)")
        formula5_0!.buildBitsetRepresentation()
        XCTAssertEqual(formula5_0!.bitsetRepresentation.description, "[[*, 1, *, *, *, *]]")
        XCTAssertEqual(formula5_0!.bitsetRepresentation.debug_get_formula_string(), "(b)")

        var formula6_0 = FormulaParser.parseDNFFormula(inputString: "(false) ∨ (false)", apList: globalAPList)
        formula6_0!.simplifyTautologies()
        XCTAssertEqual(formula6_0!.description, "(false)")
        formula6_0!.buildBitsetRepresentation()
        XCTAssertEqual(formula6_0!.bitsetRepresentation.description, "[[]]")
        XCTAssertEqual(formula6_0!.bitsetRepresentation.debug_get_formula_string(), "(false)")

        var formula7_0 = FormulaParser.parseDNFFormula(inputString: "(true) ∨ (false)", apList: globalAPList)
        formula7_0!.simplifyTautologies()
        XCTAssertEqual(formula7_0!.description, "(true)")
        formula7_0!.buildBitsetRepresentation()
        XCTAssertEqual(formula7_0!.bitsetRepresentation.description, "[[*, *, *, *, *, *]]")
        XCTAssertEqual(formula7_0!.bitsetRepresentation.debug_get_formula_string(), "(true)")
    }

    func testBitsetFormulaAND() {
        let globalAPList = APList()

        // Create Sample APs
        _ = AP(name: "a", observable: true, list: globalAPList, output: true)
        _ = AP(name: "b", observable: true, list: globalAPList, output: true)
        _ = AP(name: "c", observable: true, list: globalAPList, output: true)
        _ = AP(name: "d", observable: true, list: globalAPList, output: true)
        _ = AP(name: "o1", observable: true, list: globalAPList, output: true)
        _ = AP(name: "o2", observable: true, list: globalAPList, output: true)

        var formula1_0 = FormulaParser.parseDNFFormula(inputString: "((a ∧ b) ∨ (a ∧ c))", apList: globalAPList)!
        formula1_0.simplifyTautologies()
        XCTAssertEqual(formula1_0.description, "(a ∧ b) ∨ (a ∧ c)")
        formula1_0.buildBitsetRepresentation()
        XCTAssertEqual(formula1_0.bitsetRepresentation.description, "[[1, 1, *, *, *, *], [1, *, 1, *, *, *]]")

        var formula2_0 = FormulaParser.parseDNFFormula(inputString: "(d)", apList: globalAPList)!
        formula2_0.simplifyTautologies()
        formula2_0.buildBitsetRepresentation()

        var formula3_0 = FormulaParser.parseDNFFormula(inputString: "(!a)", apList: globalAPList)!
        formula3_0.simplifyTautologies()
        formula3_0.buildBitsetRepresentation()

        var formula_false = FormulaParser.parseDNFFormula(inputString: "(false)", apList: globalAPList)!
        formula_false.simplifyTautologies()
        formula_false.buildBitsetRepresentation()

        var formula_true = FormulaParser.parseDNFFormula(inputString: "(true)", apList: globalAPList)!
        formula_true.simplifyTautologies()
        formula_true.buildBitsetRepresentation()

        let test_result_01 = formula_true && formula_false
        XCTAssertEqual(test_result_01.bitsetRepresentation.description, "[]")

        let test_result_02 = formula_true && formula1_0
        XCTAssertEqual(test_result_02.bitsetRepresentation.description, "[[1, 1, *, *, *, *], [1, *, 1, *, *, *]]")

        let test_result_03 = formula_false && formula1_0
        XCTAssertEqual(test_result_03.bitsetRepresentation.description, "[]")

        let test_result_04 = formula2_0 && formula1_0
        test_result_04.bitsetRepresentation.simplify_using_contains_check()
        XCTAssertEqual(test_result_04.bitsetRepresentation.description, "[[1, 1, *, 1, *, *], [1, *, 1, 1, *, *]]")

        let test_result_05 = formula3_0 && formula1_0
        test_result_05.bitsetRepresentation.simplify_using_contains_check()
        XCTAssertEqual(test_result_05.bitsetRepresentation.description, "[]")

        let test_result_06 = test_result_04 && formula1_0
        test_result_06.bitsetRepresentation.simplify_using_contains_check()
        XCTAssertEqual(test_result_06.bitsetRepresentation.description, "[[1, 1, *, 1, *, *], [1, *, 1, 1, *, *]]")
    }

    func testBitsetIncrement() {
        let bs1 = Bitset(size: 3, truth_value: false)

        let bs_max = Bitset(size: 10, truth_value: true)

        XCTAssertFalse(bs_max.increment(), "Already at maximum value, should return false")

        XCTAssertEqual(bs1.description, "[0, 0, 0]")
        XCTAssertTrue(bs1.increment(), "Increment should be fine for now")
        XCTAssertEqual(bs1.description, "[0, 0, 1]")
        XCTAssertTrue(bs1.increment(), "Increment should be fine for now")
        XCTAssertEqual(bs1.description, "[0, 1, 0]")
        XCTAssertTrue(bs1.increment(), "Increment should be fine for now")
        XCTAssertEqual(bs1.description, "[0, 1, 1]")
        XCTAssertTrue(bs1.increment(), "Increment should be fine for now")
        XCTAssertEqual(bs1.description, "[1, 0, 0]")
        XCTAssertTrue(bs1.increment(), "Increment should be fine for now")
        XCTAssertEqual(bs1.description, "[1, 0, 1]")
        XCTAssertTrue(bs1.increment(), "Increment should be fine for now")
        XCTAssertEqual(bs1.description, "[1, 1, 0]")
        XCTAssertTrue(bs1.increment(), "Increment should be fine for now")
        XCTAssertEqual(bs1.description, "[1, 1, 1]")
        XCTAssertFalse(bs1.increment(), "Maximum should have been reached")

    }

}
