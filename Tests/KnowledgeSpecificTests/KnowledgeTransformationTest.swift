import XCTest

import Foundation

@testable import Automata
@testable import Specification

class KnowledgeTransformationTest: XCTestCase {
    
    func testEAHyperAnnotation() {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_numberv1_knowledge.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!

        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_numberv1.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        var automata = dotGraphOpt!
        
        var tags: [String] = []
        
        let modelChecker = ModelCheckCaller(preexistingTags: [])
        // Annotate algorithmically the remaining knowledgeTerms
        tags = modelChecker.generateTagsFromGuaranteesUsingMC(automata: &automata)
        
        let kbsc = KBSConstructor(input_automata: automata)

        let obsAutomata = kbsc.run()
        obsAutomata.finalize()

        let spec = SynthesisSpecification(automata: obsAutomata, tags: tags)
        
        // test guarantees
        XCTAssertEqual(spec.guarantees[0].description, "G ((¬ (o1)) ∨ (¬ (o2)))")
        XCTAssertEqual(spec.guarantees[1].description, "F ((kmc1) ∨ (kmc2))")
        
        var assumptions: [String] = []
        for assumption in spec.assumptions {
            assumptions.append(assumption.description)
        }
        
        // 6 state assumptions (no other states at the same time)
        // +1 global state assumption (one state always holds)
        // +1 initial state assumption
        // +6 transition assumptions for each state
        // +6 AP assumptions for each state
        // -------------------------
        // 20 Assumptions
        XCTAssertEqual(spec.assumptions.count, 20)
        
        // TODO: think about how to test exact values of assumptions (nondeterministic ordering makes this hard)  
    }

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
        if !spec.applyTransformationRules() {
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
    
    
    
    func testGraphGivenRulesTransformation01() {
        
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_numberv1+rule.json")
        XCTAssertTrue(automataInfoOpt != nil, "something went wrong while reading automataInfoFile")
        var automataInfo = automataInfoOpt!
        
        let tagMappingOpt = automataInfo.getTagToCandidateStatesMapping()

        let automataOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_numberv1.gv", info: automataInfo)
        XCTAssertTrue(automataOpt != nil, "something went wrong while reading automata file")
        let automata = automataOpt!
        
        var tags: [String] = []
        if tagMappingOpt != nil {
            // case for mapping from tags to candidate sates exists
            var candidateStateNames: [[String]] = []
            (tags, candidateStateNames) = tagMappingOpt!
            automata.addTagsToCandidateStates(tags: tags, candidateStateNames: candidateStateNames)
        } else {
            // TODO: annotate algorithmically with model checking if tags were not given by user
        }

        let kbsc = KBSConstructor(input_automata: automata)

        let obsAutomata = kbsc.run()
        obsAutomata.finalize()

        let spec = SynthesisSpecification(automata: obsAutomata, tags: tags)
        
        XCTAssertTrue(spec.inputs.contains("k0"))
        XCTAssertTrue(spec.inputs.contains("k1"))
        
        // test if candidates states tags are forwarded correctly
        XCTAssertEqual(spec.assumptions[8].description, "G ((s0) -> (((((⊤) ∧ (¬ (k0))) ∧ (¬ (k1))) ∧ (¬ (y1))) ∧ (¬ (y2))))")
        XCTAssertEqual(spec.assumptions[9].description, "G ((s1) -> ((((k0) ∧ (¬ (k1))) ∧ (¬ (y1))) ∧ (¬ (y2))))")
        XCTAssertEqual(spec.assumptions[10].description, "G ((s1s2) -> (((((⊤) ∧ (¬ (k0))) ∧ (¬ (k1))) ∧ (¬ (y1))) ∧ (¬ (y2))))")
        XCTAssertEqual(spec.assumptions[11].description, "G ((s2) -> ((((k1) ∧ (¬ (k0))) ∧ (¬ (y1))) ∧ (¬ (y2))))")
        XCTAssertEqual(spec.assumptions[12].description, "G ((s3) -> ((((y1) ∧ (k0)) ∧ (¬ (k1))) ∧ (¬ (y2))))")
        XCTAssertEqual(spec.assumptions[13].description, "G ((s4) -> ((((y2) ∧ (k1)) ∧ (¬ (k0))) ∧ (¬ (y1))))")
        
        //test if guarantees have been adjusted correctly
        
        XCTAssertEqual(spec.guarantees[0].description, "G ((¬ (o1)) ∨ (¬ (o2)))")
        XCTAssertEqual(spec.guarantees[1].description, "F ((k0) ∨ (k1))")
    }

}
