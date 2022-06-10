//
//  MovieCache.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 07/06/22.
//

import Foundation

public protocol MovieCache {
    func save(movieRoot: MovieRoot, completion: @escaping (Error?) -> Void)
}
