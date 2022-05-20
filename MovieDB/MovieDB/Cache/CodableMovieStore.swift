//
//  CodableMovieStore.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 20/05/22.
//

import Foundation

public class CodableMovieStore {
    private var storeURL: URL
    
    private struct CodableLocalMovieRoot: Codable {
        let page: Int
        let results: [CodableLocalMovie]
        
        public init(page: Int, results: [CodableLocalMovie]) {
            self.page = page
            self.results = results
        }
        
        func mapToLocalMovieRoot() -> LocalMovieRoot {
            return LocalMovieRoot(page: page, results: results.map { getLocalMovieRoot(codableLocalMovie: $0) })
        }
        
        private func getLocalMovieRoot(codableLocalMovie: CodableLocalMovie) -> LocalMovie {
            return LocalMovie(posterPath: codableLocalMovie.posterPath,
                              overview: codableLocalMovie.overview,
                              releaseDate: codableLocalMovie.releaseDate,
                              genreIds: codableLocalMovie.genreIds,
                              id: codableLocalMovie.id,
                              title: codableLocalMovie.title,
                              popularity: codableLocalMovie.popularity,
                              voteCount: codableLocalMovie.voteCount,
                              voteAverage: codableLocalMovie.voteAverage)
        }
    }
    
    private struct CodableLocalMovie: Codable {
        public let posterPath: String?
        public let overview: String
        public let releaseDate: String
        public let genreIds: [Int]
        public let id: Int
        public let title: String
        public let popularity: Double
        public let voteCount: Int
        public let voteAverage: Double
        
        public init(localMovie: LocalMovie) {
            self.posterPath = localMovie.posterPath
            self.overview = localMovie.overview
            self.releaseDate = localMovie.releaseDate
            self.genreIds = localMovie.genreIds
            self.id = localMovie.id
            self.title = localMovie.title
            self.popularity = localMovie.popularity
            self.voteCount = localMovie.voteCount
            self.voteAverage = localMovie.voteAverage
        }
    }
    
    private struct Cache: Codable {
        let timestamp: Date
        let movieRoot: CodableLocalMovieRoot
    }
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
}

extension CodableMovieStore: MovieStore {
    public func deleteCache(completion: @escaping (Error?) -> Void) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            completion(nil)
            return
        }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func insert(movieRoot: LocalMovieRoot, timestamp: Date, completion: @escaping (Error?) -> Void) {
        let encoder = JSONEncoder()
        let codableMovieRoot = CodableLocalMovieRoot(page: movieRoot.page,
                                                     results: movieRoot.results.map { CodableLocalMovie(localMovie: $0) })
        do {
            let encoded = try encoder.encode(Cache(timestamp: timestamp, movieRoot: codableMovieRoot))
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func retrieve(completion: @escaping (Result<(LocalMovieRoot?, Date?), Error>) -> Void) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.success((nil, nil)))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.success((cache.movieRoot.mapToLocalMovieRoot(), cache.timestamp)))
        } catch {
            completion(.failure(error))
        }
    }
}
