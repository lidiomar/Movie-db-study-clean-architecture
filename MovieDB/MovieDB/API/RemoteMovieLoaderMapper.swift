//
//  RemoteMovieLoaderMapper.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 04/05/22.
//

import Foundation

class RemoteMovieLoaderMapper {
    static func map(data: Data, response: HTTPURLResponse) -> MovieLoader.MovieLoaderResult {
        guard let movieRootDecodable = try? JSONDecoder().decode(MovieRootDecodable.self, from: data),
                response.statusCode == 200 else {
            return .failure(RemoteMovieLoader.Error.invalidData)
        }
        
        let movieRoot = MovieRoot(page: movieRootDecodable.page,
                         results: movieRootDecodable.results.map { $0.movie })
        
        return .success(movieRoot)
    }
}
