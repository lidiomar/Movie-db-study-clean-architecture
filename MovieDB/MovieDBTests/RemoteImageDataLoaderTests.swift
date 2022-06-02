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
        
        XCTAssertTrue(httpClient.clientURLs.isEmpty)
    }
    
    func test_loadImageData_requestDataFromURL() {
        let (sut, httpClient) = makeSUT()
        let url = URL(string: "http://any-url.com")
        
        _ = sut.loadImageData(url: url) { _ in }
        
        XCTAssertEqual([url], httpClient.clientURLs)
    }
    
    func test_loadImageData_requesetDataFromURLTwice() {
        let (sut, httpClient) = makeSUT()
        let url1 = URL(string: "http://any-url1.com")
        let url2 = URL(string: "http://any-url2.com")
        
        _ = sut.loadImageData(url: url1) { _ in }
        _ = sut.loadImageData(url: url2) { _ in }
        
        XCTAssertEqual([url1, url2], httpClient.clientURLs)
    }
    
    private func makeSUT() -> (RemoteImageDataLoader, HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteImageDataLoader(httpClient: httpClient)
        return (sut, httpClient)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        var clientURLs: [URL] = []
        
        func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
            clientURLs.append(url)
        }
    }
}
