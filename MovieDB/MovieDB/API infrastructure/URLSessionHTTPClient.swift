//
//  URLSessionHTTPClient.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 05/05/22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    var session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedError: Error {}
    
    private struct URLSessionHTTPClientWrapper: HTTPClientTask {
        var wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        let urlSessionTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedError()))
            }
        }
        urlSessionTask.resume()
        return URLSessionHTTPClientWrapper(wrapped: urlSessionTask)
    }
    
}
