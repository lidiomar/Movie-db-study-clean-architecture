//
//  RemoteMovieLoader.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 03/05/22.
//

import Foundation

public class RemoteMovieLoader: MovieLoader {
    private var url: URL
    private var httpClient: HTTPClient
    
    public enum Error: Swift.Error {
        case connectionError
        case invalidData
    }
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (MovieLoaderResult) -> Void) {
        httpClient.get(url: url, completion: { result in
            switch result {
            case .failure:
                completion(.failure(RemoteMovieLoader.Error.connectionError))
            case let .success((data, response)):
                if response.statusCode != 200 {
                    completion(.failure(RemoteMovieLoader.Error.invalidData))
                } else {
                    let movieRootDecodable = try! JSONDecoder().decode(MovieRootDecodable.self, from: data)
                    let movieRoot = MovieRoot(page: movieRootDecodable.page, results: movieRootDecodable.results.map { Movie(posterPath: $0.poster_path, overview: $0.overview, releaseDate: $0.release_date, genreIds: $0.genre_ids, id: $0.id, title: $0.title, popularity: $0.popularity, voteCount: $0.vote_count, voteAverage: $0.vote_average) } )
                    
                    if movieRoot.results.isEmpty {
                        completion(.failure(RemoteMovieLoader.Error.invalidData))
                        return
                    }
                    
                    completion(.success(movieRoot))
                }
            }
        })
    }
    
    
}
