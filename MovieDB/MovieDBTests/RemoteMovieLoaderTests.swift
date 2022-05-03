//
//  RemoteMovieLoaderTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 03/05/22.
//

import XCTest
import MovieDB


class RemoteMovieLoader: MovieLoader {
    private var url: URL
    private var httpClient: HTTPClient
    
    enum Error: Swift.Error {
        case connectionError
        case invalidData
    }
    
    init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    func load(completion: @escaping (MovieLoaderResult) -> Void) {
        httpClient.get(url: url, completion: { result in
            switch result {
            case .failure:
                completion(.failure(RemoteMovieLoader.Error.connectionError))
            default:
                break
            }
        })
    }
}

protocol HTTPClient {
    func get(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

class RemoteMovieLoaderTests: XCTestCase {
    
    func test_loader_requestURL() {
        let url = URL(string: "http://any-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        
        XCTAssertEqual(httpClient.urls, [url])
    }
    
    func test_loader_requestURLTwice() {
        let url = URL(string: "http://any-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        sut.load(completion: { _ in })
        
        XCTAssertEqual(httpClient.urls, [url, url])
    }
    
    func test_loader_deliversErrorOnClientError() {
        let url = URL(string: "http://any-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        var capturedErrors: [RemoteMovieLoader.Error] = []
        
        sut.load(completion: { result in
            switch result {
            case let .failure(error):
                capturedErrors.append(error as! RemoteMovieLoader.Error)
            default:
                XCTFail("Expected error but \(result) was found")
            }
        })
            
        httpClient.completeWith(error: NSError(domain: "test", code: 0), at: 0)
        
        XCTAssertEqual(capturedErrors, [.connectionError])
    }
    
    private func makeSUT(url: URL) -> (MovieLoader, HTTPClientSpy) {
        let httpClientSpy = HTTPClientSpy()
        let sut = RemoteMovieLoader(url: url, httpClient: httpClientSpy)
        return (sut, httpClientSpy)
    }
}

class HTTPClientSpy: HTTPClient {
    var urls: [URL] = []
    var completions: [(Result<Data, Error>) -> Void] = []
    
    func get(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        urls.append(url)
        completions.append(completion)
    }
    
    func completeWith(error: Error, at index: Int) {
        completions[index](.failure(error))
    }
}
