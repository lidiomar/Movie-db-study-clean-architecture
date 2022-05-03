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
    
    func load(completion: @escaping (result) -> Void) {
        httpClient.get(url: url, completion: { _ in })
    }
}

protocol HTTPClient {
    func get(url: URL, completion: @escaping (Data) -> Void)
}

class RemoteMovieLoaderTests: XCTestCase {
    
    func test_remoteMovieLoader_requestURL() {
        let url = URL(string: "http://any-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        
        XCTAssertEqual(httpClient.urls, [url])
    }
    
    func test_remoteMovieLoader_requestURLTwice() {
        let url = URL(string: "http://any-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        sut.load(completion: { _ in })
        
        XCTAssertEqual(httpClient.urls, [url, url])
    }
    
    private func  makeSUT(url: URL) -> (MovieLoader, HTTPClientSpy) {
        let httpClientSpy = HTTPClientSpy()
        let sut = RemoteMovieLoader(url: url, httpClient: httpClientSpy)
        return (sut, httpClientSpy)
    }
}

class HTTPClientSpy: HTTPClient {
    var urls: [URL] = []
    
    func get(url: URL, completion: @escaping (Data) -> Void) {
        urls.append(url)
    }
}
