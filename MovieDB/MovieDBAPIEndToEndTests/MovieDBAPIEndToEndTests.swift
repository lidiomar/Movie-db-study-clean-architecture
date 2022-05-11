//
//  MovieDBAPIEndToEndTests.swift
//  MovieDBAPIEndToEndTests
//
//  Created by Lidiomar Machado on 05/05/22.
//

import XCTest
import MovieDB

class MovieDBAPIEndToEndTests: XCTestCase {
    private let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=44bc59c6e912b1afda251960c4f46658&language=en-US&page=1"
    
    func test_retrieve20ElementsFromApiForPageNumber1() {
        let url = URL(string: urlString)!
        let httpClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let remoteMovieLoader = RemoteMovieLoader(url: url, httpClient: httpClient)
        
        let exp = expectation(description: "Wait for request")
        remoteMovieLoader.load { result in
            switch result {
            case let .success(movieRoot):
                XCTAssertEqual(movieRoot!.page, 1)
                XCTAssertEqual(movieRoot!.results.count, 20)
            default:
                XCTFail("Expect success but \(result) was received.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 30.0)
    }
}
