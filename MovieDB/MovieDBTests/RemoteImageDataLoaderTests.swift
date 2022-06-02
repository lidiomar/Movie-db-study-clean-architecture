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
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, httpClient) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expectToCompleteWith(sut: sut, result: .failure(RemoteImageDataLoader.ImageDataLoaderError.invalidData)) {
                httpClient.complete(statusCode: code, andData: Data(), at: index)
            }
        }
    }
    
    private func expectToCompleteWith(sut: RemoteImageDataLoader, result expectedResult: Result<Data, Error>, when action: () -> Void) {
        let url = URL(string: "http://any-url.com")
        let exp = expectation(description: "Wait image data load")

        _ = sut.loadImageData(url: url) { result in
            switch (result, expectedResult) {
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as! RemoteImageDataLoader.ImageDataLoaderError, expectedError as! RemoteImageDataLoader.ImageDataLoaderError)
            default:
                XCTFail("Expected error, got \(result)")
            }
            exp.fulfill()
        }
        
        action()
        
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
        private struct Task: HTTPClientTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
        
        var clientURLs: [URL] = []
        var cancelledURLs: [URL] = []
        var completions: [(Result<(Data, HTTPURLResponse), Error>) -> Void] = []
        
        func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask  {
            clientURLs.append(url)
            completions.append(completion)
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(withError error: Error, at index: Int) {
            completions[index](.failure(error))
        }
        
        func complete(statusCode: Int, andData data: Data, at index: Int) {
            let urlResponse = HTTPURLResponse(url: URL(string: "http://any-url.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            completions[index](.success((data, urlResponse)))
        }
    }
}
