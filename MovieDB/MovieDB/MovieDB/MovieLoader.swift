//
//  MovieLoader.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 03/05/22.
//

import Foundation

protocol MovieLoader {
    typealias result = Swift.Result<MovieRoot, Error>
    
    func load(completion: @escaping (result) -> Void)
}
