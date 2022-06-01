//
//  Helpers.swift
//  MovieDBiOSTests
//
//  Created by Lidiomar Machado on 31/05/22.
//

import Foundation
import XCTest
import MovieDB

extension XCTestCase {
    func makeUniqueMovie(posterPath: String = "posterPath",
                         overview: String = "An overview",
                         releaseDate: String = "2018-09-09",
                         genreIds: [Int] = [1, 2],
                         id: Int = UUID().hashValue,
                         title: String = "a title",
                         popularity: Double = 0.0,
                         voteCount: Int = 0,
                         voteAverage: Double = 0.0) -> Movie {
        return Movie(posterPath: posterPath,
                     overview: overview,
                     releaseDate: releaseDate,
                     genreIds: genreIds,
                     id: id,
                     title: title,
                     popularity: popularity,
                     voteCount: voteCount,
                     voteAverage: voteAverage)
    }
}
