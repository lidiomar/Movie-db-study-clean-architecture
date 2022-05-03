//
//  Movie.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 03/05/22.
//

import Foundation

public struct Movie: Equatable {
    let posterPath: String?
    let overview: String
    let releaseDate: String
    let genreIds: [Int]
    let id: Int
    let title: String
    let popularity: Double
    let voteCount: Int
    let voteAverage: Double
}
