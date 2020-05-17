import XCTest

import Foundation

@testable import Automata
@testable import Specification

class KnowledgeTransformationTest: XCTestCase {
    
    
    func testTransformationKnowledge01() {
        let specOpt = readSpecificationFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/kltl/knowledge_01.kbosy")
        XCTAssert(specOpt != nil)
        var spec = specOpt!
        
        
        // Make sure json has been read
        XCTAssertEqual(spec.inputs[0], "drive")
        XCTAssertEqual(spec.inputs[1], "indicatingRight")
        XCTAssertEqual(spec.inputs[2], "pastCrossing")
        XCTAssertEqual(spec.inputs.count, 3)
        
        XCTAssertEqual(spec.outputs[0], "go")
        XCTAssertEqual(spec.outputs.count, 1)
        
        /* Apply transformation rules that are contained in the input file.*/
        if !spec.applyTransformationRules(){
            print("ERROR: Transformation Rules could not be applied.")
            exit(EXIT_FAILURE)
        }
        
        print("Guarantees after transformation rules:")
        for g in spec.guarantees {
            print(g.description)
        }
        
        XCTAssertEqual(spec.guarantees[0].description, "F (go)")
        XCTAssertEqual(spec.guarantees[1].description, "G ((go) -> ((indicatingRight) ∨ (pastCrossing)))")
        
    }

}
