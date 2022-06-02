//
//  RemoteImageDataLoader.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 01/06/22.
//

import Foundation

public class RemoteImageDataLoader: MovieImageDataLoader {
    
    private var httpClient: HTTPClient
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public func loadImageData(url: URL?, completion: @escaping (Result<Data, Error>) -> Void) -> MovieImageDataLoaderTask {
        return HTTPClientTask()
    }
    
    private final class HTTPClientTask: MovieImageDataLoaderTask {
        func cancel() {}
    }
}
