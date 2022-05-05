//
//  Movie.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 03/05/22.
//

import Foundation

public struct MovieDecodable: Decodable {
    let poster_path: String?
    let overview: String
    let release_date: String
    let genre_ids: [Int]
    let id: Int
    let title: String
    let popularity: Double
    let vote_count: Int
    let vote_average: Double
    
    var movie: Movie {
        return Movie(posterPath: poster_path,
                     overview: overview,
                     releaseDate: release_date,
                     genreIds: genre_ids,
                     id: id,
                     title: title,
                     popularity: popularity,
                     voteCount: vote_count,
                     voteAverage: vote_average)
    }
}
