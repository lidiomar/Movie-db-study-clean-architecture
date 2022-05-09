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
    func insert(movieRoot: MovieRoot, timestamp: Date, completion: @escaping (Error?) -> Void)
}

class LocalMovieLoader {
    
    private var movieStore: MovieStore
    private var timestamp: () -> Date
    
    init(movieStore: MovieStore, timestamp: @escaping () -> Date) {
        self.movieStore = movieStore
        self.timestamp = timestamp
    }
    
    func save(movieRoot: MovieRoot) {
        movieStore.deleteCache() { [unowned self] error in
            if error == nil {
                self.movieStore.insert(movieRoot: movieRoot, timestamp: self.timestamp()) { _ in }
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
        movieStore.completeDeletion(withError: anyError())
        
        XCTAssertEqual(movieStore.receivedMessages, [.deletedCache])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        
        sut.save(movieRoot: movieRoot)
        movieStore.completeDeletionWithSuccess()

        XCTAssertEqual(movieStore.receivedMessages, [.deletedCache, .insert((movieRoot, timestamp))])
    }
    
    private func makeSUT(timestamp: @escaping (() -> Date) = {  Date() }) -> (LocalMovieLoader, MovieStoreSpy) {
        let movieStoreSpy = MovieStoreSpy()
        let localMovieLoader = LocalMovieLoader(movieStore: movieStoreSpy, timestamp: timestamp)
        
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
        static func == (lhs: MovieStoreSpy.ReceivedMessage, rhs: MovieStoreSpy.ReceivedMessage) -> Bool {
            switch (lhs, rhs) {
            case (let .insert((movieLhs, dateLhs)), let .insert((movieRhs, dateRhs))):
                return movieLhs == movieRhs && dateLhs == dateRhs
            default:
                return true
            }
        }
        
        case insert((MovieRoot, Date))
        case deletedCache
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private var deleteCacheCompletions = [(Error?) -> Void]()
    private var itemsInserted = [(MovieRoot, Date)]()
    
    func deleteCache(completion: @escaping (Error?) -> Void) {
        receivedMessages.append(.deletedCache)
        deleteCacheCompletions.append(completion)
    }
    
    func insert(movieRoot: MovieRoot, timestamp: Date, completion: @escaping (Error?) -> Void) {
        receivedMessages.append(.insert((movieRoot, timestamp)))
    }
    
    func completeDeletion(withError error: NSError, at index: Int = 0) {
        deleteCacheCompletions[index](error)
    }
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        deleteCacheCompletions[index](nil)
    }
}
