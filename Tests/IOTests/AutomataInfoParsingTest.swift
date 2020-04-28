import XCTest

import Foundation

@testable import Automata


class AutomataInfoParsingTest: XCTestCase {
    
    
    func testAutomataInfoParsing() {
            if #available(OSX 10.11, *) {
                /* System requirements passed */
                let jsonURL = URL(fileURLWithPath: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/xcode_tests/test_automata.kbosy")
                print("loading json from path: " + jsonURL.path)


                /* try to read input JSON File */
                do {
                    let jsonData =  try Data(contentsOf: jsonURL)
                    print("File data read.")
                    // jsonData can be used
                    let decoder = JSONDecoder()
                    do {
                        var automataInfo = try decoder.decode(AutomataInfo.self, from: jsonData)
                        print("Decoding completed.")
                        
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
                        
     
                    } catch {
                        /* failed to decode content of jsonData */
                        XCTAssertTrue(false, "Test Error during encoding" + error.localizedDescription)
                    }
                } catch {
                    /* failed to read data from jsonURL */
                    XCTAssertTrue(false, "loading of jsonData error...")
                }
            } else {
                /* failed System Requirements */
                XCTAssertTrue(false, "Requires at least macOS 10.11")
                exit(EXIT_FAILURE)
            }
        
    }

}
