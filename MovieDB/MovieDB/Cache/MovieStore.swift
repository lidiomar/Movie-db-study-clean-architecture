//
//  MovieStore.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 09/05/22.
//

import Foundation

public protocol MovieStore {
    func deleteCache(completion: @escaping (Error?) -> Void)
    func insert(movieRoot: LocalMovieRoot, timestamp: Date, completion: @escaping (Error?) -> Void)
    func retrieve(completion: @escaping (Result<(LocalMovieRoot?, Date?), Error>) -> Void)
}
