//
//  RemoteMovieLoader.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 03/05/22.
//

import Foundation

public class RemoteMovieLoader: MovieLoader {
    private var url: URL
    private var httpClient: HTTPClient
    
    public enum Error: Swift.Error {
        case connectionError
        case invalidData
    }
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (MovieLoaderResult) -> Void) {
        httpClient.get(url: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure:
                completion(.failure(RemoteMovieLoader.Error.connectionError))
            case let .success((data, response)):
                do {
                    let movieRoot = try RemoteMovieLoaderMapper.map(data: data, response: response)
                    completion(.success(movieRoot))
                } catch {
                    completion(.failure(RemoteMovieLoader.Error.invalidData))
                }
            }
        })
    }
}
