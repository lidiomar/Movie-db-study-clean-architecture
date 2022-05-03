//
//  MovieLoader.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 03/05/22.
//

import Foundation

public protocol MovieLoader {
    typealias MovieLoaderResult = Swift.Result<MovieRoot, Error>
    
    func load(completion: @escaping (MovieLoaderResult) -> Void)
}
