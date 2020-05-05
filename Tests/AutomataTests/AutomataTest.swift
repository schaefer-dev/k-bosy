import XCTest

import Foundation

@testable import Automata


class AutomataTest: XCTestCase {
    
    func testAutomataRun() {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata_small.kbosy")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata_small.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        
        let ap_aOpt = automata.apList.lookupAP(apName: "a")
        let ap_bOpt = automata.apList.lookupAP(apName: "b")
        let ap_hOpt = automata.apList.lookupAP(apName: "h")
        
        
        if (ap_aOpt != nil || ap_bOpt != nil || ap_hOpt != nil) {
            let ap_a = ap_aOpt!
            let ap_b = ap_bOpt!
            let ap_h = ap_hOpt!
            
            // current State test values
            let currentState = CurrentState()
            currentState.update_value(ap: ap_a, value: false)
            currentState.update_value(ap: ap_b, value: false)
            currentState.update_value(ap: ap_h, value: false)
            
            XCTAssertEqual(automata.initial_states.count, 1)
            var initial_state = automata.initial_states[0]
            
            var applicable_transitions = initial_state.getApplicableTransitions(state: currentState)
            XCTAssertEqual(applicable_transitions.count, 1)
            XCTAssertEqual(applicable_transitions[0].end.name, "s0")
            XCTAssertEqual(applicable_transitions[0].end, initial_state)
            XCTAssertEqual(applicable_transitions[0].action, nil)
            
            currentState.update_value(ap: ap_a, value: true)
            currentState.update_value(ap: ap_b, value: false)
            currentState.update_value(ap: ap_h, value: false)
            
            applicable_transitions = initial_state.getApplicableTransitions(state: currentState)
            XCTAssertEqual(applicable_transitions.count, 1)
            XCTAssertEqual(applicable_transitions[0].end.name, "s1")
            XCTAssertEqual(applicable_transitions[0].end, automata.get_state(name: "s1"))
            XCTAssertEqual(applicable_transitions[0].action!.dnf[0].literals[0].description, "go")
            
            
            // change to state s1
            initial_state = applicable_transitions[0].end
            
            currentState.update_value(ap: ap_a, value: false)
            currentState.update_value(ap: ap_b, value: false)
            currentState.update_value(ap: ap_h, value: false)
            
            applicable_transitions = initial_state.getApplicableTransitions(state: currentState)
            XCTAssertEqual(applicable_transitions.count, 1)
            XCTAssertEqual(applicable_transitions[0].end.name, "s1")
            XCTAssertEqual(applicable_transitions[0].end, automata.get_state(name: "s1"))
            XCTAssertEqual(applicable_transitions[0].action!.dnf[0].literals[0].description, "go")
            
            
            
        } else {
            XCTAssert(false, "AP was not found correctly")
        }
    }

}
