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
    
    func test_loadImageData_requestDataFromURLTwice() {
        let (sut, httpClient) = makeSUT()
        let url1 = URL(string: "http://any-url1.com")
        let url2 = URL(string: "http://any-url2.com")
        
        _ = sut.loadImageData(url: url1) { _ in }
        _ = sut.loadImageData(url: url2) { _ in }
        
        XCTAssertEqual([url1, url2], httpClient.clientURLs)
    }
    
    func test_loadImageData_deliversConnectivityErrorOnClientError() {
        let (sut, httpClient) = makeSUT()
        let url = URL(string: "http://any-url.com")
        let exp = expectation(description: "Wait image data load")
        
        _ = sut.loadImageData(url: url) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as! RemoteImageDataLoader.ImageDataLoaderError, RemoteImageDataLoader.ImageDataLoaderError.connectivity)
            default:
                XCTFail("Expected error, got \(result)")
            }
            exp.fulfill()
        }
        httpClient.complete(withError: anyError(), at: 0)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT() -> (RemoteImageDataLoader, HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteImageDataLoader(httpClient: httpClient)
        return (sut, httpClient)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "domain", code: 0, userInfo: nil)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var clientURLs: [URL] = []
        var completions: [(Result<(Data, HTTPURLResponse), Error>) -> Void] = []
        
        func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
            clientURLs.append(url)
            completions.append(completion)
        }
        
        func complete(withError error: Error, at index: Int) {
            completions[index](.failure(error))
        }
    }
}
