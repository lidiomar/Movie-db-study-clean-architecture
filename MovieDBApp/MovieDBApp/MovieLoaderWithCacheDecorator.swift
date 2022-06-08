//
//  MovieLoaderWithCacheDecorator.swift
//  MovieDBApp
//
//  Created by Lidiomar Machado on 07/06/22.
//

import Foundation
import MovieDB

public class MovieLoaderWithCacheDecorator: MovieLoader {
    
    private var decoratee: MovieLoader
    private var cache: MovieCache
    
    public init(decoratee: MovieLoader, cache: MovieCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (MovieLoaderResult) -> Void) {
        decoratee.load { [weak self] result in
            completion(result)
            guard let movieRoot = try? result.get() else { return }
            self?.cache.save(movieRoot: movieRoot) { _ in }
        }
    }
}
