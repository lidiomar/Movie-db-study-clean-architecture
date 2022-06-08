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
        _ = httpClient.get(url: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                do {
                    let movieDecodable = try RemoteMovieLoaderMapper.map(data: data, response: response)
                    completion(.success(MovieRoot(page: movieDecodable.page, results: movieDecodable.results.mapToModel())))
                } catch {
                    completion(.failure(error))
                }
            case .failure:
                completion(.failure(RemoteMovieLoader.Error.connectionError))
            }
        })
    }
}

extension Array where Element == MovieDecodable {
    func mapToModel() -> [Movie] {
        return self.map { Movie(posterPath: $0.poster_path,
                                overview: $0.overview,
                                releaseDate: $0.release_date,
                                genreIds: $0.genre_ids,
                                id: $0.id,
                                title: $0.title,
                                popularity: $0.popularity,
                                voteCount: $0.vote_count,
                                voteAverage: $0.vote_average)}
    }
}
