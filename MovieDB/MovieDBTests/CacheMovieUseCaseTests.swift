//
//  CacheMovieUseCaseTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 09/05/22.
//

import XCTest

protocol MovieStore {}

class LocalMovieLoader {
    
    private var movieStore: MovieStore
    
    init(movieStore: MovieStore) {
        self.movieStore = movieStore
    }
    
}

class CacheMovieUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, movieStore) = makeSUT()
        
        XCTAssertEqual(movieStore.receivedMessages, [])
    }
    
    private func makeSUT() -> (LocalMovieLoader, MovieStoreSpy) {
        let movieStoreSpy = MovieStoreSpy()
        let localMovieLoader = LocalMovieLoader(movieStore: movieStoreSpy)
        
        return (localMovieLoader, movieStoreSpy)
    }
    
}


private class MovieStoreSpy: MovieStore {
    enum ReceivedMessage: Equatable {
        case insert
        case deleteCache
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
}
