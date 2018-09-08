//
//  XCTestUtil.swift v.0.1.0
//  Swift4UtilTests
//
//  Created by Rudolf Farkas on 10.09.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import XCTest

extension XCTestCase {

    // wait for element to exist

    // see http://masilotti.com/xctest-waiting/
    func waitForElement(element: Any, timeout: TimeInterval) {
        let predicate = NSPredicate(format: "exists == 1")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
    }

    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval) -> XCTWaiter.Result {
        let expectation = XCTKVOExpectation(keyPath: "exists", object: element,
                                            expectedValue: true)
        return XCTWaiter().wait(for: [expectation], timeout: 5)
    }

    // wait for label to have a value

    func waitForLabelToHaveValue(_ element: XCUIElement, value: String, seconds: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "label = '\(value)'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate,
                                                    object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: seconds)
        return result == .completed
    }
}
