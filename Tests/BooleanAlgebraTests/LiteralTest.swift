import XCTest

import Foundation

@testable import Automata


class LiteralTest: XCTestCase {
    
    
    func testLiteralToString() {
        let globalAPList = APList()
        
        // Create Sample APs
        let _ = AP(name: "test1", observable: true, list: globalAPList)
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
        
        XCTAssertEqual(lit1.toString(), "!test1")
        XCTAssertEqual(lit2.toString(), "!test2")
        XCTAssertEqual(lit3.toString(), "test3")
        XCTAssertEqual(lit4.toString(), "!true")
        XCTAssertEqual(lit5.toString(), "false")
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
        let currentState = CurrentState()
        currentState.update_value(ap: test_ap1, value: true)
        currentState.update_value(ap: test_ap2, value: false)
        currentState.update_value(ap: test_ap3, value: true)
        
        XCTAssertEqual(lit1.eval(state: currentState), false)
        XCTAssertEqual(lit2.eval(state: currentState), true)
        XCTAssertEqual(lit3.eval(state: currentState), true)
        XCTAssertEqual(lit4.eval(state: currentState), false)
        XCTAssertEqual(lit5.eval(state: currentState), false)
    }
    
}
