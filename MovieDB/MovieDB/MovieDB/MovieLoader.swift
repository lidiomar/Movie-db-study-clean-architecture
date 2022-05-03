//
//  MovieLoader.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 03/05/22.
//

import Foundation

public protocol MovieLoader {
    typealias result = Swift.Result<MovieRoot, Error>
    
    func load(url: URL, completion: @escaping (result) -> Void)
}
