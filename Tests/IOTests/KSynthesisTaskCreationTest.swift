import XCTest
import Foundation

@testable import Automata
@testable import Specification

class KSynthesisTaskCreationTest: XCTestCase {
    
    func testKSynthesisTaskInit() {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/info_file/test_automata.json")
        XCTAssert(automataInfoOpt != nil)
        let automataInfo = automataInfoOpt!
        
        
        let globalAPList = APList()
        // TODO: add automata creation here whenever its implemented
        let aut = Automata(info: automataInfo)
        
        let synthesisTask = KSynthesisTask(automata: aut, observableAP: automataInfo.observableAP, hiddenAP: automataInfo.hiddenAP, outputs: automataInfo.outputs,  apList: globalAPList)
        
        XCTAssertEqual(synthesisTask.observableAP[0].id, "y1")
        XCTAssertEqual(synthesisTask.observableAP[0].obs, true)
        XCTAssertEqual(synthesisTask.observableAP[0].output, false)
    }
}
