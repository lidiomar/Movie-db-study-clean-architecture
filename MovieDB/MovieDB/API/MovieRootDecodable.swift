//
//  MovieRootDecodable.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 04/05/22.
//

import Foundation

public struct MovieRootDecodable: Decodable {
    let page: Int
    let results: [MovieDecodable]
}


