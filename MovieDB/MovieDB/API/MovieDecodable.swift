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
}
