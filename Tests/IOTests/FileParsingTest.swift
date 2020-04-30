import XCTest

import Foundation

@testable import Automata
@testable import Specification


class FileParsingTest: XCTestCase {
    
    
    func testAutomataInfoParsing() {
        let automataInfoOpt = readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata.kbosy")
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
        
        XCTAssertEqual(automataInfo.initialStates[0], "s1")
        XCTAssertEqual(automataInfo.initialStates[1], "s2")
        XCTAssertEqual(automataInfo.initialStates.count, 2)
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
    
    func testDotGraphParsing() {
        let dotGraphOpt = readSpecificationFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata.gv")
        XCTAssert(dotGraphOpt != nil)
        let dotGraph = dotGraphOpt!
        
        
        // Testing if JSON has been read correctly
        
    }

}
