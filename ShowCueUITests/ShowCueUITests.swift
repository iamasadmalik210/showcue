//
//  ShowCueUITests.swift
//  ShowCueUITests
//
//  Created by mac on 08/12/2024.
//

import XCTest
@testable import ShowCue
final class ShowCueUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    func testCollectionViewLoads() {
        let app = XCUIApplication()
        app.launch()

        let collectionView = app.collectionViews["moviesCollectionView"] // Use the Accessibility Identifier
        XCTAssertTrue(collectionView.exists, "Collection View should exist")
        XCTAssertTrue(collectionView.cells.count > 0, "Collection View should have cells")
    }

    func testMovieDetailNavigation() {
        let app = XCUIApplication()
        app.launch()

        // Check collection view
        let collectionView = app.collectionViews["moviesCollectionView"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 10), "Collection View should exist")

        // Check first cell
        let firstCell = collectionView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First cell should exist")

        // Tap the first cell
        firstCell.tap()

        // Verify detail view elements
        let detailTitle = app.staticTexts["movieDetailTitleLabel"]
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 5), "Movie Title should appear on detail screen")

        let ratingLabel = app.staticTexts["movieRatingLabel"]
        XCTAssertTrue(ratingLabel.exists, "Rating label should appear on detail screen")

        let movieDescription = app.textViews["movieDescriptionTextView"]
        XCTAssertTrue(movieDescription.exists, "Description text should appear on detail screen")

        let bannerImage = app.images["movieBannerImageView"]
        XCTAssertTrue(bannerImage.exists, "Banner image should appear on detail screen")

        let posterImage = app.images["moviePosterImageView"]
        XCTAssertTrue(posterImage.exists, "Poster image should appear on detail screen")

        let criticsLabel = app.staticTexts["movieCriticsLabel"]
        XCTAssertTrue(criticsLabel.exists, "Critics label should appear on detail screen")

        let rateThisLabel = app.staticTexts["movieRateThisLabel"]
        XCTAssertTrue(rateThisLabel.exists, "Rate This label should appear on detail screen")
        
        // Check collection view
        let genrecCollectionView = app.collectionViews["genreCollectionView"]
        XCTAssertTrue(genrecCollectionView.waitForExistence(timeout: 10), "Collection View should exist")

        // Check first cell
        let genreFirstCell = genrecCollectionView.cells.element(boundBy: 0)
        XCTAssertTrue(genreFirstCell.waitForExistence(timeout: 5), "First cell should exist")

    }



}
