//
//  ManagedLocalMovie+CoreDataClass.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 27/05/22.
//
//

import Foundation
import CoreData


public class ManagedLocalMovie: NSManagedObject {
    @NSManaged public var genreIds: NSObject?
    @NSManaged public var id: Int64
    @NSManaged public var overview: String
    @NSManaged public var popularity: Double
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String
    @NSManaged public var title: String
    @NSManaged public var voteAverage: Double
    @NSManaged public var voteCount: Int64
    @NSManaged public var movieRoot: ManagedLocalMovieRoot?
    
    static func movie(from localMovie: LocalMovie, in context: NSManagedObjectContext) -> ManagedLocalMovie {
        let managed = ManagedLocalMovie(context: context)
        managed.id = Int64(localMovie.id)
        managed.genreIds = localMovie.genreIds as NSObject
        managed.overview = localMovie.overview
        managed.popularity = localMovie.popularity
        managed.posterPath = localMovie.posterPath
        managed.releaseDate = localMovie.releaseDate
        managed.title = localMovie.title
        managed.voteAverage = localMovie.voteAverage
        managed.voteCount = Int64(localMovie.voteCount)
        return managed
    }
    
    func toLocal() -> LocalMovie {
        return LocalMovie(posterPath: self.posterPath,
                          overview: self.overview,
                          releaseDate: self.releaseDate,
                          genreIds: self.genreIds as! [Int],
                          id: Int(self.id),
                          title: self.title,
                          popularity: self.popularity,
                          voteCount: Int(self.voteCount),
                          voteAverage: self.voteAverage)
    }
}
