import XCTest

import Foundation
import LTL

@testable import Automata

class ModelCheckingTest: XCTestCase {


    func testGetKnowledgeTermsFormulas() {
        do {
            let ltlguarantee1 = try LTL.parse(fromString: "G(go -> K(F(f) -> (yes ∧ ¬go)))")
            let ltlguarantee2 = try LTL.parse(fromString: "G(F(K(F(f) -> (yes ∧ ¬go))) ∧ F(K(yes ∨ go)))")
            let ltlguarantee3 = try LTL.parse(fromString: "F(K(yes ∨ go))")
            
            
            let knowledgeTerms1 = ltlguarantee1.getAllKnowledgeTerms()
            let knowledgeTerms2 = ltlguarantee2.getAllKnowledgeTerms()
            let knowledgeTerms3 = ltlguarantee3.getAllKnowledgeTerms()
            
            XCTAssertEqual(knowledgeTerms1.count, 1)
            XCTAssertEqual(knowledgeTerms1[0].description, "K ((F (f)) -> ((yes) ∧ (¬ (go))))")
            
            XCTAssertEqual(knowledgeTerms2.count, 2)
            XCTAssertEqual(knowledgeTerms2[0].description, "K ((F (f)) -> ((yes) ∧ (¬ (go))))")
            XCTAssertEqual(knowledgeTerms2[1].description, "K ((yes) ∨ (go))")
            
            XCTAssertEqual(knowledgeTerms3.count, 1)
            XCTAssertEqual(knowledgeTerms3[0].description, "K ((yes) ∨ (go))")
            
            
            // put all knowledge Term into a set to eliminate duplicates
            let knowledgeTermSet: Set<LTL> = Set(knowledgeTerms1 + knowledgeTerms2 + knowledgeTerms3)
            XCTAssertEqual(knowledgeTermSet.count, 2)
        } catch {
            XCTAssertTrue(false, "LTL parsing error")
        }

    }
    
    func testAlgorithmicTagInsertion() {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_numberv1_knowledge.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!

        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_numberv1.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        var automata = dotGraphOpt!
        
        var tags: [String] = []
        
        let modelChecker = ModelCheckCaller()
        // Annotate algorithmically the remaining knowledgeTerms
        tags += modelChecker.generateTagsFromGuaranteesUsingMC(automata: &automata)
        
        XCTAssertEqual(tags, ["kmc1", "kmc2"])
        XCTAssertEqual(automata.guarantees[0].description, "G ((¬ (o1)) ∨ (¬ (o2)))")
        XCTAssertEqual(automata.guarantees[1].description, "F ((kmc1) ∨ (kmc2))")
        XCTAssertEqual(modelChecker.tagMapping["kmc1"]!.description, "K (one)")
        XCTAssertEqual(modelChecker.tagMapping["kmc2"]!.description, "K (two)")
    }
    
    
    func testCompleteInformationAssumptions() {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_numberv1_knowledge.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!

        let dotGraphOpt = FileParser.readDotGraphFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/automata/test_numberv1.gv", info: automataInfo)
        XCTAssert(dotGraphOpt != nil)
        var automata = dotGraphOpt!
        
        var tags: [String] = []
        
        let modelChecker = ModelCheckCaller()
        // Annotate algorithmically the remaining knowledgeTerms
        tags += modelChecker.generateTagsFromGuaranteesUsingMC(automata: &automata)
        
        let testString = modelChecker.getCompleteInformationAssumptions(automata: automata)
        
        XCTAssertEqual(testString, "G ((s0) -> ((((¬ (s1)) ∧ (¬ (s2))) ∧ (¬ (s3))) ∧ (¬ (s4)))) & G ((s1) -> ((((¬ (s0)) ∧ (¬ (s2))) ∧ (¬ (s3))) ∧ (¬ (s4)))) & G ((s2) -> ((((¬ (s0)) ∧ (¬ (s1))) ∧ (¬ (s3))) ∧ (¬ (s4)))) & G ((s3) -> ((((¬ (s0)) ∧ (¬ (s1))) ∧ (¬ (s2))) ∧ (¬ (s4)))) & G ((s4) -> ((((¬ (s0)) ∧ (¬ (s1))) ∧ (¬ (s2))) ∧ (¬ (s3)))) & G (((((s0) ∨ (s1)) ∨ (s2)) ∨ (s3)) ∨ (s4)) & s0 & G ((s0) -> (((⊤) ∧ (¬ (y1))) ∧ (¬ (y2)))) & G ((s1) -> (((one) ∧ (¬ (y1))) ∧ (¬ (y2)))) & G ((s2) -> (((two) ∧ (¬ (y1))) ∧ (¬ (y2)))) & G ((s3) -> (((one) ∧ (y1)) ∧ (¬ (y2)))) & G ((s4) -> (((two) ∧ (y2)) ∧ (¬ (y1)))) & G ((¬ (s0)) ∨ (((⊤) ∧ (X (s1))) ∨ ((⊤) ∧ (X (s2))))) & G ((¬ (s1)) ∨ (((¬ (o1)) ∧ (X (s1))) ∨ ((o1) ∧ (X (s3))))) & G ((¬ (s2)) ∨ (((¬ (o2)) ∧ (X (s2))) ∨ ((o2) ∧ (X (s4))))) & G ((¬ (s3)) ∨ ((⊤) ∧ (X (s3)))) & G ((¬ (s4)) ∨ ((⊤) ∧ (X (s4))))")
    }
}
