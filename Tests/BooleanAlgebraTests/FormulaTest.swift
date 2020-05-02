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
        XCTAssertTrue(checkBracketCorrectness(input_str: str1))
        
        let str2 = "a∨((bcd) ∨ (d ∧ a))"
        XCTAssertTrue(checkBracketCorrectness(input_str: str2))
        
        let str3 = "a∨((bcd)) ∨ (d ∧ a))"
        XCTAssertFalse(checkBracketCorrectness(input_str: str3))
        
        let str4 = "((a∨((bcd)) ∨ (d ∧ a))"
        XCTAssertFalse(checkBracketCorrectness(input_str: str4))
    }
    
    
    func testParseConjunctionLongerAps() {
        let globalAPList = APList()
        
        // Create Sample APs
        let _ = AP(name: "a1", observable: true, list: globalAPList)
        let _ = AP(name: "b2", observable: true, list: globalAPList)
        let _ = AP(name: "c3", observable: false, list: globalAPList)
        let _ = AP(name: "d4", observable: false, list: globalAPList)
        
        
        
        let conj1 = parseConjunction(str_conj: "a1∧¬d4∧c3∧a1", apList: globalAPList)
        if conj1 == nil {
            XCTAssert(false, "Unexpected Conjunction Parsing Error")
        } else {
            XCTAssertEqual(conj1!.literals[0].toString(), "a1")
            XCTAssertEqual(conj1!.literals[1].toString(), "!d4")
            XCTAssertEqual(conj1!.literals[2].toString(), "c3")
            XCTAssertEqual(conj1!.literals[3].toString(), "a1")
        }
        
    }
    
    func testParseConjunction() {
        let globalAPList = APList()
        
        // Create Sample APs
        let _ = AP(name: "a", observable: true, list: globalAPList)
        let _ = AP(name: "b", observable: true, list: globalAPList)
        let _ = AP(name: "c", observable: false, list: globalAPList)
        let _ = AP(name: "d", observable: false, list: globalAPList)
        
        
        
        let conj1 = parseConjunction(str_conj: "a∧¬d∧c∧a", apList: globalAPList)
        if conj1 == nil {
            XCTAssert(false, "Unexpected Conjunction Parsing Error")
        } else {
            XCTAssertEqual(conj1!.literals[0].toString(), "a")
            XCTAssertEqual(conj1!.literals[1].toString(), "!d")
            XCTAssertEqual(conj1!.literals[2].toString(), "c")
            XCTAssertEqual(conj1!.literals[3].toString(), "a")
        }
        
    }
    
    
    func testParseDNFFormula() {
        let globalAPList = APList()
        
        // Create Sample APs
        let _ = AP(name: "a", observable: true, list: globalAPList)
        let _ = AP(name: "b", observable: true, list: globalAPList)
        let _ = AP(name: "c", observable: false, list: globalAPList)
        let _ = AP(name: "d", observable: false, list: globalAPList)
        
        
        
        let formula1 = parseDNFFormula(input_str: "((a) ∨ (b) ∨ (¬d))", apList: globalAPList)
        if formula1 == nil {
            XCTAssert(false, "Unexpected Formula Parsing Error")
        } else {
            XCTAssertEqual(formula1!.dnf[0].literals[0].toString(), "a")
            XCTAssertEqual(formula1!.dnf[0].literals.count, 1)
            XCTAssertEqual(formula1!.dnf[1].literals[0].toString(), "b")
            XCTAssertEqual(formula1!.dnf[1].literals.count, 1)
            XCTAssertEqual(formula1!.dnf[2].literals[0].toString(), "!d")
            XCTAssertEqual(formula1!.dnf[2].literals.count, 1)
            XCTAssertEqual(formula1!.dnf.count, 3)
        }
        
        let formula2 = parseDNFFormula(input_str: "((false) ∨ (b) ∨ (¬true))", apList: globalAPList)
        if formula2 == nil {
            XCTAssert(false, "Unexpected Formula Parsing Error")
        } else {
            XCTAssertEqual(formula2!.dnf[0].literals[0].toString(), "false")
            XCTAssertEqual(formula2!.dnf[0].literals.count, 1)
            XCTAssertEqual(formula2!.dnf[1].literals[0].toString(), "b")
            XCTAssertEqual(formula2!.dnf[1].literals.count, 1)
            XCTAssertEqual(formula2!.dnf[2].literals[0].toString(), "!true")
            XCTAssertEqual(formula2!.dnf[2].literals.count, 1)
            XCTAssertEqual(formula2!.dnf.count, 3)
        }
        
        let formula3 = parseDNFFormula(input_str: "((a ∧ ¬c ∧ ¬false) ∨ (b ∧ b) ∨ (¬d))", apList: globalAPList)
        if formula3 == nil {
            XCTAssert(false, "Unexpected Formula Parsing Error")
        } else {
            XCTAssertEqual(formula3!.dnf[0].literals[0].toString(), "a")
            XCTAssertEqual(formula3!.dnf[0].literals[1].toString(), "!c")
            XCTAssertEqual(formula3!.dnf[0].literals[2].toString(), "!false")
            XCTAssertEqual(formula3!.dnf[0].literals.count, 3)
            XCTAssertEqual(formula3!.dnf[1].literals[0].toString(), "b")
            XCTAssertEqual(formula3!.dnf[1].literals[1].toString(), "b")
            XCTAssertEqual(formula3!.dnf[1].literals.count, 2)
            XCTAssertEqual(formula3!.dnf[2].literals[0].toString(), "!d")
            XCTAssertEqual(formula3!.dnf[2].literals.count, 1)
            XCTAssertEqual(formula3!.dnf.count, 3)
        }
    }
}
