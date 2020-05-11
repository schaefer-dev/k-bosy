import XCTest

import Foundation

@testable import Automata


class AutomataTest: XCTestCase {
    
    func testAutomataRun() {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata_small.kbosy")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        XCTAssertEqual(automataInfo.guarantees.count, 1)
        XCTAssertEqual(automataInfo.guarantees[0].description, "F (go)")
        
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata_small_kripke.gv", info: automataInfo)
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
            let currentState = CurrentTruthValues()
            currentState.update_value(ap: ap_a, value: false)
            currentState.update_value(ap: ap_b, value: false)
            currentState.update_value(ap: ap_h, value: false)
            
            XCTAssertEqual(automata.initial_states.count, 1)
            var initial_state = automata.initial_states[0]
            
            XCTAssertEqual(initial_state.propositions.count, 0)
            
            var applicable_transitions = initial_state.getApplicableTransitions(truthValues: currentState)
            XCTAssertEqual(applicable_transitions.count, 1)
            XCTAssertEqual(applicable_transitions[0].end.name, "s0")
            XCTAssertEqual(applicable_transitions[0].end, initial_state)
            
            currentState.update_value(ap: ap_a, value: true)
            currentState.update_value(ap: ap_b, value: false)
            currentState.update_value(ap: ap_h, value: false)
            
            applicable_transitions = initial_state.getApplicableTransitions(truthValues: currentState)
            XCTAssertEqual(applicable_transitions.count, 1)
            XCTAssertEqual(applicable_transitions[0].end.name, "s1")
            XCTAssertEqual(applicable_transitions[0].end, automata.get_state(name: "s1"))
            
            
            // change to state s1
            initial_state = applicable_transitions[0].end
            XCTAssertEqual(initial_state.propositions.count, 1)
            XCTAssertEqual(initial_state.propositions[0].description, "go")
            
            currentState.update_value(ap: ap_a, value: false)
            currentState.update_value(ap: ap_b, value: false)
            currentState.update_value(ap: ap_h, value: false)
            
            applicable_transitions = initial_state.getApplicableTransitions(truthValues: currentState)
            XCTAssertEqual(applicable_transitions.count, 1)
            XCTAssertEqual(applicable_transitions[0].end.name, "s1")
            XCTAssertEqual(applicable_transitions[0].end, automata.get_state(name: "s1"))
            
            
            
        } else {
            XCTAssert(false, "AP was not found correctly")
        }
    }
    
    
    func testGenerateInitialStateAssumptions() {
        
        var automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata_small.kbosy")
        XCTAssert(automataInfoOpt != nil)
        var automataInfo = automataInfoOpt!
        
        XCTAssertEqual(automataInfo.guarantees.count, 1)
        XCTAssertEqual(automataInfo.guarantees[0].description, "F (go)")
        
        
        var dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata_small_kripke.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        var automata = dotGraphOpt!
        
        
        var test_value = AssumptionsGenerator._generateInitialStateAssumptions(auto: automata)
        
        XCTAssertEqual(test_value.description, "s0")
        
        
        
        automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata_small.kbosy")
        XCTAssert(automataInfoOpt != nil)
        automataInfo = automataInfoOpt!
        
        XCTAssertEqual(automataInfo.guarantees.count, 1)
        XCTAssertEqual(automataInfo.guarantees[0].description, "F (go)")
        
        
        dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata_small_kripke_multiple-initialStates.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        automata = dotGraphOpt!
        
        
        test_value = AssumptionsGenerator._generateInitialStateAssumptions(auto: automata)
        
        
        XCTAssertEqual(test_value.description, "((s0) ∨ (s1)) ∨ (s2)")
        
    }

}
