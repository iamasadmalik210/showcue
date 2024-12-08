//
//  CoreDataHelper.swift
//  ShowCue
//
//  Created by mac on 07/12/2024.
//

import Foundation
import CoreData
import UIKit

protocol CoreDataHelperProtocol {
    func saveMovies(_ movies: [Movie])
    func fetchMovies() -> [Movie]
}


class CoreDataHelper {
    static let shared = CoreDataHelper()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MovieModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data: \(error)")
            }
        }
    }
}

class MockCoreDataHelper: CoreDataHelperProtocol {
     var mockMovies: [Movie] = []
    
    func saveMovies(_ movies: [Movie]) {
        // Simulate saving movies
        mockMovies = movies
    }

    func fetchMovies() -> [Movie] {
        // Simulate fetching movies
        return mockMovies
    }
}
