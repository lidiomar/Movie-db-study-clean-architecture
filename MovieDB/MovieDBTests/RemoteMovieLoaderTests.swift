//
//  RemoteMovieLoaderTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 03/05/22.
//

import XCTest
import MovieDB

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
        
        expect(sut, toCompleteWith: .connectionError) {
            httpClient.completeWith(error: NSError(domain: "test", code: 0), at: 0)
        }
    }
    
    func test_loader_deliversErrorOnNon200HTTPStatus() {
        let url = URL(string: "http://any-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        let httpSamples = [404, 401, 500, 502]
        
        httpSamples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .invalidData) {
                httpClient.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    private func expect(_ sut: MovieLoader,
                        toCompleteWith result: RemoteMovieLoader.Error,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        var capture = [RemoteMovieLoader.Error]()
        
        sut.load { result in
            switch result {
            case let .failure(error):
                capture.append(error as! RemoteMovieLoader.Error)
            default:
                XCTFail("Expected failure but \(result) was found", file: file, line: line)
            }
        }
        
        action()
        
        XCTAssertEqual(capture, [result])
    }
    
    private func makeSUT(url: URL) -> (MovieLoader, HTTPClientSpy) {
        let httpClientSpy = HTTPClientSpy()
        let sut = RemoteMovieLoader(url: url, httpClient: httpClientSpy)
        return (sut, httpClientSpy)
    }
}

class HTTPClientSpy: HTTPClient {
    var urls: [URL] = []
    var completions: [(Result<(Data, HTTPURLResponse), Error>) -> Void] = []
    
    func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        urls.append(url)
        completions.append(completion)
    }
    
    func completeWith(error: Error, at index: Int) {
        completions[index](.failure(error))
    }
    
    func complete(withStatusCode statusCode: Int, at index: Int) {
        let response = HTTPURLResponse(url: urls[index],
                                       statusCode: statusCode,
                                       httpVersion: nil,
                                       headerFields: nil)!
        let data = Data()
        completions[index](.success((data, response)))
    }
}
