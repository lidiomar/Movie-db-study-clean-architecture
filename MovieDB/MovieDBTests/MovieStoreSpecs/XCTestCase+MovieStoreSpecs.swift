//
//  XCTestCase+MovieStoreSpecs.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 20/05/22.
//

import Foundation
import XCTest
import MovieDB

extension MovieStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveEmptyResultOnEmptyCache(sut: MovieStore) {
        expect(sut: sut, withResult: .success((nil, nil)))
    }
    
    func assertThatHasNoSideEffectsOnRetrieveEmptyCache(sut: MovieStore) {
        expect(sut: sut, toRetrieveTwice: .success((nil, nil)))
    }
    
    func assertThatDeliversFoundValuesOnNonEmptyCache(sut: MovieStore, timestamp: Date, localMovieRoot: LocalMovieRoot) {
        insert(sut: sut, localMovieRoot: localMovieRoot, timestamp: timestamp)
        
        expect(sut: sut, withResult: .success((localMovieRoot, timestamp)))
    }
    
    func assertThatHasNoSideEffectsOnNonEmptyCache(sut: MovieStore, localMovieRoot: LocalMovieRoot, timestamp: Date) {
        insert(sut: sut, localMovieRoot: localMovieRoot, timestamp: timestamp)
        
        expect(sut: sut, toRetrieveTwice: .success((localMovieRoot, timestamp)))
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(sut: MovieStore, localMovieRoot: LocalMovieRoot, timestamp: Date) {
        insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        insert(sut: sut, localMovieRoot: localMovieRoot, timestamp: timestamp)
        
        expect(sut: sut, withResult: .success((localMovieRoot, timestamp)))
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(sut: MovieStore) {
        let error = insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        
        XCTAssertNil(error)
    }
    
    func assertInsertDeliversNoErrorOnNonEmptyCache(sut: MovieStore) {
        insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        let error = insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 2, results: [makeUniqueLocalMovie()]), timestamp: Date())
        
        XCTAssertNil(error)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(sut: MovieStore) {
        let error = deleteCache(sut: sut)
        
        XCTAssertNil(error)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(sut: MovieStore) {
        deleteCache(sut: sut)
        deleteCache(sut: sut)
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(sut: MovieStore) {
        insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        let error = deleteCache(sut: sut)
        
        XCTAssertNil(error)
    }
    
    func assertThatStoreSideEffectsRunSerially(sut: MovieStore) {
        let exp1 = expectation(description: "1")
        let exp2 = expectation(description: "2")
        let exp3 = expectation(description: "3")
        var orderOfExecution = [XCTestExpectation]()
        
        sut.insert(movieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date()) { _ in
            exp1.fulfill()
            orderOfExecution.append(exp1)
        }
        
        sut.deleteCache { _ in
            exp2.fulfill()
            orderOfExecution.append(exp2)
        }
        
        sut.insert(movieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date()) { _ in
            exp3.fulfill()
            orderOfExecution.append(exp3)
        }
        
        wait(for: [exp1, exp2, exp3], timeout: 5.0)
        
        XCTAssertEqual(orderOfExecution, [exp1, exp2, exp3])
    }
}

extension MovieStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(sut: MovieStore, localMovieRoot: LocalMovieRoot, timestamp: Date) -> Error? {
        let exp = expectation(description: "Wait for movie insertion")
        var receivedError: Error?
        
        sut.insert(movieRoot: localMovieRoot, timestamp: timestamp) { error in
            receivedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    @discardableResult
    func deleteCache(sut: MovieStore) -> Error? {
        let exp = expectation(description: "Wait for deletion")
        var receivedError: Error?
        
        sut.deleteCache { error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 30.0)
        return receivedError
    }
    
    func expect(sut: MovieStore,
                toRetrieveTwice result: Result<(LocalMovieRoot?, Date?), Error>,
                file: StaticString = #file,
                line: UInt = #line) {
        expect(sut: sut, withResult: result)
        expect(sut: sut, withResult: result)

    }
    
    func expect(sut: MovieStore,
                withResult expectedResult: Result<(LocalMovieRoot?, Date?), Error>,
                file: StaticString = #file,
                line: UInt = #line) {
        let exp = expectation(description: "Wait for movie retrieval")
        
        sut.retrieve { result in
            switch (result, expectedResult) {
            case let (.success((localMovieRoot, timestamp)), .success((expectedLocalMovieRoot, expectedTimestamp))):
                XCTAssertEqual(localMovieRoot, expectedLocalMovieRoot, file: file, line: line)
                XCTAssertEqual(timestamp, expectedTimestamp)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected success with data got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func makeUniqueLocalMovie(posterPath: String = "",
                              overview: String = "",
                              releaseDate: String = "",
                              genreIds: [Int] = [1],
                              id: Int = UUID().hashValue,
                              title: String = "",
                              popularity: Double = 1.0,
                              voteCount: Int = 1,
                              voteAverage: Double = 1.0) -> LocalMovie {
        
        return LocalMovie(posterPath: posterPath,
                          overview: overview,
                          releaseDate: releaseDate,
                          genreIds: genreIds,
                          id: id,
                          title: title,
                          popularity: popularity,
                          voteCount: voteCount,
                          voteAverage: voteAverage)
    }
}
