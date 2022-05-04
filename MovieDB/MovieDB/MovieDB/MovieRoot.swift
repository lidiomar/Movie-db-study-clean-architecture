//
//  Movie.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 03/05/22.
//

import Foundation

public struct MovieRoot: Equatable {
    let page: Int
    let results: [Movie]
    
    public init(page: Int, results: [Movie]) {
        self.page = page
        self.results = results
    }
}
