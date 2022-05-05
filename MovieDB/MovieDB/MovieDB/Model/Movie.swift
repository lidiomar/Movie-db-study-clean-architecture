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
    
    public init(posterPath: String?,
         overview: String,
         releaseDate: String,
         genreIds: [Int],
         id: Int,
         title: String,
         popularity: Double,
         voteCount: Int,
         voteAverage: Double) {
        
        self.posterPath = posterPath
        self.overview = overview
        self.releaseDate = releaseDate
        self.genreIds = genreIds
        self.id = id
        self.title = title
        self.popularity = popularity
        self.voteCount = voteCount
        self.voteAverage = voteAverage
    }
}
