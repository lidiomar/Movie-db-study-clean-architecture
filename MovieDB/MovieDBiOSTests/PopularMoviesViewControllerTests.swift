//
//  PopularMoviesViewControllerTests.swift
//  MovieDBiOSTests
//
//  Created by Lidiomar Machado on 29/05/22.
//

import XCTest
import MovieDB
@testable import MovieDBiOS

class PopularMoviesViewControllerTests: XCTestCase {

    func test_loadMovies_requestMoviesFromLoader() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.completions.count, 1)
    }
    
    func test_loadMoviesCompletion_rendersSuccessfullyLoadedMovies() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfRenderedMovies(), 0)
        
        loader.complete(withMovieRoot: MovieRoot(page: 1, results: [makeUniqueMovie()]), at: 0)
        
        XCTAssertEqual(sut.numberOfRenderedMovies(), 1)
    }
    
    private func makeSUT() -> (PopularMoviesViewController, MovieLoaderSpy) {
        let spy = MovieLoaderSpy()
        let viewModel = PopularMoviesViewModel(movieLoader: spy)
        let popularMoviesViewController = PopularMoviesViewController(viewModel: viewModel)
        return (popularMoviesViewController, spy)
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

private extension PopularMoviesViewController {
    
    func numberOfRenderedMovies() -> Int {
        tableView.numberOfRows(inSection: movieSection)
    }
    
    private var movieSection: Int {
        return 0
    }
}

class MovieLoaderSpy: MovieLoader {
    var completions: [(MovieLoaderResult) -> Void] = []
    
    func load(completion: @escaping (MovieLoaderResult) -> Void) {
        completions.append(completion)
    }
    
    func complete(withMovieRoot movieRoot: MovieRoot, at index: Int) {
        completions[index](.success(movieRoot))
    }
}
