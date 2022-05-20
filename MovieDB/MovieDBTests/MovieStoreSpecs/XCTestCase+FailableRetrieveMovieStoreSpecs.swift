//
//  XCTestCase+FailableRetrieveMovieStoreSpecs.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 20/05/22.
//

import Foundation
import XCTest
import MovieDB

extension FailableRetrieveMovieStoreSpecs where Self: XCTestCase {
    func assertThatDeliversFailureOnRetrievalError(sut: MovieStore) {
        expect(sut: sut, withResult: .failure(NSError(domain: "domain", code: 1, userInfo: nil)))
    }
    
    func assertThatHasNoSideEffectsOnFailure(sut: MovieStore) {
        expect(sut: sut, toRetrieveTwice: .failure(NSError(domain: "domain", code: 1, userInfo: nil)))
    }
}
