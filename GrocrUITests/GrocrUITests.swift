//
//  GrocrUITests.swift
//  GrocrUITests
//
//  Created by Rudolf Farkas on 08.09.18.
//  Copyright © 2018 com.rudifa. All rights reserved.
//

import XCTest

class GrocrUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app.launchArguments = ["XCUITests"]

        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialUserLogout() {
        waitForElement(element: app.staticTexts["Grocr"], timeout: 5)
        waitForElement(element: app.textFields["Email"], timeout: 5)
    }

    func testLogin() {
        print(app.debugDescription)

        waitForElement(element: app.textFields["Email"], timeout: 5)

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("fred@pajot.ch")

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("freddie")

        app.buttons["Login"].tap()
        waitForElement(element: app.navigationBars["Grocery List"], timeout: 6)
        sleep(5)
    }
}
