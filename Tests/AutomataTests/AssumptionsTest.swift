import XCTest

import Foundation

@testable import Automata

class AssumptionsTest: XCTestCase {


    func testGenerateInitialStateAssumptions() {

        var automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_automata_small.json")
        XCTAssert(automataInfoOpt != nil)
        var automataInfo = automataInfoOpt!

        XCTAssertEqual(automataInfo.guarantees.count, 1)
        XCTAssertEqual(automataInfo.guarantees[0].description, "F (go)")

        var dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_automata_small_kripke.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        var automata = dotGraphOpt!

        var test_value = AssumptionsGenerator.internal_generateInitialStateAssumptions(auto: automata)

        XCTAssertEqual(test_value.description, "s0")

        automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_automata_small.json")
        XCTAssert(automataInfoOpt != nil)
        automataInfo = automataInfoOpt!

        XCTAssertEqual(automataInfo.guarantees.count, 1)
        XCTAssertEqual(automataInfo.guarantees[0].description, "F (go)")

        dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_automata_small_kripke_multiple-initialStates.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        automata = dotGraphOpt!

        test_value = AssumptionsGenerator.internal_generateInitialStateAssumptions(auto: automata)

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

        let test_value = AssumptionsGenerator.internal_generatePossibleStateAssumptions(auto: automata)
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

        let test_value = AssumptionsGenerator.internal_generatePossibleStateAssumptions(auto: automata)
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

        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_env_01_fixedTransitions.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        automata.reduceToObservablePart()
        automata.finalize()

        let test_value = AssumptionsGenerator.internal_generateStateAPsAssumptions(auto: automata, tagsInAPs: true)
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

        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_env_01_fixedTransitions.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        automata.finalize()

        let test_value = AssumptionsGenerator.internal_generateTransitionAssumptions(auto: automata)

        // 1 condition for each transition
        XCTAssertEqual(test_value.count, 4)

        XCTAssertTrue(test_value[0].description == "G ((¬ (s0)) ∨ (((request) ∧ (X (s1))) ∨ ((¬ (request)) ∧ (X (s0)))))" || test_value[0].description == "G ((¬ (s0)) ∨ (((¬ (request)) ∧ (X (s0))) ∨ ((request) ∧ (X (s1)))))")
        XCTAssertEqual(test_value[1].description, "G ((¬ (s1)) ∨ ((⊤) ∧ (X (s1))))")
        XCTAssertTrue(test_value[2].description == "G ((¬ (s2)) ∨ (((⊤) ∧ (X (s2))) ∨ ((⊤) ∧ (X (s3)))))" || test_value[2].description == "G ((¬ (s2)) ∨ (((⊤) ∧ (X (s3))) ∨ ((⊤) ∧ (X (s2)))))")
        XCTAssertEqual(test_value[3].description, "G ((¬ (s3)) ∨ ((⊤) ∧ (X (s3))))")
    }

    func testGetAutomataInputAPs() {

        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_env_01.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!

        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_env_01_fixedTransitions.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!

        let completeInfoAssumptions = AssumptionsGenerator.getAutomataInputAPs(auto: automata, tags: [])

        // 1 condition for each transition
        XCTAssertEqual(completeInfoAssumptions.count, 9)
        XCTAssertEqual(completeInfoAssumptions[0], "grant")
        XCTAssertEqual(completeInfoAssumptions[1], "h1")
        XCTAssertEqual(completeInfoAssumptions[2], "h2")
        XCTAssertEqual(completeInfoAssumptions[3], "i1")
        XCTAssertEqual(completeInfoAssumptions[4], "i2")
        XCTAssertEqual(completeInfoAssumptions[5], "s0")
        XCTAssertEqual(completeInfoAssumptions[6], "s1")
        XCTAssertEqual(completeInfoAssumptions[7], "s2")
        XCTAssertEqual(completeInfoAssumptions[8], "s3")
        
        automata.reduceToObservablePart()
        
        let incompleteInfoAssumptions = AssumptionsGenerator.getAutomataInputAPs(auto: automata, tags: [])
        
        // 1 condition for each transition
        XCTAssertEqual(incompleteInfoAssumptions.count, 7)
        XCTAssertEqual(incompleteInfoAssumptions[0], "grant")
        XCTAssertEqual(incompleteInfoAssumptions[1], "i1")
        XCTAssertEqual(incompleteInfoAssumptions[2], "i2")
        XCTAssertEqual(incompleteInfoAssumptions[3], "s0")
        XCTAssertEqual(incompleteInfoAssumptions[4], "s1")
        XCTAssertEqual(incompleteInfoAssumptions[5], "s2")
        XCTAssertEqual(incompleteInfoAssumptions[6], "s3")
    }

    func testGetAutomataOutputAPs() {

        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_env_01.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!

        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_env_01_fixedTransitions.gv", info: automataInfo)
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

        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_env_01_fixedTransitions.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        let automata = dotGraphOpt!
        automata.finalize()

        let test_value = AssumptionsGenerator.generateAutomataAssumptions(auto: automata, tags: [], tagsInAPs: true)

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
        automata.reduceToObservablePart()
        automata.finalize()

        let test_value = AssumptionsGenerator.generateAutomataAssumptions(auto: automata, tags: [], tagsInAPs: true)

        // 1 condition for each transition
        XCTAssertEqual(test_value.count, 14)
        XCTAssertEqual(test_value[0].description, "s0")
        XCTAssertEqual(test_value[1].description, "G ((s0) -> (((¬ (s1)) ∧ (¬ (s2))) ∧ (¬ (s3))))")
        XCTAssertEqual(test_value[2].description, "G ((s1) -> (((¬ (s0)) ∧ (¬ (s2))) ∧ (¬ (s3))))")
        XCTAssertEqual(test_value[3].description, "G ((s2) -> (((¬ (s0)) ∧ (¬ (s1))) ∧ (¬ (s3))))")
        XCTAssertEqual(test_value[4].description, "G ((s3) -> (((¬ (s0)) ∧ (¬ (s1))) ∧ (¬ (s2))))")
        XCTAssertEqual(test_value[5].description, "G ((((s0) ∨ (s1)) ∨ (s2)) ∨ (s3))")

        
        XCTAssertEqual(test_value[6].description, "G ((s0) -> ((⊤) ∧ (¬ (r1))))")
        XCTAssertEqual(test_value[7].description, "G ((s1) -> ((r1) ∧ (⊤)))")
        XCTAssertEqual(test_value[8].description, "G ((s2) -> ((r1) ∧ (⊤)))")
        XCTAssertEqual(test_value[9].description, "G ((s3) -> ((⊤) ∧ (¬ (r1))))")
        XCTAssertTrue(test_value[10].description == "G ((¬ (s0)) ∨ (((⊤) ∧ (X (s0))) ∨ ((⊤) ∧ (X (s1)))))" || test_value[10].description == "G ((¬ (s0)) ∨ (((⊤) ∧ (X (s1))) ∨ ((⊤) ∧ (X (s0)))))")
        XCTAssertTrue(test_value[11].description == "G ((¬ (s1)) ∨ (((¬ (g1)) ∧ (X (s1))) ∨ ((g1) ∧ (X (s2)))))" || test_value[11].description == "G ((¬ (s1)) ∨ (((g1) ∧ (X (s2))) ∨ ((¬ (g1)) ∧ (X (s1)))))")
        XCTAssertTrue(test_value[12].description == "G ((¬ (s2)) ∨ (((¬ (g1)) ∧ (X (s2))) ∨ ((g1) ∧ (X (s3)))))" || test_value[12].description == "G ((¬ (s2)) ∨ (((g1) ∧ (X (s3))) ∨ ((¬ (g1)) ∧ (X (s2)))))")
        XCTAssertEqual(test_value[13].description, "G ((¬ (s3)) ∨ ((⊤) ∧ (X (s1))))")

        // TODO maybe complete this test here with different input so its not redudant with previous tests of submethods
    }
}
