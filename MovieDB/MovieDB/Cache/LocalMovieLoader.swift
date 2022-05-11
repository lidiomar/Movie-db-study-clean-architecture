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
    private let calendar = Calendar(identifier: .gregorian)
    private let currentDate = Date()
    
    public init(movieStore: MovieStore, timestamp: @escaping () -> Date) {
        self.movieStore = movieStore
        self.timestamp = timestamp
    }
    
    public func save(movieRoot: MovieRoot, completion: @escaping (Error?) -> Void) {
        movieStore.deleteCache() { [weak self] cacheDeletionError in
            guard let self = self else { return }
            if cacheDeletionError == nil {
                self.cache(movieRoot: movieRoot, withCompletion: completion)
                return
            }
            completion(cacheDeletionError)
        }
    }
        
    private func cache(movieRoot: MovieRoot,
                       withCompletion completion: @escaping (Error?) -> Void) {
        
        let localMovieRoot = LocalMovieRoot(page: movieRoot.page,
                                            results: movieRoot.results.mapMovieToLocalMovie())
        
        self.movieStore.insert(movieRoot: localMovieRoot, timestamp: self.timestamp()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
}

extension LocalMovieLoader: MovieLoader {
    
    public func load(completion: @escaping (MovieLoaderResult) -> Void) {
        movieStore.retrieve { [unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(localMovieRoot) where validTimeStamp(self.timestamp()):
                guard let localMovieRoot = localMovieRoot else {
                    completion(.success(nil))
                    return
                }
                let movieRoot = MovieRoot(page: localMovieRoot.page,
                                          results: localMovieRoot.results.mapLocalMovieToMovie())
                completion(.success(movieRoot))
            case .success:
                completion(.success(nil))
            }
        }
    }
    
    private func validTimeStamp(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: 9, to: timestamp) else {
            return false
        }
        
        return currentDate < maxCacheAge
    }
    
}

private extension Array where Element == LocalMovie {
    func mapLocalMovieToMovie() -> [Movie] {
        return self.map { Movie(posterPath: $0.posterPath,
                              overview: $0.overview,
                              releaseDate: $0.releaseDate,
                              genreIds: $0.genreIds,
                              id: $0.id,
                              title: $0.title,
                              popularity: $0.popularity,
                              voteCount: $0.voteCount,
                              voteAverage: $0.voteAverage) }
    }
}

private extension Array where Element == Movie {
    func mapMovieToLocalMovie() -> [LocalMovie] {
        return self.map { LocalMovie(posterPath: $0.posterPath,
                              overview: $0.overview,
                              releaseDate: $0.releaseDate,
                              genreIds: $0.genreIds,
                              id: $0.id,
                              title: $0.title,
                              popularity: $0.popularity,
                              voteCount: $0.voteCount,
                              voteAverage: $0.voteAverage) }
    }
}
