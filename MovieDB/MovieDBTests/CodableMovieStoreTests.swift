//
//  CodableMovieStoreTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 18/05/22.
//

import Foundation
import XCTest
import MovieDB

class CodableMovieStore: MovieStore {
    func deleteCache(completion: @escaping (Error?) -> Void) {
        
    }
    
    func insert(movieRoot: LocalMovieRoot, timestamp: Date, completion: @escaping (Error?) -> Void) {
        
    }
    
    func retrieve(completion: @escaping (Result<(LocalMovieRoot?, Date?), Error>) -> Void) {
        completion(.success((nil, nil)))
    }
}

class CodableMovieStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        var receivedLocalMovieRoot: LocalMovieRoot?
        let exp = expectation(description: "Wait for movie retrieval")
        
        sut.retrieve { result in
            switch result {
            case let .success((localMovieRoot, _)):
                receivedLocalMovieRoot = localMovieRoot
            default:
                XCTFail("Expected success with data got \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(receivedLocalMovieRoot)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for movie retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case let (.success((firstLocalMovieRoot, firstDate)), .success((secondLocalMovieRoot, secondDate))):
                    XCTAssertNil(firstLocalMovieRoot)
                    XCTAssertNil(firstDate)
                    XCTAssertNil(secondLocalMovieRoot)
                    XCTAssertNil(secondDate)
                default:
                    XCTFail("Expected success with empty data got \(firstResult) and \(secondResult)")
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT() -> CodableMovieStore {
        let sut = CodableMovieStore()
        return sut
    }
}
