import XCTest

import Foundation

@testable import Automata

class KBSCTest: XCTestCase {

    func testGetObservableAPList() {
        let globalAPList = APList()

        // Create Sample APs
        _ = AP(name: "test1", observable: true, list: globalAPList)
        _ = AP(name: "test2", observable: true, list: globalAPList)
        _ = AP(name: "test3", observable: false, list: globalAPList)
        _ = AP(name: "test4", observable: true, list: globalAPList)
        _ = AP(name: "testOut", observable: false, list: globalAPList, output: true)

        let obsAPList = KBSCUtils.getObservableAPList(inputList: globalAPList)

        let obs_APs = obsAPList.get_allAPs()
        XCTAssertEqual(obs_APs.count, 4)
        XCTAssertTrue(obsAPList.lookupAP(apName: "test1") != nil, "test1 should have been contained because observable AP")
        XCTAssertTrue(obsAPList.lookupAP(apName: "test2") != nil, "test2 should have been contained because observable AP")
        XCTAssertTrue(obsAPList.lookupAP(apName: "test3") == nil, "test3 should not have been contained because unobservable AP")
        XCTAssertTrue(obsAPList.lookupAP(apName: "test4") != nil, "test4 should have been contained because observable AP")
        XCTAssertTrue(obsAPList.lookupAP(apName: "testOut") != nil, "testOut should have been contained because output AP")
    }

}
