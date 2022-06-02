//
//  RemoteImageDataLoader.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 01/06/22.
//

import Foundation

public class RemoteImageDataLoader: MovieImageDataLoader {
    private var httpClient: HTTPClient
    
    public enum ImageDataLoaderError: Swift.Error {
        case connectivity, invalidData
    }
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public func loadImageData(url: URL?, completion: @escaping (Result<Data, Error>) -> Void) -> MovieImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = httpClient.get(url: url!) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                            .mapError { _ in ImageDataLoaderError.connectivity }
                            .flatMap { (data, response) in
                                let isValidResponse = response.isOK && !data.isEmpty
                                return isValidResponse ? .success(data) : .failure(ImageDataLoaderError.invalidData)
                            })
        }
        return task
    }
}

private final class HTTPClientTaskWrapper: MovieImageDataLoaderTask {
    private var completion: ((Result<Data, Error>) -> Void)?
    
    var wrapped: HTTPClientTask?
    
    init(_ completion: @escaping (Result<Data, Error>) -> Void) {
        self.completion = completion
    }
    
    func complete(with result: (Result<Data, Error>)) {
        completion?(result)
    }
    
    func cancel() {
        preventFurtherCompletions()
        wrapped?.cancel()
    }
    
    private func preventFurtherCompletions() {
        completion = nil
    }
}


