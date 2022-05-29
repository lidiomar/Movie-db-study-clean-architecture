//
//  MovieDBCacheIntegrationTests.swift
//  MovieDBCacheIntegrationTests
//
//  Created by Lidiomar Machado on 29/05/22.
//

import XCTest
import MovieDB

class MovieDBCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        deleteStoreArtifacts()
    }

    override func tearDown() {
        super.tearDown()

        deleteStoreArtifacts()
    }
    
    func test_deliverNoValuesWhenCacheIsEmpty() {
        let sut = makeSUT()
        
        expect(sut: sut, result: .success(nil))
    }
    
    func test_deliverValuesWhenCacheIsNotEmpty() {
        let sut = makeSUT()
        let movieRoot = makeMovieRoot()
        insertMovieRoot(sut, movieRoot: movieRoot)
        
        expect(sut: sut, result: .success(movieRoot))
    }
    
    func test_overridesValues() {
        let sut = makeSUT()
        let firstMovieRoot = makeMovieRoot()
        insertMovieRoot(sut, movieRoot: firstMovieRoot)
        let secondMovieRoot = makeMovieRoot(page: 2)
        insertMovieRoot(sut, movieRoot: secondMovieRoot)
        
        expect(sut: sut, result: .success(secondMovieRoot))
    }

    func test_deliverValuesWithDifferentInstances() {
        let firstSUT = makeSUT()
        let secondSUT = makeSUT()
        let movieRoot = makeMovieRoot()
        insertMovieRoot(firstSUT, movieRoot: movieRoot)
        
        expect(sut: secondSUT, result: .success(movieRoot))
    }
    
    func test_overrideValuesWithDifferentInstances() {
        let firstSUT = makeSUT()
        let secondSUT = makeSUT()
        let firstMovieRoot = makeMovieRoot()
        let secondMovieRoot = makeMovieRoot(page: 2)
        insertMovieRoot(firstSUT, movieRoot: firstMovieRoot)
        insertMovieRoot(secondSUT, movieRoot: secondMovieRoot)
        
        expect(sut: firstSUT, result: .success(secondMovieRoot))
    }
    
    private func expect(sut: LocalMovieLoader, result expectedResult: MovieLoader.MovieLoaderResult) {
        let exp = expectation(description: "Waiting for load")
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(movieRoot), .success(expectedMovieRoot)):
                XCTAssertEqual(movieRoot, expectedMovieRoot)
            default:
                XCTFail("Expect success with non values returned.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func insertMovieRoot(_ sut: LocalMovieLoader, movieRoot: MovieRoot) {
        let exp = expectation(description: "Waiting for save")
        
        sut.save(movieRoot: movieRoot) { error in
            if error != nil {
                XCTFail("Error when inserting movieRoot")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    private func makeSUT() -> LocalMovieLoader {
        let storeBundle = Bundle(for: CoreDataMovieStore.self)
        let storeURL = testSpecificStoreURL()
        let movieStore = try! CoreDataMovieStore(storeURL: storeURL, bundle: storeBundle)
        let movieLoader = LocalMovieLoader(movieStore: movieStore, timestamp: Date.init)
        return movieLoader
    }
    
    private func testSpecificStoreURL() -> URL {
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return storeURL.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func makeMovieRoot(page: Int = 1) -> MovieRoot {
        return MovieRoot(page: page, results: [makeUniqueMovie()])
    }
    
    private func makeUniqueMovie(posterPath: String = "",
                              overview: String = "",
                              releaseDate: String = "",
                              genreIds: [Int] = [1],
                              id: Int = UUID().hashValue,
                              title: String = "",
                              popularity: Double = 1.0,
                              voteCount: Int = 1,
                              voteAverage: Double = 1.0) -> Movie {
        
        return Movie(posterPath: posterPath,
                     overview: overview,
                     releaseDate: releaseDate,
                     genreIds: genreIds,
                     id: id,
                     title: title,
                     popularity: popularity,
                     voteCount: voteCount,
                     voteAverage: voteAverage)
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
