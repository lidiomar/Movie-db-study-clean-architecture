//
//  MovieLoaderWithCacheSavingComposite.swift
//  MovieDBAppTests
//
//  Created by Lidiomar Machado on 03/06/22.
//

import Foundation
import XCTest
import MovieDB

protocol MovieCache {
    func save(movieRoot: MovieRoot, completion: @escaping (Error?) -> Void)
}

class MovieLoaderWithCacheDecorator: MovieLoader {
    
    private var decoratee: MovieLoader
    private var cache: MovieCache
    
    init(decoratee: MovieLoader, cache: MovieCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (MovieLoaderResult) -> Void) {
        decoratee.load { [weak self] result in
            completion(result)
            guard let movieRoot = try? result.get() else { return }
            self?.cache.save(movieRoot: movieRoot) { _ in }
        }
    }
}

class MovieLoaderWithCacheDecoratorTests: XCTestCase {
    
    func test_load_deliversSuccessOnDecorateeSuccess() {
        let movieRoot = MovieRoot(page: 1, results: [makeUniqueMovie()])
        let sut = makeSUT(result: .success(movieRoot))
        
        expect(sut: sut, with: .success(movieRoot))
    }

    
    func test_load_deliversFailureOnDecorateeFailure() {
        let error = NSError(domain: "domain", code: 1, userInfo: nil)
        let sut = makeSUT(result: .failure(error))
        
        expect(sut: sut, with: .failure(error))
    }
    
    func test_load_saveOnCacheOnDecorateeSuccess() {
        let movieRoot = MovieRoot(page: 1, results: [makeUniqueMovie()])
        let cache = MovieCacheSpy()
        let sut = makeSUT(result: .success(movieRoot), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.cacheMovies, [movieRoot])
    }

    private func expect(sut: MovieLoader, with expectedResult: MovieLoader.MovieLoaderResult) {
        let exp = expectation(description: "Wait for load")
        
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(receivedMovieRoot), .success(expectedMovieRoot)):
                XCTAssertEqual(receivedMovieRoot, expectedMovieRoot)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Expected success, got \(result) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(result: MovieLoader.MovieLoaderResult, cache: MovieCacheSpy = MovieCacheSpy.init()) -> MovieLoader {
        let loader = MovieLoaderStub(result: result)
        let sut = MovieLoaderWithCacheDecorator(decoratee: loader, cache: cache)
        return sut
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
    
    private class MovieLoaderStub: MovieLoader {
        var result: MovieLoaderResult
        
        init(result: MovieLoaderResult) {
            self.result = result
        }
        
        func load(completion: @escaping (MovieLoaderResult) -> Void) {
            completion(result)
        }
    }
    
    private class MovieCacheSpy: MovieCache {
        var cacheMovies: [MovieRoot] = []
        func save(movieRoot: MovieRoot, completion: @escaping (Error?) -> Void) {
            cacheMovies.append(movieRoot)
        }
    }
}
