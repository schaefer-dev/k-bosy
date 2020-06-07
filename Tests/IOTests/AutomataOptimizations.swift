import XCTest

@testable import Automata
@testable import Specification

class AutomataOptimizations: XCTestCase {
    
    func testAutomataFinalize () {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_nas_01.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        
        let automataOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_nas_01.gv", info: automataInfo)
        XCTAssert(automataOpt != nil)
        
        let automata = automataOpt!
        
        XCTAssertEqual(automata.get_state(name: "s0")!.propositions.count, 1)
        XCTAssertEqual(automata.get_state(name: "s1")!.propositions.count, 2)
        XCTAssertEqual(automata.get_state(name: "s2")!.propositions.count, 2)
        XCTAssertEqual(automata.get_state(name: "s3")!.propositions.count, 1)
        
        
        // Make sure that APs in states are set correctly
        
        automata.reduceToObservablePart()
        XCTAssertEqual(automata.get_state(name: "s0")!.propositions.count, 0)
        XCTAssertEqual(automata.get_state(name: "s1")!.propositions.count, 1)
        XCTAssertEqual(automata.get_state(name: "s1")!.propositions[0].id, "r1")
        XCTAssertEqual(automata.get_state(name: "s2")!.propositions.count, 1)
        XCTAssertEqual(automata.get_state(name: "s2")!.propositions[0].id, "r1")
        XCTAssertEqual(automata.get_state(name: "s3")!.propositions.count, 0)
        
        automata.finalize()
        XCTAssertEqual(automata.get_state(name: "s0")!.propositions.count, 0)
        XCTAssertEqual(automata.get_state(name: "s1")!.propositions.count, 1)
        XCTAssertEqual(automata.get_state(name: "s1")!.propositions[0].id, "r1")
        XCTAssertEqual(automata.get_state(name: "s2")!.propositions.count, 1)
        XCTAssertEqual(automata.get_state(name: "s2")!.propositions[0].id, "r1")
        XCTAssertEqual(automata.get_state(name: "s3")!.propositions.count, 0)
        
        
        
        
        // Make sure that transitions are translated correctly into their bitset form
        
        XCTAssertEqual(automata.get_state(name: "s0")!.transitions.count, 2)
        XCTAssertEqual(automata.get_state(name: "s1")!.transitions.count, 2)
        XCTAssertEqual(automata.get_state(name: "s2")!.transitions.count, 2)
        XCTAssertEqual(automata.get_state(name: "s3")!.transitions.count, 1)
        
        XCTAssertEqual(automata.get_state(name: "s0")!.transitions[0].condition.bitset_representation.get_formula_string(), "(true)")
        XCTAssertEqual(automata.get_state(name: "s0")!.transitions[1].condition.bitset_representation.get_formula_string(), "(true)")
        
        XCTAssertEqual(automata.get_state(name: "s1")!.transitions[0].condition.bitset_representation.get_formula_string(), "(¬g1)")
        XCTAssertEqual(automata.get_state(name: "s1")!.transitions[1].condition.bitset_representation.get_formula_string(), "(g1)")
        
        XCTAssertEqual(automata.get_state(name: "s2")!.transitions[0].condition.bitset_representation.get_formula_string(), "(¬g1)")
        XCTAssertEqual(automata.get_state(name: "s2")!.transitions[1].condition.bitset_representation.get_formula_string(), "(g1)")
        
        XCTAssertEqual(automata.get_state(name: "s3")!.transitions[0].condition.bitset_representation.get_formula_string(), "(true)")
        
    }
}
