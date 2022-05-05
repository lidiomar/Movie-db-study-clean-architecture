//
//  RemoteMovieLoaderMapper.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 04/05/22.
//

import Foundation

class RemoteMovieLoaderMapper {
    static func map(data: Data, response: HTTPURLResponse) throws -> MovieRoot {
        if response.statusCode != 200 {
            throw RemoteMovieLoader.Error.invalidData
        }
            
        let movieRootDecodable = try JSONDecoder().decode(MovieRootDecodable.self, from: data)
        
        return MovieRoot(page: movieRootDecodable.page,
                         results: movieRootDecodable.results.map { $0.movie })
    }
}
