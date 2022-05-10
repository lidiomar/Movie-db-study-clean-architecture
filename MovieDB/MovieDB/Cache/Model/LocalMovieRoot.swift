//
//  LocalMovieRoot.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 10/05/22.
//

import Foundation

public struct LocalMovieRoot: Equatable {
    public let page: Int
    public let results: [LocalMovie]
    
    public init(page: Int, results: [LocalMovie]) {
        self.page = page
        self.results = results
    }
}
