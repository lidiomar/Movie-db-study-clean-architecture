//
//  Movie.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 03/05/22.
//

import Foundation

struct MovieRoot: Equatable {
    let page: Int
    let results: [Movie]
}
