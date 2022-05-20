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
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.success((cache.movieRoot.mapToLocalMovieRoot(), cache.timestamp)))
        } catch {
            completion(.failure(error))
        }
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
        
        expect(sut: sut, withResult: .success((nil, nil)))
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCacheWhenCalledTwice() {
        let sut = makeSUT()
        
        expectToRetrieveTwice(sut: sut, withLocalMovieRoot: nil, andTimestamp: nil)
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
    
    private func insert(sut: CodableMovieStore, localMovieRoot: LocalMovieRoot, timestamp: Date) -> Error? {
        let exp = expectation(description: "Wait for movie insertion")
        var receivedError: Error?
        
        sut.insert(movieRoot: localMovieRoot, timestamp: timestamp) { error in
            receivedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func expectToRetrieveTwice(sut: CodableMovieStore,
                                       withLocalMovieRoot expectedLocalMovieRoot: LocalMovieRoot?,
                                       andTimestamp expectedTimestamp: Date?,
                                       file: StaticString = #file,
                                       line: UInt = #line) {
        expect(sut: sut, withResult: .success((expectedLocalMovieRoot, expectedTimestamp)))
        expect(sut: sut, withResult: .success((expectedLocalMovieRoot, expectedTimestamp)))

    }
    
    private func expect(sut: CodableMovieStore,
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
    
    private func makeSUT(url: URL? = nil) -> CodableMovieStore {
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
