//
//  RemoteImageDataLoaderTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 01/06/22.
//

import XCTest
import MovieDB

class RemoteImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, httpClient) = makeSUT()
        
        XCTAssertTrue(httpClient.completions.isEmpty)
    }
    
    func test_loadImageData_requestDataFromURL() {
        let (sut, httpClient) = makeSUT()
        let url = URL(string: "http://any-url.com")
        
        _ = sut.loadImageData(url: url) { _ in }
        
        let (urlRequested, _) = httpClient.completions[0]
        XCTAssertEqual(url, urlRequested)
    }
    
    private func makeSUT() -> (RemoteImageDataLoader, HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteImageDataLoader(httpClient: httpClient)
        return (sut, httpClient)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        
        var completions: [(URL, (Result<(Data, HTTPURLResponse), Error>) -> Void)] = []
        
        func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
            completions.append((url, completion))
        }
    }
}
