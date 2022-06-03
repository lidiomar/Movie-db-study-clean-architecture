//
//  MovieLoaderWithFallbackComposite.swift
//  MovieDBApp
//
//  Created by Lidiomar Machado on 03/06/22.
//

import MovieDB

public class MovieLoaderWithFallbackComposite: MovieLoader {
    private var primaryLoader: MovieLoader
    private var fallbackLoader: MovieLoader
    
    public init(primaryLoader: MovieLoader, fallbackLoader: MovieLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    public func load(completion: @escaping (MovieLoaderResult) -> Void) {
        primaryLoader.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            default:
                self?.fallbackLoader.load(completion: completion)
            }
        }
    }
}
