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
    
    init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    func load(url: URL, completion: @escaping (result) -> Void) {
        httpClient.get(url: url, completion: { _ in })
    }
}

protocol HTTPClient {
    func get(url: URL, completion: @escaping (Data) -> Void)
}

class RemoteMovieLoaderTests: XCTestCase {
    
    func test_remoteMovieLoader_requestURL() {
        let url = URL(string: "http://any-url.com")!
        let httpClientSpy = HTTPClientSpy()
        let sut = RemoteMovieLoader(url: url, httpClient: httpClientSpy)
        
        
        sut.load(url: url, completion: { _ in })
        
        XCTAssertEqual(url, httpClientSpy.url)
    }
}

class HTTPClientSpy: HTTPClient {
    var url: URL?
    
    func get(url: URL, completion: @escaping (Data) -> Void) {
        self.url = url
    }
}
