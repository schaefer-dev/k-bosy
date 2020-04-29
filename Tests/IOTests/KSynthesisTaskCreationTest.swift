import XCTest
import Foundation

@testable import Automata
@testable import Specification

class KSynthesisTaskCreationTest: XCTestCase {
    
    func testKSynthesisTaskInit() {
        let automataInfoOpt = readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata.kbosy")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        
        let globalAPList = APList()
        // TODO: add automata creation here whenever its implemented
        let aut = Automata()
        
        let synthesisTask = KSynthesisTask(automata: aut, observableAP: automataInfo.observableAP, hiddenAP: automataInfo.hiddenAP, outputs: automataInfo.outputs, initialStates: automataInfo.initialStates, apList: globalAPList)
        
        XCTAssertEqual(synthesisTask.observableAP[0].id, "y1")
        XCTAssertEqual(synthesisTask.observableAP[0].obs, true)
        XCTAssertEqual(synthesisTask.observableAP[0].output, false)
    }
}
