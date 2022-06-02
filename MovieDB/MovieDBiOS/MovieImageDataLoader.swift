//
//  MovieImageDataLoader.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 01/06/22.
//

import Foundation

public protocol MovieImageDataLoaderTask {
    func cancel()
}

public protocol MovieImageDataLoader {
    func loadImageData(url: URL?, completion: @escaping (Result<Data, Error>) -> Void) -> MovieImageDataLoaderTask
}
