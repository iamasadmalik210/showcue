//
//  ShowCueUnitTests.swift
//  ShowCueUnitTests
//
//  Created by mac on 08/12/2024.
//

import XCTest
import CoreData
@testable import ShowCue

final class ShowCueUnitTests: XCTestCase {

    var viewController: ViewController!
    var mockNetworkManager: MockNetworkManager!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        // Setup ViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        viewController.loadViewIfNeeded()

        // Setup Mocks
        mockNetworkManager = MockNetworkManager()
        NetworkManager.shared = mockNetworkManager

        // Setup Core Data
        let container = NSPersistentContainer(name: "ShowCue")
        container.loadPersistentStores { _, error in
            if let error = error {
                XCTFail("Failed to set up Core Data stack: \(error)")
            }
        }
        context = container.viewContext
    }

    func insertMockCoreDataMovies() {
        let movieEntity = MovieEntity(context: context)
        movieEntity.id = 1
        movieEntity.title = "Core Data Movie"
        movieEntity.posterImage = "/coredata.jpg"

        do {
            try context.save()
        } catch {
            XCTFail("Failed to save mock movie to Core Data: \(error)")
        }
    }

    func testFetchMoviesFromCoreData() {
        // Insert mock data into Core Data
        insertMockCoreDataMovies()

        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        do {
            let storedMovies = try context.fetch(fetchRequest)
            let movies = storedMovies.map { $0.toMovie() }  // Convert to Movie using the toMovie() method
            XCTAssertEqual(movies.count, 1, "Core Data should contain one movie")
            XCTAssertEqual(movies[0].title, "Core Data Movie", "Title should match mock data")
        } catch {
            XCTFail("Failed to fetch movies from Core Data: \(error)")
        }
    }

    func testFetchMoviesSuccess() {
        let mockMovies = [
            Movie(
                adult: false,
                backdropPath: "/test_backdrop.jpg",
                genreIDs: [12, 14],
                id: 1,
                originalLanguage: "en",
                originalTitle: "Test Original Title",
                overview: "Test Overview",
                popularity: 10.5,
                posterPath: "/test.jpg",
                releaseDate: "2024-12-06",
                title: "Test Movie",
                video: false,
                voteAverage: 7.5,
                voteCount: 100
            )
        ]

        mockNetworkManager.mockResult = .success(MoviesResponse(page: 1, results: mockMovies, total_pages: 1))

        viewController.fetchMovies(page: 1)

        XCTAssertFalse(viewController.isFetching, "Fetching should be set to false after API call")
        XCTAssertEqual(viewController.popularMovies.count, mockMovies.count, "Movies count should match mock data")
    }

    func testFetchMoviesFailure() {
        mockNetworkManager.mockResult = .failure(NetworkError.invalidURL)

        viewController.fetchMovies(page: 1)

        XCTAssertFalse(viewController.isFetching, "Fetching should be set to false after API call failure")
        XCTAssertEqual(viewController.popularMovies.count, 0, "Movies count should remain 0 on failure")
    }
    
    
}
extension MovieEntity {
    // Mapping MovieEntity to Movie
    func toMovie() -> Movie {
        return Movie(
            adult: false, // Or set to some default value
            backdropPath: nil, // Set as nil or an empty string if not needed
            genreIDs: [], // Empty array if not needed
            id: Int(self.id),
            originalLanguage: "", // Set to empty string if not available
            originalTitle: "", // Set to empty string if not available
            overview: "", // Set to empty string if not available
            popularity: 0.0, // Set to 0 or any default value
            posterPath: self.posterImage, // Use the existing property
            releaseDate: "", // Set to empty string if not available
            title: self.title ?? "", // Use title from Core Data
            video: false, // Set to false or a default value
            voteAverage: self.voteAverage, // Use the existing property
            voteCount: 0 // Set to 0 or any default value
        )
    }
}
