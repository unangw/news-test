//
//  NewsUITests.swift
//  NewsUITests
//
//  Created by BTS.id on 02/03/26.
//

import XCTest

final class NewsUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testMainScreenShowsCategoryCards() throws {
        XCTAssertTrue(app.staticTexts["General"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Business"].exists)
        XCTAssertTrue(app.staticTexts["Entertainment"].exists)
    }

    @MainActor
    func testTapCategoryNavigatesToSourcesScreen() throws {
        let generalCategory = app.staticTexts["General"]
        XCTAssertTrue(generalCategory.waitForExistence(timeout: 5))

        generalCategory.tap()

        XCTAssertTrue(app.staticTexts["Sources"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["Search source here..."].exists)
    }

    @MainActor
    func testSourcesScreenBackButtonReturnsToMain() throws {
        let category = app.staticTexts["General"]
        XCTAssertTrue(category.waitForExistence(timeout: 5))
        category.tap()
        XCTAssertTrue(app.staticTexts["Sources"].waitForExistence(timeout: 5))

        let backButton = app.otherElements["nav_back_button"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        XCTAssertTrue(app.staticTexts["General"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSourcesScreenShowsSearchPlaceholder() throws {
        let category = app.staticTexts["General"]
        XCTAssertTrue(category.waitForExistence(timeout: 5))
        category.tap()

        let searchField = app.textFields["Search source here..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
    }

    @MainActor
    func testMultipleCategoryTapsStillPresentSourcesScreen() throws {
        let firstCategory = app.staticTexts["Business"]
        XCTAssertTrue(firstCategory.waitForExistence(timeout: 5))
        firstCategory.tap()
        XCTAssertTrue(app.staticTexts["Sources"].waitForExistence(timeout: 5))

        let backButton = app.otherElements["nav_back_button"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
        XCTAssertTrue(app.staticTexts["General"].waitForExistence(timeout: 5))

        let secondCategory = app.staticTexts["Health"]
        XCTAssertTrue(secondCategory.waitForExistence(timeout: 5))
        secondCategory.tap()
        XCTAssertTrue(app.staticTexts["Sources"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
