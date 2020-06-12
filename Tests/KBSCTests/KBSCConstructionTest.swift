//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 12.06.20.
//

import Foundation


import Foundation

import XCTest

import Foundation

@testable import Automata

class KBSCConstructionTest: XCTestCase {

    
    func testKBSCConstructionSimple() {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_numberv1.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        
        let automataOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_numberv1.gv", info: automataInfo)
        XCTAssert(automataOpt != nil)
        let automata = automataOpt!
        
        print("\n\n----------------------------------\nTEST: Starting building of obs Automata now...\n")
        
        let obs_automata = AutomataKBSC.constructObservableAutomataKBSC(input_automata: automata)
        
        
        XCTAssertEqual(obs_automata.get_allStates().count, 6, "expected the obs Automata to consist of 6 states")
        
        
        // NOTE: 4 different truth values possible, and currently every truth value has its own transition, which means that the number of transitions is multiplied by 4 to the intuitive version one would build by hand
        
        // Check transitions outgoing from s0
        XCTAssertEqual(obs_automata.get_state(name: "s0")!.transitions.count, 1 * 4, "expected the initial state to have 4 Transitions, because 4 different truth value combinations possible with 2 APs")
        XCTAssertEqual(obs_automata.get_state(name: "s0")!.transitions[0].description, "{s0 + (¬o1 ∧ ¬o2) --> s1s2}")
        XCTAssertEqual(obs_automata.get_state(name: "s0")!.transitions[1].description, "{s0 + (¬o1 ∧ o2) --> s1s2}")
        XCTAssertEqual(obs_automata.get_state(name: "s0")!.transitions[2].description, "{s0 + (o1 ∧ ¬o2) --> s1s2}")
        XCTAssertEqual(obs_automata.get_state(name: "s0")!.transitions[3].description, "{s0 + (o1 ∧ o2) --> s1s2}")
        
        // Check transitions outgoing from s1s2
        XCTAssertEqual(obs_automata.get_state(name: "s1s2")!.transitions.count, 7, "")
        // index of transitions here is not fixed, if we fix index instead of contains check this test is nondeterministic, think about why this is the case.
        var expected_transitions_s1s2 = ["{s1s2 + (¬o1 ∧ ¬o2) --> s1s2}"]
        expected_transitions_s1s2.append("{s1s2 + (¬o1 ∧ o2) --> s1}")
        expected_transitions_s1s2.append("{s1s2 + (¬o1 ∧ o2) --> s4}")
        expected_transitions_s1s2.append("{s1s2 + (o1 ∧ ¬o2) --> s2}")
        expected_transitions_s1s2.append("{s1s2 + (o1 ∧ ¬o2) --> s3}")
        expected_transitions_s1s2.append("{s1s2 + (o1 ∧ o2) --> s3}")
        expected_transitions_s1s2.append("{s1s2 + (o1 ∧ o2) --> s4}")
        
        var transition_strings_s1s2: [String] = []
        for trans in obs_automata.get_state(name: "s1s2")!.transitions {
            transition_strings_s1s2.append(trans.description)
        }
        for elem in expected_transitions_s1s2 {
            XCTAssertTrue(transition_strings_s1s2.contains(elem), "expected transition " + elem + " was not found in automata")
        }
        for elem in transition_strings_s1s2 {
            XCTAssertTrue(expected_transitions_s1s2.contains(elem), "transition " + elem + " was not expected by test")
        }
        
        
        
        // Check transitions outgoing from s1
        XCTAssertEqual(obs_automata.get_state(name: "s1")!.transitions.count, 4, "")
        // index of transitions here is not fixed, if we fix index instead of contains check this test is nondeterministic, think about why this is the case.
        var expected_transitions_s1 = ["{s1 + (¬o1 ∧ ¬o2) --> s1}"]
        expected_transitions_s1.append("{s1 + (¬o1 ∧ o2) --> s1}")
        expected_transitions_s1.append("{s1 + (o1 ∧ ¬o2) --> s3}")
        expected_transitions_s1.append("{s1 + (o1 ∧ o2) --> s3}")
        
        var transition_strings_s1: [String] = []
        for trans in obs_automata.get_state(name: "s1")!.transitions {
            transition_strings_s1.append(trans.description)
        }
        for elem in expected_transitions_s1 {
            XCTAssertTrue(transition_strings_s1.contains(elem), "expected transition " + elem + " was not found in automata")
        }
        for elem in transition_strings_s1 {
            XCTAssertTrue(expected_transitions_s1.contains(elem), "transition " + elem + " was not expected by test")
        }
        
        
        // Check transitions outgoing from s2
        XCTAssertEqual(obs_automata.get_state(name: "s2")!.transitions.count, 4, "")
        // index of transitions here is not fixed, if we fix index instead of contains check this test is nondeterministic, think about why this is the case.
        var expected_transitions_s2 = ["{s2 + (¬o1 ∧ ¬o2) --> s2}"]
        expected_transitions_s2.append("{s2 + (¬o1 ∧ o2) --> s4}")
        expected_transitions_s2.append("{s2 + (o1 ∧ ¬o2) --> s2}")
        expected_transitions_s2.append("{s2 + (o1 ∧ o2) --> s4}")
        
        var transition_strings_s2: [String] = []
        for trans in obs_automata.get_state(name: "s2")!.transitions {
            transition_strings_s2.append(trans.description)
        }
        for elem in expected_transitions_s2 {
            XCTAssertTrue(transition_strings_s2.contains(elem), "expected transition " + elem + " was not found in automata")
        }
        for elem in transition_strings_s2 {
            XCTAssertTrue(expected_transitions_s2.contains(elem), "transition " + elem + " was not expected by test")
        }
        
        
        // Check transitions outgoing from s3
        XCTAssertEqual(obs_automata.get_state(name: "s3")!.transitions.count, 4, "")
        // index of transitions here is not fixed, if we fix index instead of contains check this test is nondeterministic, think about why this is the case.
        var expected_transitions_s3 = ["{s3 + (¬o1 ∧ ¬o2) --> s3}"]
        expected_transitions_s3.append("{s3 + (¬o1 ∧ o2) --> s3}")
        expected_transitions_s3.append("{s3 + (o1 ∧ ¬o2) --> s3}")
        expected_transitions_s3.append("{s3 + (o1 ∧ o2) --> s3}")
        
        var transition_strings_s3: [String] = []
        for trans in obs_automata.get_state(name: "s3")!.transitions {
            transition_strings_s3.append(trans.description)
        }
        for elem in expected_transitions_s3 {
            XCTAssertTrue(transition_strings_s3.contains(elem), "expected transition " + elem + " was not found in automata")
        }
        for elem in transition_strings_s3 {
            XCTAssertTrue(expected_transitions_s3.contains(elem), "transition " + elem + " was not expected by test")
        }
        
        
        // Check transitions outgoing from s4
        XCTAssertEqual(obs_automata.get_state(name: "s4")!.transitions.count, 4, "")
        // index of transitions here is not fixed, if we fix index instead of contains check this test is nondeterministic, think about why this is the case.
        var expected_transitions_s4 = ["{s4 + (¬o1 ∧ ¬o2) --> s4}"]
        expected_transitions_s4.append("{s4 + (¬o1 ∧ o2) --> s4}")
        expected_transitions_s4.append("{s4 + (o1 ∧ ¬o2) --> s4}")
        expected_transitions_s4.append("{s4 + (o1 ∧ o2) --> s4}")
        
        var transition_strings_s4: [String] = []
        for trans in obs_automata.get_state(name: "s4")!.transitions {
            transition_strings_s4.append(trans.description)
        }
        for elem in expected_transitions_s4 {
            XCTAssertTrue(transition_strings_s4.contains(elem), "expected transition " + elem + " was not found in automata")
        }
        for elem in transition_strings_s4 {
            XCTAssertTrue(expected_transitions_s4.contains(elem), "transition " + elem + " was not expected by test")
        }
    }


}
