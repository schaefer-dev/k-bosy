import XCTest

import Foundation

@testable import Automata


class AutomataTest: XCTestCase {
    
    func testAutomataRun() {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_automata_small.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        XCTAssertEqual(automataInfo.guarantees.count, 1)
        XCTAssertEqual(automataInfo.guarantees[0].description, "F (go)")
        
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_automata_small_kripke.gv", info: automataInfo)
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
        
        var automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_automata_small.json")
        XCTAssert(automataInfoOpt != nil)
        var automataInfo = automataInfoOpt!
        
        XCTAssertEqual(automataInfo.guarantees.count, 1)
        XCTAssertEqual(automataInfo.guarantees[0].description, "F (go)")
        
        
        var dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_automata_small_kripke.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        var automata = dotGraphOpt!
        
        
        var test_value = AssumptionsGenerator._generateInitialStateAssumptions(auto: automata)
        
        XCTAssertEqual(test_value.description, "s0")
        
        
        
        automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_automata_small.json")
        XCTAssert(automataInfoOpt != nil)
        automataInfo = automataInfoOpt!
        
        XCTAssertEqual(automataInfo.guarantees.count, 1)
        XCTAssertEqual(automataInfo.guarantees[0].description, "F (go)")
        
        
        dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_automata_small_kripke_multiple-initialStates.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        automata = dotGraphOpt!
        
        
        test_value = AssumptionsGenerator._generateInitialStateAssumptions(auto: automata)
        
        
        XCTAssertEqual(test_value.description, "((s0) ∨ (s1)) ∨ (s2)")
        
    }
    
    
    
    func testGenerateStateAssumptions2() {
        
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_automata_small.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        XCTAssertEqual(automataInfo.guarantees.count, 1)
        XCTAssertEqual(automataInfo.guarantees[0].description, "F (go)")
        
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_automata_small_kripke.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        
        let test_value = AssumptionsGenerator._generatePossibleStateAssumptions(auto: automata)
        XCTAssertEqual(test_value.count, 3)
        
        XCTAssertEqual(test_value[0].description, "G ((s0) -> (¬ (s1)))")
        XCTAssertEqual(test_value[1].description, "G ((s1) -> (¬ (s0)))")
        XCTAssertEqual(test_value[2].description, "G ((s0) ∨ (s1))")
    }
    
    func testGenerateStateAssumptions3() {
        
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_automata_small.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        XCTAssertEqual(automataInfo.guarantees.count, 1)
        XCTAssertEqual(automataInfo.guarantees[0].description, "F (go)")
        
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_automata_small_kripke_multiple-initialStates.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        
        let test_value = AssumptionsGenerator._generatePossibleStateAssumptions(auto: automata)
        XCTAssertEqual(test_value.count, 4)
    
        
        XCTAssertEqual(test_value[0].description, "G ((s0) -> ((¬ (s1)) ∧ (¬ (s2))))")
        XCTAssertEqual(test_value[1].description, "G ((s1) -> ((¬ (s0)) ∧ (¬ (s2))))")
        XCTAssertEqual(test_value[2].description, "G ((s2) -> ((¬ (s0)) ∧ (¬ (s1))))")
        XCTAssertEqual(test_value[3].description, "G (((s0) ∨ (s1)) ∨ (s2))")
    }
    
    
    func testGenerateStateAPsAssumptions() {
        
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_env_01.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_env_01.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        
        let test_value = AssumptionsGenerator._generateStateAPsAssumptions(auto: automata)
        XCTAssertEqual(test_value.count, 4)
        XCTAssertEqual(test_value[0].description, "G ((s0) -> (((i1) ∧ (i2)) ∧ (¬ (grant))))")
        XCTAssertEqual(test_value[1].description, "G ((s1) -> (((grant) ∧ (i2)) ∧ (¬ (i1))))")
        XCTAssertEqual(test_value[2].description, "G ((s2) -> ((((⊤) ∧ (¬ (grant))) ∧ (¬ (i1))) ∧ (¬ (i2))))")
        XCTAssertEqual(test_value[3].description, "G ((s3) -> ((((grant) ∧ (i1)) ∧ (i2)) ∧ (⊤)))")
        
    }
    
    
    func testGenerateTransitionAssumptions() {
        
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_env_01.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_env_01.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        
        let test_value = AssumptionsGenerator._generateTransitionAssumptions(auto: automata)
        
        // 1 condition for each transition
        XCTAssertEqual(test_value.count, 4)
        
        XCTAssertEqual(test_value[0].description, "G ((¬ (s0)) ∨ (((request) ∧ (X (s1))) ∨ ((¬ (request)) ∧ (X (s0)))))")
        XCTAssertEqual(test_value[1].description, "G ((¬ (s1)) ∨ ((⊤) ∧ (X (s1))))")
        XCTAssertEqual(test_value[2].description, "G ((¬ (s2)) ∨ (((⊤) ∧ (X (s2))) ∨ ((⊤) ∧ (X (s3)))))")
        XCTAssertEqual(test_value[3].description, "G ((¬ (s3)) ∨ ((⊤) ∧ (X (s3))))")
    }
    
    
    func testGetAutomataInputAPs() {
        
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_env_01.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_env_01.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        
        let test_value = AssumptionsGenerator.getAutomataInputAPs(auto: automata)
        
        // 1 condition for each transition
        XCTAssertEqual(test_value.count, 7)
        XCTAssertEqual(test_value[0], "grant")
        XCTAssertEqual(test_value[1], "i1")
        XCTAssertEqual(test_value[2], "i2")
        XCTAssertEqual(test_value[3], "s0")
        XCTAssertEqual(test_value[4], "s1")
        XCTAssertEqual(test_value[5], "s2")
        XCTAssertEqual(test_value[6], "s3")
    }
    
    func testGetAutomataOutputAPs() {
        
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_env_01.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_env_01.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        
        let test_value = AssumptionsGenerator.getAutomataOutputAPs(auto: automata)
        
        // 1 condition for each transition
        XCTAssertEqual(test_value.count, 2)
        XCTAssertEqual(test_value[0], "go")
        XCTAssertEqual(test_value[1], "request")
    }
    
    
    func testGenerateAllAssumptions() {
        
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_env_01.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_env_01.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        
        let test_value = AssumptionsGenerator.generateAutomataAssumptions(auto: automata)
        
        // 1 condition for each transition
        XCTAssertEqual(test_value.count, 14)
        
        // TODO maybe complete this test here with different input so its not redudant with previous tests of submethods
    }
    
    func testGenerateAssumptionsNAS() {
        
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_nas_01.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_nas_01.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        
        let test_value = AssumptionsGenerator.generateAutomataAssumptions(auto: automata)
        
        // 1 condition for each transition
        XCTAssertEqual(test_value.count, 14)
        XCTAssertEqual(test_value[0].description, "G ((s0) -> (((¬ (s1)) ∧ (¬ (s2))) ∧ (¬ (s3))))")
        XCTAssertEqual(test_value[1].description, "G ((s1) -> (((¬ (s0)) ∧ (¬ (s2))) ∧ (¬ (s3))))")
        XCTAssertEqual(test_value[2].description, "G ((s2) -> (((¬ (s0)) ∧ (¬ (s1))) ∧ (¬ (s3))))")
        XCTAssertEqual(test_value[3].description, "G ((s3) -> (((¬ (s0)) ∧ (¬ (s1))) ∧ (¬ (s2))))")
        XCTAssertEqual(test_value[4].description, "G ((((s0) ∨ (s1)) ∨ (s2)) ∨ (s3))")
        
        XCTAssertEqual(test_value[5].description, "s0")
        XCTAssertEqual(test_value[6].description, "G ((s0) -> ((⊤) ∧ (¬ (r1))))")
        XCTAssertEqual(test_value[7].description, "G ((s1) -> ((r1) ∧ (⊤)))")
        XCTAssertEqual(test_value[8].description, "G ((s2) -> ((r1) ∧ (⊤)))")
        XCTAssertEqual(test_value[9].description, "G ((s3) -> ((⊤) ∧ (¬ (r1))))")
        XCTAssertEqual(test_value[10].description, "G ((¬ (s0)) ∨ (((⊤) ∧ (X (s0))) ∨ ((⊤) ∧ (X (s1)))))")
        XCTAssertEqual(test_value[11].description, "G ((¬ (s1)) ∨ (((¬ (g1)) ∧ (X (s1))) ∨ ((g1) ∧ (X (s2)))))")
        XCTAssertEqual(test_value[12].description, "G ((¬ (s2)) ∨ (((¬ (g1)) ∧ (X (s2))) ∨ ((g1) ∧ (X (s3)))))")
        XCTAssertEqual(test_value[13].description, "G ((¬ (s3)) ∨ ((⊤) ∧ (X (s1))))")
        
        // TODO maybe complete this test here with different input so its not redudant with previous tests of submethods
    }
    
    

}
