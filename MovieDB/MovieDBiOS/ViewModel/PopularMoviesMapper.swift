//
//  PopularMoviesMapper.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 31/05/22.
//

import Foundation
import MovieDB

struct PopularMoviesMapper {
    static func toMovieModel(_ movies: [Movie]) -> [MovieModel] {
        movies.map { MovieModel(popularity: String($0.popularity),
                              title: $0.title,
                              score: String($0.voteAverage),
                              releaseYear: $0.releaseDate,
                              thumbnailURL: thumbURL(posterPath: $0.posterPath))}
    }
    
    static private func thumbURL(posterPath: String?) -> URL? {
        guard let path = posterPath else {
            return nil
        }
        return URL(string: "\(Constants.baseImageURL)\(Constants.imageWidth)\(path)")
    }
}
