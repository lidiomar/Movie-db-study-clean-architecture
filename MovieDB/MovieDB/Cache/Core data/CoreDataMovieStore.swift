//
//  CoreDataMovieStore.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 27/05/22.
//

import Foundation
import CoreData

public class CoreDataMovieStore: MovieStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "Movie", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCache(completion: @escaping (Error?) -> Void) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(movieRoot: LocalMovieRoot, timestamp: Date, completion: @escaping (Error?) -> Void) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.cache = ManagedLocalMovieRoot.movieRoot(from: movieRoot, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping (Result<(LocalMovieRoot?, Date?), Error>) -> Void) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.success((cache.cache?.toLocal(), cache.timestamp)))
                } else {
                    completion(.success((nil, nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
