import XCTest

import Foundation

@testable import Automata


class LiteralTest: XCTestCase {
    
    
    func testLiteraldescription() {
        let globalAPList = APList()
        
        // Create Sample APs
        let test_ap1 = AP(name: "test1", observable: true, list: globalAPList)
        let _ = AP(name: "test2", observable: true, list: globalAPList)
        let _ = AP(name: "test3", observable: false, list: globalAPList)
        
        
        // Create Sample Variables that may occur in a formula, they are linked to APs
        let lit1: Literal = Variable(negated: true, atomicProposition: test_ap1)
        
        // TODO: add erorr here if lookup fails!
        let lit2: Literal = Variable(negated: true, atomicProposition: globalAPList.lookupAP(apName: "test2")!)
        let lit3: Literal = Variable(negated: false, atomicProposition: globalAPList.lookupAP(apName: "test3")!)
        // Create Sample Constats that may occur in a formula
        let lit4: Literal = Constant(negated: true, truthValue: true)
        let lit5: Literal = Constant(negated: false, truthValue: false)
        
        XCTAssertEqual(lit1.description, "¬test1")
        XCTAssertEqual(lit2.description, "¬test2")
        XCTAssertEqual(lit3.description, "test3")
        XCTAssertEqual(lit4.description, "¬true")
        XCTAssertEqual(lit5.description, "false")
    }
    
    
    func testLiteralEval() {
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
        let currentState = CurrentTruthValues()
        currentState.update_value(ap: test_ap1, value: true)
        currentState.update_value(ap: test_ap2, value: false)
        currentState.update_value(ap: test_ap3, value: true)
        
        XCTAssertEqual(lit1.eval(truthValues: currentState), false)
        XCTAssertEqual(lit2.eval(truthValues: currentState), true)
        XCTAssertEqual(lit3.eval(truthValues: currentState), true)
        XCTAssertEqual(lit4.eval(truthValues: currentState), false)
        XCTAssertEqual(lit5.eval(truthValues: currentState), false)
    }
    
    
    func testParseLiteral() {
        let globalAPList = APList()
        
        // Create Sample APs
        let _ = AP(name: "a", observable: true, list: globalAPList)
        let _ = AP(name: "b", observable: true, list: globalAPList)
        let _ = AP(name: "c12", observable: false, list: globalAPList)
        let _ = AP(name: "d", observable: false, list: globalAPList)
        
        
        
        let lit1 = FormulaParser.parseLiteral(str_literal: "", apList: globalAPList)
        if lit1 != nil {
            XCTAssert(false, "Expected Literal parsing error because literal empty")
        }
        
        let lit2 = FormulaParser.parseLiteral(str_literal: "¬", apList: globalAPList)
        if lit2 != nil {
            XCTAssert(false, "Expected Literal parsing error because literal empty")
        }
        
        let lit3 = FormulaParser.parseLiteral(str_literal: "a", apList: globalAPList)
        if lit3 == nil {
            XCTAssert(false, "Unexpected Literal Parsing Error")
        } else {
            XCTAssertEqual(lit3!.description, "a")
        }
        
        let lit4 = FormulaParser.parseLiteral(str_literal: "c12", apList: globalAPList)
        if lit4 == nil {
            XCTAssert(false, "Unexpected Literal Parsing Error")
        } else {
            XCTAssertEqual(lit4!.description, "c12")
        }
        
        let lit5 = FormulaParser.parseLiteral(str_literal: "¬false", apList: globalAPList)
        if lit5 == nil {
            XCTAssert(false, "Unexpected Literal Parsing Error")
        } else {
            XCTAssertEqual(lit5!.description, "¬false")
        }
        
        
    }
    
}
