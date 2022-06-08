//
//  LocalMovieLoader.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 09/05/22.
//

import Foundation

public class LocalMovieLoader {
    
    private var movieStore: MovieStore
    private var currentDate: () -> Date
    
    public init(movieStore: MovieStore, timestamp: @escaping () -> Date) {
        self.movieStore = movieStore
        self.currentDate = timestamp
    }
        
    private func cache(movieRoot: MovieRoot,
                       withCompletion completion: @escaping (Error?) -> Void) {
        
        let localMovieRoot = LocalMovieRoot(page: movieRoot.page,
                                            results: movieRoot.results.mapMovieToLocalMovie())
        
        self.movieStore.insert(movieRoot: localMovieRoot, timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
}

extension LocalMovieLoader: MovieCache {
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
}

extension LocalMovieLoader: MovieLoader {
    
    public func load(completion: @escaping (MovieLoaderResult) -> Void) {
        movieStore.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success((localMovieRoot, timeStamp)):
                guard let localMovieRoot = localMovieRoot,
                      let timeStamp = timeStamp,
                      ValidCachePolicy.validTimeStamp(self.currentDate(), against: timeStamp)
                else {
                    completion(.success(nil))
                    return
                }
                let movieRoot = MovieRoot(page: localMovieRoot.page,
                                          results: localMovieRoot.results.mapLocalMovieToMovie())
                completion(.success(movieRoot))
            }
        }
    }
    
    public func validateCache() {
        movieStore.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.movieStore.deleteCache { _ in }
            case let .success((_, timeStamp)):
                guard let timeStamp = timeStamp else {
                    return
                }
                if !ValidCachePolicy.validTimeStamp(self.currentDate(), against: timeStamp) {
                    self.movieStore.deleteCache(completion: { _ in })
                }
            }
        }
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
