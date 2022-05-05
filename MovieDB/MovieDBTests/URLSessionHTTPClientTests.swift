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
    
    private struct UnexpectedError: Error {}
    
    func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedError()))
            }
        }.resume()
    }
    
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.registerURLProtocolStub()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.unregisterURLProtocolStub()
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
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: anyError()))

        XCTAssertNotNil(resultErrorFor(data: Data(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: anyURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: anyURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: anyHTTPURLResponse(), error: anyError()))  
    }
    
    func anyHTTPURLResponse() -> HTTPURLResponse {
        let url = URL(string: "http://any-url.com")!
        return HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    func anyURLResponse() -> URLResponse {
        let url = URL(string: "http://any-url.com")!
        return URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func anyError() -> NSError {
        return NSError(domain: "domain", code: 0)
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
        var receivedError: Error?
        
        switch result {
        case let .failure(error):
            receivedError = error
        default:
            XCTFail("Expected fail, received \(String(describing: result))", file: file, line: line)
        }
        
        return receivedError
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?) -> Result<(Data, HTTPURLResponse), Error>? {
        let sut = URLSessionHTTPClient()
        let url = URL(string: "http://a-url.com")!
        var receivedResult: Result<(Data, HTTPURLResponse), Error>?
        
        URLProtocolStub.stubWith(data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for request")
        sut.get(url: url) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
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
    
    static func registerURLProtocolStub() {
        URLProtocol.registerClass(self)
    }
    
    static func unregisterURLProtocolStub() {
        URLProtocol.unregisterClass(self)
        observeRequest = nil
        URLProtocolStub.stub = nil
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
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
