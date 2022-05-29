//
//  CodableMovieStoreTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 18/05/22.
//

import Foundation
import XCTest
import MovieDB

class CodableMovieStoreTests: XCTestCase, FailableMovieStoreSpecs {
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveEmptyResultOnEmptyCache(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatHasNoSideEffectsOnRetrieveEmptyCache(sut: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
//        let sut = makeSUT()
//        let timestamp = Date()
//        let localMovieRoot = LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()])
//
//        assertThatDeliversFoundValuesOnNonEmptyCache(sut: sut, timestamp: timestamp, localMovieRoot: localMovieRoot)
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
//        let url = testSpecificStoreURL()
//        let sut = makeSUT(url: url)
//
//        try? "Invalid data".write(to: url, atomically: false, encoding: .utf8)
//
//        assertThatDeliversFailureOnRetrievalError(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
//        let storeURL = testSpecificStoreURL()
//        let sut = makeSUT(url: storeURL)
//
//        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
//
//        assertThatHasNoSideEffectsOnFailure(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
//        let sut = makeSUT()
//        let localMovieRoot = LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()])
//        let timestamp = Date()
//
//        assertThatHasNoSideEffectsOnNonEmptyCache(sut: sut, localMovieRoot: localMovieRoot, timestamp: timestamp)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
//        let sut = makeSUT()
//        let localMovieRoot = LocalMovieRoot(page: 2, results: [makeUniqueLocalMovie()])
//        let timestamp = Date()
//
//        assertThatInsertOverridesPreviouslyInsertedCacheValues(sut: sut, localMovieRoot: localMovieRoot, timestamp: timestamp)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let url = URL(string: "#@invalid/store-url")!
        let sut = makeSUT(url: url)
        
        assertThatInsertDeliversErrorOnInsertionError(sut: sut)
    }
    
    func test_insert_hasNoSideEffectsOnFailure() {
        let url = URL(string: "#@invalid/store-url")!
        let sut = makeSUT(url: url)
        
        assertThatInsertHasNoSideEffectsOnFailure(sut: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatInsertDeliversNoErrorOnEmptyCache(sut: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        assertInsertDeliversNoErrorOnNonEmptyCache(sut: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        deleteCache(sut: sut)
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let sut = makeSUT(url: FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!)
        
        assertThatDeleteDeliversErrorOnDeletionError(sut: sut)
    }
    
    func test_delete_hasNoSideEffectsOnFailure() {
        let sut = makeSUT(url: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!)
        
        assertThatDeleteHasNoSideEffectsOnFailure(sut: sut)
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
        let sut = CodableMovieStore(storeURL: url ?? testSpecificStoreURL())
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("\(type(of: self)).store")
    }
}
