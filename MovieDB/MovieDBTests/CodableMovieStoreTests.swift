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
    private var storeURL: URL
    
    private struct CodableLocalMovieRoot: Codable {
        let page: Int
        let results: [CodableLocalMovie]
        
        public init(page: Int, results: [CodableLocalMovie]) {
            self.page = page
            self.results = results
        }
        
        func mapToLocalMovieRoot() -> LocalMovieRoot {
            return LocalMovieRoot(page: page, results: results.map { getLocalMovieRoot(codableLocalMovie: $0) })
        }
        
        private func getLocalMovieRoot(codableLocalMovie: CodableLocalMovie) -> LocalMovie {
            return LocalMovie(posterPath: codableLocalMovie.posterPath,
                              overview: codableLocalMovie.overview,
                              releaseDate: codableLocalMovie.releaseDate,
                              genreIds: codableLocalMovie.genreIds,
                              id: codableLocalMovie.id,
                              title: codableLocalMovie.title,
                              popularity: codableLocalMovie.popularity,
                              voteCount: codableLocalMovie.voteCount,
                              voteAverage: codableLocalMovie.voteAverage)
        }
    }
    
    private struct CodableLocalMovie: Codable {
        public let posterPath: String?
        public let overview: String
        public let releaseDate: String
        public let genreIds: [Int]
        public let id: Int
        public let title: String
        public let popularity: Double
        public let voteCount: Int
        public let voteAverage: Double
        
        public init(localMovie: LocalMovie) {
            self.posterPath = localMovie.posterPath
            self.overview = localMovie.overview
            self.releaseDate = localMovie.releaseDate
            self.genreIds = localMovie.genreIds
            self.id = localMovie.id
            self.title = localMovie.title
            self.popularity = localMovie.popularity
            self.voteCount = localMovie.voteCount
            self.voteAverage = localMovie.voteAverage
        }
    }
    
    private struct Cache: Codable {
        let timestamp: Date
        let movieRoot: CodableLocalMovieRoot
    }
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func deleteCache(completion: @escaping (Error?) -> Void) {
        
    }
    
    func insert(movieRoot: LocalMovieRoot, timestamp: Date, completion: @escaping (Error?) -> Void) {
        let encoder = JSONEncoder()
        let codableMovieRoot = CodableLocalMovieRoot(page: movieRoot.page,
                                                     results: movieRoot.results.map { CodableLocalMovie(localMovie: $0) })
        let encoded = try! encoder.encode(Cache(timestamp: timestamp, movieRoot: codableMovieRoot))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
    
    func retrieve(completion: @escaping (Result<(LocalMovieRoot?, Date?), Error>) -> Void) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.success((nil, nil)))
            return
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.success((cache.movieRoot.mapToLocalMovieRoot(), cache.timestamp)))
    }
}

class CodableMovieStoreTests: XCTestCase {
    
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
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for movie retrieval")
        let insertedLocalMovieRoot = LocalMovieRoot(page: 1,
                                                    results: [LocalMovie(posterPath: "",
                                                                   overview: "",
                                                                   releaseDate: "",
                                                                   genreIds: [1],
                                                                   id: 1,
                                                                   title: "",
                                                                   popularity: 1.0,
                                                                   voteCount: 1,
                                                                   voteAverage: 1.0)])
        let insertedTimestamp = Date()
        
        sut.insert(movieRoot: insertedLocalMovieRoot, timestamp: insertedTimestamp) { error in
            XCTAssertNil(error, "Expected movieRoot to be inserted successfully")
            
            sut.retrieve { result in
                switch result {
                case let .success((localMovieRoot, timestamp)):
                    XCTAssertEqual(localMovieRoot, insertedLocalMovieRoot)
                    XCTAssertEqual(timestamp, insertedTimestamp)
                default:
                    XCTFail("Expected success got \(result)")
                }
                exp.fulfill()
            }
        }
        
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT() -> CodableMovieStore {
        let sut = CodableMovieStore(storeURL: testSpecificStoreURL())
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory,
                                        in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
