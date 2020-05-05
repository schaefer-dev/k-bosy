import XCTest

import Foundation

@testable import Automata


class FormulaTest: XCTestCase {
    
    func testConjunctionEval() {
        let globalAPList = APList()
        
        // Create Sample APs
        let test_ap1 = AP(name: "test1", observable: true, list: globalAPList)
        let test_ap2 = AP(name: "test2", observable: true, list: globalAPList)
        let test_ap3 = AP(name: "test3", observable: false, list: globalAPList)
        
        
        // Create Sample Variables that may occur in a formula, they are linked to APs
        let lit1: Literal = Variable(negated: true, atomicProposition: test_ap1)
        
        // TODO: add erorr here if lookup fails!
        let lit2: Literal = Variable(negated: true, atomicProposition: globalAPList.lookupAP(apName: "test2")!)
        let lit3: Literal = Variable(negated: false, atomicProposition: globalAPList.lookupAP(apName: "test3")!)
        // Create Sample Constats that may occur in a formula
        let lit4: Literal = Constant(negated: true, truthValue: true)
        let lit5: Literal = Constant(negated: false, truthValue: false)
        
        // current State test values
        let currentState = CurrentState()
        currentState.update_value(ap: test_ap1, value: true)
        currentState.update_value(ap: test_ap2, value: false)
        currentState.update_value(ap: test_ap3, value: true)

        // make sure values of single literals are what is expected by this test
        XCTAssertEqual(lit1.eval(state: currentState), false)
        XCTAssertEqual(lit2.eval(state: currentState), true)
        XCTAssertEqual(lit3.eval(state: currentState), true)
        XCTAssertEqual(lit4.eval(state: currentState), false)
        XCTAssertEqual(lit5.eval(state: currentState), false)
        
        
        // Create conjunctions
        let conj1Content = [lit2, lit3]
        let conj1 = Conjunction(literalsContainedInConjunction: conj1Content)
        
        let conj2Content = [lit2, lit3, lit2, lit3, lit3]
        let conj2 = Conjunction(literalsContainedInConjunction: conj2Content)
        
        let conj3Content = [lit2, lit3, lit1]
        let conj3 = Conjunction(literalsContainedInConjunction: conj3Content)
        
        let conj4Content = [lit2, lit3, lit2, lit3, lit5, lit3]
        let conj4 = Conjunction(literalsContainedInConjunction: conj4Content)
        
        XCTAssertEqual(conj1.eval(state: currentState), true)
        XCTAssertEqual(conj2.eval(state: currentState), true)
        XCTAssertEqual(conj3.eval(state: currentState), false)
        XCTAssertEqual(conj4.eval(state: currentState), false)
    }
    
    
    func testDNFEval() {
        let globalAPList = APList()
        
        // Create Sample APs
        let test_ap1 = AP(name: "test1", observable: true, list: globalAPList)
        let test_ap2 = AP(name: "test2", observable: true, list: globalAPList)
        let test_ap3 = AP(name: "test3", observable: false, list: globalAPList)
        
        
        // Create Sample Variables that may occur in a formula, they are linked to APs
        let lit1: Literal = Variable(negated: true, atomicProposition: test_ap1)
        
        // TODO: add erorr here if lookup fails!
        let lit2: Literal = Variable(negated: true, atomicProposition: globalAPList.lookupAP(apName: "test2")!)
        let lit3: Literal = Variable(negated: false, atomicProposition: globalAPList.lookupAP(apName: "test3")!)
        // Create Sample Constats that may occur in a formula
        let lit4: Literal = Constant(negated: true, truthValue: true)
        let lit5: Literal = Constant(negated: false, truthValue: false)
        
        // current State test values
        let currentState = CurrentState()
        currentState.update_value(ap: test_ap1, value: true)
        currentState.update_value(ap: test_ap2, value: false)
        currentState.update_value(ap: test_ap3, value: true)

        // make sure values of single literals are what is expected by this test
        XCTAssertEqual(lit1.eval(state: currentState), false)
        XCTAssertEqual(lit2.eval(state: currentState), true)
        XCTAssertEqual(lit3.eval(state: currentState), true)
        XCTAssertEqual(lit4.eval(state: currentState), false)
        XCTAssertEqual(lit5.eval(state: currentState), false)
        
        
        // Create conjunctions
        let conj1Content = [lit2, lit3]
        let conj1 = Conjunction(literalsContainedInConjunction: conj1Content)
        
        let conj2Content = [lit2, lit3, lit2, lit3, lit3]
        let conj2 = Conjunction(literalsContainedInConjunction: conj2Content)
        
        let conj3Content = [lit2, lit3, lit1]
        let conj3 = Conjunction(literalsContainedInConjunction: conj3Content)
        
        let conj4Content = [lit2, lit3, lit2, lit3, lit5, lit3]
        let conj4 = Conjunction(literalsContainedInConjunction: conj4Content)
        
        // make sure values of conjunctions are what is expected by this test
        XCTAssertEqual(conj1.eval(state: currentState), true)
        XCTAssertEqual(conj2.eval(state: currentState), true)
        XCTAssertEqual(conj3.eval(state: currentState), false)
        XCTAssertEqual(conj4.eval(state: currentState), false)
        
        
        let dnf1Content = [conj1, conj3, conj4]
        let dnf1 = Formula(containedConjunctions: dnf1Content)
        
        let dnf2Content = [conj3, conj4]
        let dnf2 = Formula(containedConjunctions: dnf2Content)
        
        
        let dnf3Content = [conj3, conj3, conj4]
        let dnf3 = Formula(containedConjunctions: dnf3Content)
        
        let dnf4Content = [conj4, conj4, conj1]
        let dnf4 = Formula(containedConjunctions: dnf4Content)
        
        
        XCTAssertEqual(dnf1.eval(state: currentState), true)
        XCTAssertEqual(dnf2.eval(state: currentState), false)
        XCTAssertEqual(dnf3.eval(state: currentState), false)
        XCTAssertEqual(dnf4.eval(state: currentState), true)
    }
    
    
    func testBracketCorrectnessCheck() {
        let str1 = "(a) ∧ (b)"
        XCTAssertTrue(FormulaParser.checkBracketCorrectness(input_str: str1))
        
        let str2 = "((a)∨((bcd)) ∨ ((d) ∧ (a)))"
        XCTAssertTrue(FormulaParser.checkBracketCorrectness(input_str: str2))
        
        let str3 = "a∨((bcd)) ∨ (d ∧ a))"
        XCTAssertFalse(FormulaParser.checkBracketCorrectness(input_str: str3))
        
        let str4 = "((a∨((bcd)) ∨ (d ∧ a))"
        XCTAssertFalse(FormulaParser.checkBracketCorrectness(input_str: str4))
        
        let str5 = "(a∨((bcd) ∨ d) ∧ a)"
        XCTAssertFalse(FormulaParser.checkBracketCorrectness(input_str: str5))
        
        let str6 = "a∨(bcd ∨ (d ∧ a))"
        XCTAssertFalse(FormulaParser.checkBracketCorrectness(input_str: str6))
        
        let str7 = "(a∨bcd ∨ (d ∧ a))"
        XCTAssertTrue(FormulaParser.checkBracketCorrectness(input_str: str7))
    }
    
    
    func testdescription() {
        let globalAPList = APList()
        
        // Create Sample APs
        let _ = AP(name: "a", observable: true, list: globalAPList)
        let _ = AP(name: "b", observable: true, list: globalAPList)
        let _ = AP(name: "c", observable: false, list: globalAPList)
        let _ = AP(name: "d", observable: false, list: globalAPList)
        let _ = AP(name: "test", observable: false, list: globalAPList)
        
        let str1 = "(a) ∧ (¬b)"
        let formula1 = FormulaParser.parseDNFFormula(input_str: str1, apList: globalAPList)
        XCTAssertEqual(formula1!.dnf.count, 1)
        XCTAssertEqual(formula1!.dnf[0].literals.count, 2)
        XCTAssertEqual(formula1!.description, "(a ∧ ¬b)")
        
        let str2 = "((a)∨((¬test)) ∨ ((d) ∧ (a)))"
        XCTAssertTrue(FormulaParser.checkBracketCorrectness(input_str: str2))
        let formula2 = FormulaParser.parseDNFFormula(input_str: str2, apList: globalAPList)
        XCTAssertEqual(formula2!.description, "(a) ∨ (¬test) ∨ (d ∧ a)")
        
        let str3 = "(test ∨ (¬d ∧ ¬a))"
        XCTAssertTrue(FormulaParser.checkBracketCorrectness(input_str: str3))
        let formula3 = FormulaParser.parseDNFFormula(input_str: str3, apList: globalAPList)
        XCTAssertEqual(formula3!.description, "(test) ∨ (¬d ∧ ¬a)")
    }
    
    
    func testParseConjunctionLongerAps() {
        let globalAPList = APList()
        
        // Create Sample APs
        let _ = AP(name: "a1", observable: true, list: globalAPList)
        let _ = AP(name: "b2", observable: true, list: globalAPList)
        let _ = AP(name: "c3", observable: false, list: globalAPList)
        let _ = AP(name: "d4", observable: false, list: globalAPList)
        
        
        
        let conj1 = FormulaParser.parseConjunction(str_conj: "a1∧¬d4∧c3∧a1", apList: globalAPList)
        if conj1 == nil {
            XCTAssert(false, "Unexpected Conjunction Parsing Error")
        } else {
            XCTAssertEqual(conj1!.literals[0].description, "a1")
            XCTAssertEqual(conj1!.literals[1].description, "¬d4")
            XCTAssertEqual(conj1!.literals[2].description, "c3")
            XCTAssertEqual(conj1!.literals[3].description, "a1")
        }
        
    }
    
    func testParseConjunction() {
        let globalAPList = APList()
        
        // Create Sample APs
        let _ = AP(name: "a", observable: true, list: globalAPList)
        let _ = AP(name: "b", observable: true, list: globalAPList)
        let _ = AP(name: "c", observable: false, list: globalAPList)
        let _ = AP(name: "d", observable: false, list: globalAPList)
        
        
        
        let conj1 = FormulaParser.parseConjunction(str_conj: "a∧¬d∧c∧a", apList: globalAPList)
        if conj1 == nil {
            XCTAssert(false, "Unexpected Conjunction Parsing Error")
        } else {
            XCTAssertEqual(conj1!.literals[0].description, "a")
            XCTAssertEqual(conj1!.literals[1].description, "¬d")
            XCTAssertEqual(conj1!.literals[2].description, "c")
            XCTAssertEqual(conj1!.literals[3].description, "a")
        }
        
        let conj2 = FormulaParser.parseConjunction(str_conj: "a∧¬false∧c∧a", apList: globalAPList)
        if conj2 == nil {
            XCTAssert(false, "Unexpected Conjunction Parsing Error")
        } else {
            XCTAssertEqual(conj2!.literals[0].description, "a")
            XCTAssertEqual(conj2!.literals[1].description, "¬false")
            XCTAssertEqual(conj2!.literals[2].description, "c")
            XCTAssertEqual(conj2!.literals[3].description, "a")
        }
        
        let conj3 = FormulaParser.parseConjunction(str_conj: "a∧¬d1∧c∧a", apList: globalAPList)
        if conj3 != nil {
            XCTAssert(false, "Expected Conjunction Parsing Error")
        }
        
        let conj4 = FormulaParser.parseConjunction(str_conj: "a∧¬a∧c∧f", apList: globalAPList)
        if conj4 != nil {
            XCTAssert(false, "Expected Conjunction Parsing Error")
        }
        
        let conj5 = FormulaParser.parseConjunction(str_conj: "a∧¬a∧c∧∧a", apList: globalAPList)
        if conj5 != nil {
            XCTAssert(false, "Expected Conjunction Parsing Error")
        }
        
        let conj6 = FormulaParser.parseConjunction(str_conj: "a∧¬a∧c∧a∧", apList: globalAPList)
        if conj6 != nil {
            XCTAssert(false, "Expected Conjunction Parsing Error")
        }
        
    }
    
    
    func testParseDNFFormula() {
        let globalAPList = APList()
        
        // Create Sample APs
        let _ = AP(name: "a", observable: true, list: globalAPList)
        let _ = AP(name: "b", observable: true, list: globalAPList)
        let _ = AP(name: "c", observable: false, list: globalAPList)
        let _ = AP(name: "d", observable: false, list: globalAPList)
        
        
        
        let formula1 = FormulaParser.parseDNFFormula(input_str: "((a) ∨ (b) ∨ (¬d))", apList: globalAPList)
        if formula1 == nil {
            XCTAssert(false, "Unexpected Formula Parsing Error")
        } else {
            XCTAssertEqual(formula1!.dnf[0].literals[0].description, "a")
            XCTAssertEqual(formula1!.dnf[0].literals.count, 1)
            XCTAssertEqual(formula1!.dnf[1].literals[0].description, "b")
            XCTAssertEqual(formula1!.dnf[1].literals.count, 1)
            XCTAssertEqual(formula1!.dnf[2].literals[0].description, "¬d")
            XCTAssertEqual(formula1!.dnf[2].literals.count, 1)
            XCTAssertEqual(formula1!.dnf.count, 3)
        }
        
        let formula2 = FormulaParser.parseDNFFormula(input_str: "((false) ∨ (b) ∨ (¬true))", apList: globalAPList)
        if formula2 == nil {
            XCTAssert(false, "Unexpected Formula Parsing Error")
        } else {
            XCTAssertEqual(formula2!.dnf[0].literals[0].description, "false")
            XCTAssertEqual(formula2!.dnf[0].literals.count, 1)
            XCTAssertEqual(formula2!.dnf[1].literals[0].description, "b")
            XCTAssertEqual(formula2!.dnf[1].literals.count, 1)
            XCTAssertEqual(formula2!.dnf[2].literals[0].description, "¬true")
            XCTAssertEqual(formula2!.dnf[2].literals.count, 1)
            XCTAssertEqual(formula2!.dnf.count, 3)
        }
        
        let formula3 = FormulaParser.parseDNFFormula(input_str: "((a ∧ ¬c ∧ ¬false) ∨ (b ∧ b) ∨ (¬d))", apList: globalAPList)
        if formula3 == nil {
            XCTAssert(false, "Unexpected Formula Parsing Error")
        } else {
            XCTAssertEqual(formula3!.dnf[0].literals[0].description, "a")
            XCTAssertEqual(formula3!.dnf[0].literals[1].description, "¬c")
            XCTAssertEqual(formula3!.dnf[0].literals[2].description, "¬false")
            XCTAssertEqual(formula3!.dnf[0].literals.count, 3)
            XCTAssertEqual(formula3!.dnf[1].literals[0].description, "b")
            XCTAssertEqual(formula3!.dnf[1].literals[1].description, "b")
            XCTAssertEqual(formula3!.dnf[1].literals.count, 2)
            XCTAssertEqual(formula3!.dnf[2].literals[0].description, "¬d")
            XCTAssertEqual(formula3!.dnf[2].literals.count, 1)
            XCTAssertEqual(formula3!.dnf.count, 3)
        }
        
        
        let formula4 = FormulaParser.parseDNFFormula(input_str: "((a ∧ ¬c ∧ ¬false) ∨ ∨  (b ∧ b) ∨ (¬d))", apList: globalAPList)
        if formula4 != nil {
            XCTAssert(false, "Expected Formula Parsing Error")
        }
        
        let formula5 = FormulaParser.parseDNFFormula(input_str: "", apList: globalAPList)
        if formula5 == nil {
            XCTAssert(false, "Unexpected Formula Parsing Error")
        } else {
            XCTAssertEqual(formula5!.dnf[0].literals[0].description, "true")
            XCTAssertEqual(formula5!.dnf[0].literals.count, 1)
            XCTAssertEqual(formula5!.dnf.count, 1)
        }
        
        let formula6 = FormulaParser.parseDNFFormula(input_str: "((a ∧ ¬c ∧ ¬false) ∨ (b ∧ b) ∨ (¬d) ∨ )", apList: globalAPList)
        if formula6 != nil {
            XCTAssert(false, "Expected Formula Parsing Error")
        }
    }
}
