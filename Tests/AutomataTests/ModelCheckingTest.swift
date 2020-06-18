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
            
            let knowledgeTermSet: Set<LTL> = Set(knowledgeTerms1 + knowledgeTerms2 + knowledgeTerms3)
            XCTAssertEqual(knowledgeTermSet.count, 2)
        } catch {
            XCTAssertTrue(false, "LTL parsing error")
        }

    }
}
