//
//  MovieEntity+CoreDataProperties.swift
//  
//
//  Created by mac on 07/12/2024.
//
//

import Foundation
import CoreData


extension MovieEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieEntity> {
        return NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var posterImage: String?
    @NSManaged public var voteAverage: Double

}
