//
//  RemoteMovieLoaderMapper.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 04/05/22.
//

import Foundation

class RemoteMovieLoaderMapper {
    
    static func map(data: Data, response: HTTPURLResponse) throws -> MovieRootDecodable {
        guard response.statusCode == 200,
              let movieRootDecodable = try? JSONDecoder().decode(MovieRootDecodable.self, from: data) else {
                  throw RemoteMovieLoader.Error.invalidData
              }
        return movieRootDecodable
    }
    
}
