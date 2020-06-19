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
        
        let modelChecker = ModelCheckCaller(preexistingTags: [])
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
        
        let modelChecker = ModelCheckCaller(preexistingTags: [])
        // Annotate algorithmically the remaining knowledgeTerms
        tags += modelChecker.generateTagsFromGuaranteesUsingMC(automata: &automata)
        
        let testString = modelChecker.getEAHyperAssumptions(automata: automata)
        
        XCTAssertEqual(testString, "G((s0_p) -> ((((!(s1_p)) & (!(s2_p))) & (!(s3_p))) & (!(s4_p)))) & G((s1_p) -> ((((!(s0_p)) & (!(s2_p))) & (!(s3_p))) & (!(s4_p)))) & G((s2_p) -> ((((!(s0_p)) & (!(s1_p))) & (!(s3_p))) & (!(s4_p)))) & G((s3_p) -> ((((!(s0_p)) & (!(s1_p))) & (!(s2_p))) & (!(s4_p)))) & G((s4_p) -> ((((!(s0_p)) & (!(s1_p))) & (!(s2_p))) & (!(s3_p)))) & G(((((s0_p) | (s1_p)) | (s2_p)) | (s3_p)) | (s4_p)) & s0_p & G((s0_p) -> (((true_p) & (!(y1_p))) & (!(y2_p)))) & G((s1_p) -> (((one_p) & (!(y1_p))) & (!(y2_p)))) & G((s2_p) -> (((two_p) & (!(y1_p))) & (!(y2_p)))) & G((s3_p) -> (((one_p) & (y1_p)) & (!(y2_p)))) & G((s4_p) -> (((two_p) & (y2_p)) & (!(y1_p)))) & G((!(s0_p)) | (((true_p) & (X(s1_p))) | ((true_p) & (X(s2_p))))) & G((!(s1_p)) | (((!(o1_p)) & (X(s1_p))) | ((o1_p) & (X(s3_p))))) & G((!(s2_p)) | (((!(o2_p)) & (X(s2_p))) | ((o2_p) & (X(s4_p))))) & G((!(s3_p)) | ((true_p) & (X(s3_p)))) & G((!(s4_p)) | ((true_p) & (X(s4_p))))")
    }
    
    
    public func testGetEAHyperFormat() {
        do {
            let ltlguarantee1 = try LTL.parse(fromString: "G(go -> K(G(f) -> (yes ∧ ¬go)))")
            let ltlguarantee2 = try LTL.parse(fromString: "G(F(K(G(f) -> (yes ∧ ¬go))) ∧ F(G(yes ∨ go)))")
            let ltlguarantee3 = try LTL.parse(fromString: "F(G(yes ∨ go))")
            
            XCTAssertEqual(ltlguarantee1.getEAHyperFormat(), "G((go_p) -> (K((G(f_p)) -> ((yes_p) & (!(go_p))))))")
            XCTAssertEqual(ltlguarantee2.getEAHyperFormat(), "G((F(K((G(f_p)) -> ((yes_p) & (!(go_p)))))) & (F(G((yes_p) | (go_p)))))")
            XCTAssertEqual(ltlguarantee3.getEAHyperFormat(), "F(G((yes_p) | (go_p)))")
        } catch {
            XCTAssertTrue(false, "LTL parsing error")
        }
    }
}
