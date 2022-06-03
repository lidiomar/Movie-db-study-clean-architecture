//
//  MovieLoaderWithFallbackComposite.swift
//  MovieDBAppTests
//
//  Created by Lidiomar Machado on 02/06/22.
//

import XCTest
import MovieDB
import MovieDBApp

class MovieLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_deliversPrimaryLoaderOnPrimarySuccess() {
        let primaryResult = MovieRoot(page: 1, results: [makeUniqueMovie()])
        let fallbackResult = MovieRoot(page: 2, results: [makeUniqueMovie()])
        let primaryLoader = MovieLoaderStub(resultStub: .success(primaryResult))
        let fallbackLoader = MovieLoaderStub(resultStub: .success(fallbackResult))
        let sut = MovieLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        let exp = expectation(description: "Wait for load")
        
        sut.load { result in
            switch result {
            case let .success(movieRoot):
                XCTAssertEqual(movieRoot, primaryResult)
            default:
                XCTFail("Expected success result \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversFallbackLoaderOnPrimaryFailure() {
        let fallbackResult = MovieRoot(page: 2, results: [makeUniqueMovie()])
        let primaryLoader = MovieLoaderStub(resultStub: .failure(NSError(domain: "domain", code: 0)))
        let fallbackLoader = MovieLoaderStub(resultStub: .success(fallbackResult))
        let sut = MovieLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        let exp = expectation(description: "Wait for load")
        
        sut.load { result in
            switch result {
            case let .success(movieRoot):
                XCTAssertEqual(movieRoot, fallbackResult)
            default:
                XCTFail("Expected success result \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversFailureOnFallbackFailure() {
        let primaryFailure = NSError(domain: "domain 1", code: 1)
        let fallbackFailure = NSError(domain: "domain 2", code: 2)
        let primaryLoader = MovieLoaderStub(resultStub: .failure(primaryFailure))
        let fallbackLoader = MovieLoaderStub(resultStub: .failure(fallbackFailure))
        let sut = MovieLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        let exp = expectation(description: "Wait for load")
        
        sut.load { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as NSError, fallbackFailure)
            default:
                XCTFail("Expected failure result \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeUniqueMovie() -> Movie {
        return Movie(posterPath: nil,
                     overview: "An overview",
                     releaseDate: "2018-09-09",
                     genreIds: [1, 2],
                     id: UUID().hashValue,
                     title: "a title",
                     popularity: 0.0,
                     voteCount: 0,
                     voteAverage: 0.0)
    }
}

private class MovieLoaderStub: MovieLoader {
    var resultStub: MovieLoaderResult
    
    init(resultStub: MovieLoaderResult) {
        self.resultStub = resultStub
    }
    
    func load(completion: @escaping (MovieLoaderResult) -> Void) {
        completion(resultStub)
    }
}
