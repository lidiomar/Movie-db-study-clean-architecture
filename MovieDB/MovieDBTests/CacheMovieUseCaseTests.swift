//
//  CacheMovieUseCaseTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 09/05/22.
//

import XCTest
import MovieDB

protocol MovieStore {
    func deleteCache(completion: @escaping (Error?) -> Void)
    func insert(movieRoot: MovieRoot, completion: @escaping (Error?) -> Void)
}

class LocalMovieLoader {
    
    private var movieStore: MovieStore
    
    init(movieStore: MovieStore) {
        self.movieStore = movieStore
    }
    
    func save(movieRoot: MovieRoot) {
        movieStore.deleteCache() { [unowned self] error in
            if error == nil {
                self.movieStore.insert(movieRoot: movieRoot) { _ in }
            }
        }
    }
    
}

class CacheMovieUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, movieStore) = makeSUT()
        
        XCTAssertEqual(movieStore.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, movieStore) = makeSUT()
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        
        sut.save(movieRoot: movieRoot)
        
        XCTAssertEqual(movieStore.receivedMessages, [.deletedCache])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, movieStore) = makeSUT()
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        
        sut.save(movieRoot: movieRoot)
        movieStore.completeDeletion(withError: anyError(), at: 0)
        
        XCTAssertEqual(movieStore.receivedMessages, [.deletedCache])
    }
    
    private func makeSUT() -> (LocalMovieLoader, MovieStoreSpy) {
        let movieStoreSpy = MovieStoreSpy()
        let localMovieLoader = LocalMovieLoader(movieStore: movieStoreSpy)
        
        return (localMovieLoader, movieStoreSpy)
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
    
    private func makeMovieRoot(page: Int, movies: [Movie]) -> MovieRoot {
        return MovieRoot(page: page, results: movies)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "Domain", code: 0, userInfo: nil)
    }
}


private class MovieStoreSpy: MovieStore {
    
    enum ReceivedMessage: Equatable {
        case insert
        case deletedCache
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private var deleteCacheCompletions = [(Error?) -> Void]()
    
    func deleteCache(completion: @escaping (Error?) -> Void) {
        receivedMessages.append(.deletedCache)
        deleteCacheCompletions.append(completion)
    }
    
    func insert(movieRoot: MovieRoot, completion: @escaping (Error?) -> Void) {
        receivedMessages.append(.insert)
    }
    
    func completeDeletion(withError error: NSError, at index: Int) {
        deleteCacheCompletions[index](error)
    }
}
