//
//  URLSessionHTTPClientTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 05/05/22.
//

import XCTest
import MovieDB

class URLSessionHTTPClient: HTTPClient {
    var session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        session.dataTask(with: url) { data, response, error in }.resume()
    }
    
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    func test_getFromURL_callGETRequestWithURL() {
        let sut = URLSessionHTTPClient()
        let url = URL(string: "http://a-url.com")!
        
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequest = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        sut.get(url: url, completion: { _ in })
        
        
        wait(for: [exp], timeout: 1.0)
    }
}

class URLProtocolStub: URLProtocol {
    
    static var observeRequest: ((URLRequest) -> Void)?
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        URLProtocolStub.observeRequest?(request)
        return true
    }
    
    override func startLoading() {}
    
    override func stopLoading() {}
}
