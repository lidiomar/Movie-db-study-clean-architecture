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
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieveTwice: .success((nil, nil)))
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let insertedTimestamp = Date()
        let insertedLocalMovieRoot = LocalMovieRoot(page: 1,
                                                    results: [makeUniqueLocalMovie()])
        
        
        let error = insert(sut: sut, localMovieRoot: insertedLocalMovieRoot, timestamp: insertedTimestamp)
        
        XCTAssertNil(error, "Movie was not inserted with success.")
        expect(sut: sut, withResult: .success((insertedLocalMovieRoot, insertedTimestamp)))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let url = testSpecificStoreURL()
        let sut = makeSUT(url: url)
        
        try? "Invalid data".write(to: url, atomically: false, encoding: .utf8)
        
        expect(sut: sut, withResult: .failure(NSError(domain: "domain", code: 1, userInfo: nil)))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(url: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut: sut, toRetrieveTwice: .failure(NSError(domain: "domain", code: 1, userInfo: nil)))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let expectedLocalMovieRoot = LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()])
        let expectedDate = Date()
        
        insert(sut: sut, localMovieRoot: expectedLocalMovieRoot, timestamp: expectedDate)
        
        expect(sut: sut, toRetrieveTwice: .success((expectedLocalMovieRoot, expectedDate)))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        let latestLocalMovieRoot = LocalMovieRoot(page: 2, results: [makeUniqueLocalMovie()])
        let latestTimestamp = Date()
        
        insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        insert(sut: sut, localMovieRoot: latestLocalMovieRoot, timestamp: latestTimestamp)
        
        expect(sut: sut, withResult: .success((latestLocalMovieRoot, latestTimestamp)))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let url = URL(string: "#@invalid/store-url")!
        let sut = makeSUT(url: url)
        
        let error = insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        
        XCTAssertNotNil(error)
    }
    
    func test_insert_hasNoSideEffectsOnFailure() {
        let url = URL(string: "#@invalid/store-url")!
        let sut = makeSUT(url: url)
        
        insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let error = insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        
        XCTAssertNil(error)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        let error = insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 2, results: [makeUniqueLocalMovie()]), timestamp: Date())
        
        XCTAssertNil(error)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        deleteCache(sut: sut)
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let sut = makeSUT(url: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!)
        
        let error = deleteCache(sut: sut)
        
        XCTAssertNotNil(error, "Expected to not delete successfully")
    }
    
    func test_delete_hasNoSideEffectsOnFailure() {
        let sut = makeSUT(url: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!)
        
        deleteCache(sut: sut)
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let error = deleteCache(sut: sut)
        
        XCTAssertNil(error)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(sut: sut)
        deleteCache(sut: sut)
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert(sut: sut, localMovieRoot: LocalMovieRoot(page: 1, results: [makeUniqueLocalMovie()]), timestamp: Date())
        let error = deleteCache(sut: sut)
        
        XCTAssertNil(error)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
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
    
    @discardableResult
    private func insert(sut: MovieStore, localMovieRoot: LocalMovieRoot, timestamp: Date) -> Error? {
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
    private func deleteCache(sut: MovieStore) -> Error? {
        let exp = expectation(description: "Wait for deletion")
        var receivedError: Error?
        
        sut.deleteCache { error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 30.0)
        return receivedError
    }
    
    private func expect(sut: MovieStore,
                        toRetrieveTwice result: Result<(LocalMovieRoot?, Date?), Error>,
                        file: StaticString = #file,
                        line: UInt = #line) {
        expect(sut: sut, withResult: result)
        expect(sut: sut, withResult: result)

    }
    
    private func expect(sut: MovieStore,
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
    
    private func makeSUT(url: URL? = nil) -> MovieStore {
        let sut = CodableMovieStore(storeURL: url ?? testSpecificStoreURL())
        return sut
    }
    
    
    private func makeUniqueLocalMovie(posterPath: String = "",
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
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory,
                                        in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
