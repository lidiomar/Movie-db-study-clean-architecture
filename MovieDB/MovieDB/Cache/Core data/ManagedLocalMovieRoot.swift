//
//  ManagedLocalMovieRoot+CoreDataClass.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 27/05/22.
//
//

import Foundation
import CoreData


public class ManagedLocalMovieRoot: NSManagedObject {
    @NSManaged public var page: Int64
    @NSManaged public var cache: ManagedCache
    @NSManaged public var movies: NSOrderedSet
    
    static func movieRoot(from localMovieRoot: LocalMovieRoot, in context: NSManagedObjectContext) -> ManagedLocalMovieRoot {
        let managed = ManagedLocalMovieRoot(context: context)
        managed.page = Int64(localMovieRoot.page)
        managed.movies = NSOrderedSet(array: localMovieRoot.results.map {
            return ManagedLocalMovie.movie(from: $0, in: context)
        })
        return managed
    }
    
    func toLocal() -> LocalMovieRoot {
        return LocalMovieRoot(page: Int(self.page), results: self.movies.map { ($0 as! ManagedLocalMovie).toLocal() })
    }

}
