//
//  LocalMovie.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 10/05/22.
//

import Foundation

public struct LocalMovie: Equatable {
    public let posterPath: String?
    public let overview: String
    public let releaseDate: String
    public let genreIds: [Int]
    public let id: Int
    public let title: String
    public let popularity: Double
    public let voteCount: Int
    public let voteAverage: Double
    
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
