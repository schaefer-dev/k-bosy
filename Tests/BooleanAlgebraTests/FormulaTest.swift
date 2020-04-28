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
}
