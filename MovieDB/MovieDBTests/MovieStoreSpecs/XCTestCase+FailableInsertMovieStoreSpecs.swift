//
//  XCTestCase+FailableInsertMovieStoreSpecs.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 20/05/22.
//

import Foundation
import XCTest
import MovieDB

extension FailableInsertMovieStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(sut: MovieStore) {
        let error = insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        
        XCTAssertNotNil(error)
    }
    
    func assertThatInsertHasNoSideEffectsOnFailure(sut: MovieStore) {
        insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
}
