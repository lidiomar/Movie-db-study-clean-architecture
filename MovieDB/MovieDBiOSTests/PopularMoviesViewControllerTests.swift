//
//  PopularMoviesViewControllerTests.swift
//  MovieDBiOSTests
//
//  Created by Lidiomar Machado on 29/05/22.
//

import XCTest
import MovieDB
import MovieDBiOS

class PopularMoviesViewControllerTests: XCTestCase {

    func test_loadMovies_requestMoviesFromLoader() {
        let (sut, spy) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(spy.completions.count, 1)
    }
    
    private func makeSUT() -> (PopularMoviesViewController, MovieLoaderSpy) {
        let spy = MovieLoaderSpy()
        let popularMoviesViewController = PopularMoviesViewController(loader: spy)
        return (popularMoviesViewController, spy)
    }
}

class MovieLoaderSpy: MovieLoader {
    var completions: [(MovieLoaderResult) -> Void] = []
    
    func load(completion: @escaping (MovieLoaderResult) -> Void) {
        completions.append(completion)
    }
}
