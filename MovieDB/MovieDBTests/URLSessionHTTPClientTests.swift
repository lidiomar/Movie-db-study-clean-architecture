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
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
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
        URLProtocolStub.observeRequest = nil
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
    
    func test_getFromURL_failsWhenRequestURL() {
        let sut = URLSessionHTTPClient()
        let url = URL(string: "http://a-url.com")!
        let stubError = NSError(domain: "domain", code: 0)
        URLProtocolStub.stubWith(data: nil, response: nil, error: stubError)

        let exp2 = expectation(description: "Wait for request")
        sut.get(url: url, completion: { result in
            switch result {
            case .success:
                XCTFail("Expected failure got \(result)")
            case let .failure(error):
                XCTAssertEqual((error as NSError).code, stubError.code)
                XCTAssertEqual((error as NSError).domain, stubError.domain)
            }
            exp2.fulfill()
        })

        wait(for: [exp2], timeout: 1.0)
    }
}

class URLProtocolStub: URLProtocol {
    
    static var observeRequest: ((URLRequest) -> Void)?
    private static var stub: Stub?
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static func stubWith(data: Data?, response: URLResponse?, error: Error?) {
        URLProtocolStub.stub = Stub(data: data, response: response, error: error)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        URLProtocolStub.observeRequest?(request)
        return true
    }
    
    override func startLoading() {
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
