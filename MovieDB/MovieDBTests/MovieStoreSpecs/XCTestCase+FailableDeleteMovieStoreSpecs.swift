//
//  XCTestCase+FailableDeleteMovieStoreSpecs.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 20/05/22.
//

import Foundation
import MovieDB
import XCTest

extension FailableDeleteMovieStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(sut: MovieStore) {
        let error = deleteCache(sut: sut)
        
        XCTAssertNotNil(error, "Expected to not delete successfully")
    }
    
    func assertThatDeleteHasNoSideEffectsOnFailure(sut: MovieStore) {
        deleteCache(sut: sut)
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
}
