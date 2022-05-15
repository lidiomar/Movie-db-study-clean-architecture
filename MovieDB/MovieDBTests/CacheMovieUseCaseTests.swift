//
//  CacheMovieUseCaseTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 09/05/22.
//

import XCTest
import MovieDB

class CacheMovieUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, movieStore) = makeSUT()
        
        XCTAssertEqual(movieStore.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, movieStore) = makeSUT()
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        
        sut.save(movieRoot: movieRoot.model) { _ in }
        
        XCTAssertEqual(movieStore.receivedMessages, [.deletedCache])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, movieStore) = makeSUT()
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        
        sut.save(movieRoot: movieRoot.model) { _ in }
        movieStore.completeDeletion(withError: anyError())
        
        XCTAssertEqual(movieStore.receivedMessages, [.deletedCache])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        
        sut.save(movieRoot: movieRoot.model) { _ in }
        movieStore.completeDeletionWithSuccess()

        XCTAssertEqual(movieStore.receivedMessages, [.deletedCache, .insert((movieRoot.local, timestamp))])
    }
    
    func test_save_failOnDeletionError() {
        let timestamp = Date()
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        
        sut.save(movieRoot: movieRoot.model) { _ in }
        movieStore.completeDeletion(withError: anyError())
        
        XCTAssertEqual(movieStore.receivedMessages, [.deletedCache])
    }
    
    func test_save_failOnInsertionError() {
        let timestamp = Date()
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        let error = anyError()
        var receivedError: NSError?
        
        sut.save(movieRoot: movieRoot.model) { error in
            receivedError = error as NSError?
        }
        
        movieStore.completeDeletionWithSuccess()
        movieStore.completeInsertionWithError(error: anyError())
        
        XCTAssertEqual(receivedError, error)
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let timestamp = Date()
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        var receivedError: NSError?
        
        sut.save(movieRoot: movieRoot.model) { error in
            receivedError = error as NSError?
        }
        
        movieStore.completeDeletionWithSuccess()
        movieStore.completeInsertionWithSuccess()
        
        XCTAssertNil(receivedError)
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let movieStore = MovieStoreSpy()
        var sut: LocalMovieLoader? = LocalMovieLoader(movieStore: movieStore, timestamp: { Date() })
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        var receivedError: NSError?
        
        sut?.save(movieRoot: movieRoot.model) { error in
            receivedError = error as NSError?
        }
        sut = nil
        movieStore.completeDeletion(withError: anyError())
        
        XCTAssertNil(receivedError)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let movieStore = MovieStoreSpy()
        var sut: LocalMovieLoader? = LocalMovieLoader(movieStore: movieStore, timestamp: { Date() })
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        var receivedError: NSError?
        
        sut?.save(movieRoot: movieRoot.model) { error in
            receivedError = error as NSError?
        }
        
        movieStore.completeDeletionWithSuccess()
        sut = nil
        movieStore.completeInsertionWithError(error: anyError())
        
        XCTAssertNil(receivedError)
    }
    
    func test_load_requestCacheRetrieval() {
        let timestamp = Date()
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        
        sut.load() { _ in }
        
        XCTAssertEqual(movieStore.receivedMessages, [.retrieved])
    }
    
    func test_load_failsOnRetrievalError() {
        let timestamp = Date()
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        let error = anyError()
        
        expect(sut, toCompleteWith: .failure(error)) {
            movieStore.completeRetrieveWithError(error: error)
        }
    }
    
    func test_load_deliversNoDataWhenCacheIsEmpty() {
        let timestamp = Date()
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        
        expect(sut, toCompleteWith: .success(nil)) {
            movieStore.completeRetrieveSuccessfully(with: nil)
        }
    }
    
    func test_load_deliverDataSuccessfullyOnLessThanExpiredTimeForCache() {
        let timestamp = Date().minusFeedCacheMaxAge().adding(days: 1)
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        
        expect(sut, toCompleteWith: .success(movieRoot.model)) {
            movieStore.completeRetrieveSuccessfully(with: movieRoot.local)
        }
    }
    
    func test_load_deliversNoDataWhenCacheIsEqualOfCacheExpirationTime() {
        let timestamp = Date().minusFeedCacheMaxAge()
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        
        expect(sut, toCompleteWith: .success(nil)) {
            movieStore.completeRetrieveSuccessfully(with: movieRoot.local)
        }
    }
    
    func test_load_deliversNoDataWhenCacheIsExpired() {
        let timestamp = Date().minusFeedCacheMaxAge().adding(days: -1)
        let (sut, movieStore) = makeSUT(timestamp: { timestamp })
        let movieRoot = makeMovieRoot(page: 1, movies: [makeUniqueMovie(), makeUniqueMovie()])
        
        expect(sut, toCompleteWith: .success(nil)) {
            movieStore.completeRetrieveSuccessfully(with: movieRoot.local)
        }
    }
    
    func test_load_deletesCacheOnRetrievalError() {
        let (sut, movieStore) = makeSUT()
        
        sut.load { _ in }
        movieStore.completeRetrieveWithError(error: anyError())
        
        XCTAssertEqual(movieStore.receivedMessages, [.retrieved, .deletedCache])
    }
    
    func test_load_doesNotDeleteCacheOnNilCache() {
        let (sut, movieStore) = makeSUT()
        
        sut.load { _ in }
        movieStore.completeRetrieveSuccessfully(with: nil)
        
        XCTAssertEqual(movieStore.receivedMessages, [.retrieved])
    }
    
    func test_load_doesNotDeleteCacheOnValidExpirationPeriod() {
        let date = Date().minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, movieStore) = makeSUT(timestamp: { date })
        
        sut.load { _ in }
        movieStore.completeRetrieveSuccessfully(with: nil)
        
        XCTAssertEqual(movieStore.receivedMessages, [.retrieved])
    }
    
    func test_load_deleteCacheOnInvalidExpirationPeriod() {
        let date = Date().minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, movieStore) = makeSUT(timestamp: { date })
        
        sut.load { _ in }
        movieStore.completeRetrieveSuccessfully(with: nil)
        
        XCTAssertEqual(movieStore.receivedMessages, [.retrieved, .deletedCache])
    }
    
    func test_load_doesNotDeleverResultAfterSUTInstanceHasBeenDeallocated() {
        let movieStore = MovieStoreSpy()
        var sut: LocalMovieLoader? = LocalMovieLoader(movieStore: movieStore, timestamp: { Date() })
        
        sut?.load { result in
            XCTFail("Load should not be called after LocalMovieLoader be deallocated.")
        }
        sut = nil
        
        movieStore.completeRetrieveSuccessfully(with: nil)
    }
  
    private func expect(_ sut: LocalMovieLoader, toCompleteWith result: LocalMovieLoader.MovieLoaderResult, when action: () -> Void) {
        sut.load { receivedResult in
            switch (result, receivedResult) {
            case let (.success(resultMovieRoot), .success(receivedMovieRoot)):
                XCTAssertEqual(resultMovieRoot, receivedMovieRoot)
            case let (.failure(resultError as NSError), .failure(receivedError as NSError)):
                XCTAssertEqual(resultError, receivedError)
            default:
                XCTFail("Expected \(result) is not equal to \(receivedResult)")
            }
        }
        
        action()
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
    
    private func makeMovieRoot(page: Int, movies: [Movie]) -> (model: MovieRoot, local: LocalMovieRoot) {
        let localMovieRoot = LocalMovieRoot(page: page, results: movies.map { LocalMovie(posterPath: $0.posterPath,
                                                                                         overview: $0.overview,
                                                                                         releaseDate: $0.releaseDate,
                                                                                         genreIds: $0.genreIds,
                                                                                         id: $0.id,
                                                                                         title: $0.title,
                                                                                         popularity: $0.popularity,
                                                                                         voteCount: $0.voteCount,
                                                                                         voteAverage: $0.voteAverage) })
        let movieRoot = MovieRoot(page: page, results: movies)
        return (movieRoot, localMovieRoot)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "Domain", code: 0, userInfo: nil)
    }
}

private extension Date {
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
}

private class MovieStoreSpy: MovieStore {
    
    enum ReceivedMessage: Equatable {
        static func == (lhs: MovieStoreSpy.ReceivedMessage, rhs: MovieStoreSpy.ReceivedMessage) -> Bool {
            switch (lhs, rhs) {
            case (let .insert((movieLhs, dateLhs)), let .insert((movieRhs, dateRhs))):
                return movieLhs == movieRhs && dateLhs == dateRhs
            case (.deletedCache, .deletedCache):
                return true
            case (.retrieved, .retrieved):
                return true
            default:
                return false
            }
        }
        
        case insert((LocalMovieRoot, Date))
        case deletedCache
        case retrieved
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private var deleteCacheCompletions = [(Error?) -> Void]()
    private var insertCompletions = [(Error?) -> Void]()
    private var retrieveCompletions = [(Result<LocalMovieRoot?, Error>) -> Void]()
    
    func deleteCache(completion: @escaping (Error?) -> Void) {
        receivedMessages.append(.deletedCache)
        deleteCacheCompletions.append(completion)
    }
    
    func insert(movieRoot: LocalMovieRoot, timestamp: Date, completion: @escaping (Error?) -> Void) {
        receivedMessages.append(.insert((movieRoot, timestamp)))
        insertCompletions.append(completion)
    }
    
    func retrieve(completion: @escaping (Result<LocalMovieRoot?, Error>) -> Void) {
        receivedMessages.append(.retrieved)
        retrieveCompletions.append(completion)
    }
    
    func completeDeletion(withError error: NSError, at index: Int = 0) {
        deleteCacheCompletions[index](error)
    }
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        deleteCacheCompletions[index](nil)
    }
    
    func completeInsertionWithError(at index: Int = 0, error: NSError) {
        insertCompletions[index](error)
    }
    
    func completeInsertionWithSuccess(at index: Int = 0) {
        insertCompletions[index](nil)
    }
    
    func completeRetrieveWithError(at index: Int = 0, error: NSError) {
        retrieveCompletions[index](.failure(error))
    }
    
    func completeRetrieveSuccessfully(at index: Int = 0, with localMovieRoot: LocalMovieRoot?) {
        retrieveCompletions[index](.success(localMovieRoot))
    }
}
