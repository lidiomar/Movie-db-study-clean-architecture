//
//  LocalMovieLoader.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 09/05/22.
//

import Foundation

public class LocalMovieLoader {
    
    private var movieStore: MovieStore
    private var timestamp: () -> Date
    
    public init(movieStore: MovieStore, timestamp: @escaping () -> Date) {
        self.movieStore = movieStore
        self.timestamp = timestamp
    }
    
    public func save(movieRoot: MovieRoot, completion: @escaping (Error?) -> Void) {
        movieStore.deleteCache() { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                self.movieStore.insert(movieRoot: movieRoot, timestamp: self.timestamp()) { [weak self] error in
                    guard self != nil else { return }
                    completion(error)
                }
                return
            }
            completion(error)
        }
    }
    
}
