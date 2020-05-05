import XCTest

import Foundation

@testable import Automata
@testable import Specification


class FileParsingTest: XCTestCase {
    
    
    func testAutomataInfoParsing() {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata.kbosy")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
                        
        // Testing if JSON has been read correctly
        XCTAssertEqual(automataInfo.observableAP[0], "y1")
        XCTAssertEqual(automataInfo.observableAP[1], "y2")
        XCTAssertEqual(automataInfo.observableAP[2], "p1")
        XCTAssertEqual(automataInfo.observableAP[3], "p2")
        XCTAssertEqual(automataInfo.observableAP.count, 4)
        
        XCTAssertEqual(automataInfo.hiddenAP[0], "h1")
        XCTAssertEqual(automataInfo.hiddenAP[1], "h2")
        XCTAssertEqual(automataInfo.hiddenAP[2], "s1")
        XCTAssertEqual(automataInfo.hiddenAP[3], "s2")
        XCTAssertEqual(automataInfo.hiddenAP.count, 4)
        
        XCTAssertEqual(automataInfo.outputs[0], "o1")
        XCTAssertEqual(automataInfo.outputs[1], "o2")
        XCTAssertEqual(automataInfo.outputs.count, 2)
        
    }
    
    
    func testSpecParsing() {
        let specOpt = readSpecificationFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/knowledge_01.kbosy")
        XCTAssert(specOpt != nil)
        let spec = specOpt!
        
        
        // Testing if JSON has been read correctly
        XCTAssertEqual(spec.inputs[0], "drive")
        XCTAssertEqual(spec.inputs[1], "indicatingRight")
        XCTAssertEqual(spec.inputs[2], "pastCrossing")
        XCTAssertEqual(spec.inputs.count, 3)
        
        XCTAssertEqual(spec.outputs[0], "go")
        XCTAssertEqual(spec.outputs.count, 1)
    }
    
    func testDotGraphParsingSingleAction() {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata_small.kbosy")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        
        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata_small.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let dotGraph = dotGraphOpt!
        
        // s0 is only initial state
        XCTAssertEqual(dotGraph.initial_states[0].name, "s0")
        XCTAssertEqual(dotGraph.initial_states.count, 1)
        
        // s0 has outgoing transitions to s1 and s0
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[0].end.name, "s1")
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[1].end.name, "s0")
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions.count, 2)
        
        // s1 has only one outgoing transition to s1
        XCTAssertEqual(dotGraph.get_state(name: "s1")!.transitions[0].end.name, "s1")
        XCTAssertEqual(dotGraph.get_state(name: "s1")!.transitions.count, 1)
        
        
        // test if SINGLE actions of transitions are parsed correctly
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[0].action[0].description, "go")
        let action2: [AP] = dotGraph.get_state(name: "s0")!.transitions[1].action
        XCTAssertEqual(action2.count, 0)
        XCTAssertEqual(dotGraph.get_state(name: "s1")!.transitions[0].action[0].description, "go")
        
        
        // test if conditions are parsed correctly
        // Test condition of s0->s1
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[0].condition.dnf[0].literals[0].description, "a")
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[0].condition.dnf[0].literals.count, 1)
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[0].condition.dnf[1].literals[0].description, "b")
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[0].condition.dnf[1].literals.count, 1)
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[0].condition.dnf[2].literals[0].description, "h")
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[0].condition.dnf[2].literals.count, 1)
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[0].condition.dnf.count, 3)
        
        // Test condition of s0->s0
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[1].condition.dnf[0].literals[0].description, "¬a")
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[1].condition.dnf[0].literals[1].description, "¬b")
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[1].condition.dnf[0].literals[2].description, "¬h")
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[1].condition.dnf[0].literals.count, 3)
        XCTAssertEqual(dotGraph.get_state(name: "s0")!.transitions[1].condition.dnf.count, 1)
        
        
        // Test condition of s1->s1
        XCTAssertEqual(dotGraph.get_state(name: "s1")!.transitions[0].condition.dnf[0].literals[0].description, "true")
        XCTAssertEqual(dotGraph.get_state(name: "s1")!.transitions[0].condition.dnf[0].literals.count, 1)
        XCTAssertEqual(dotGraph.get_state(name: "s1")!.transitions[0].condition.dnf.count, 1)
    }

}
