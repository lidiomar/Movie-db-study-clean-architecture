//
//  CodableMovieStoreTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 18/05/22.
//

import Foundation
import XCTest
import MovieDB

class CoreDataMovieStoreTests: XCTestCase, MovieStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveEmptyResultOnEmptyCache(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatHasNoSideEffectsOnRetrieveEmptyCache(sut: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let localMovieRoot = LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()])
        
        assertThatDeliversFoundValuesOnNonEmptyCache(sut: sut, timestamp: timestamp, localMovieRoot: localMovieRoot)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let localMovieRoot = LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()])
        let timestamp = Date()
        
        assertThatHasNoSideEffectsOnNonEmptyCache(sut: sut, localMovieRoot: localMovieRoot, timestamp: timestamp)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        let localMovieRoot = LocalMovieRoot(page: 2, results: [makeUniqueLocalMovie()])
        let timestamp = Date()
        
        assertThatInsertOverridesPreviouslyInsertedCacheValues(sut: sut, localMovieRoot: localMovieRoot, timestamp: timestamp)
    }

    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(sut: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertInsertDeliversNoErrorOnNonEmptyCache(sut: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        deleteCache(sut: sut)
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(sut: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyCache(sut: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(sut: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        assertThatStoreSideEffectsRunSerially(sut: sut)
    }
    
    private func makeSUT(url: URL? = nil) -> MovieStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataMovieStore(storeURL: storeURL)
        return sut
    }
}
