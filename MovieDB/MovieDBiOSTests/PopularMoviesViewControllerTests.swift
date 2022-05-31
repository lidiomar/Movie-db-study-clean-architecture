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
        let movie = makeUniqueMovie()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfRenderedMovies(), 0)
        
        loader.complete(withMovieRoot: MovieRoot(page: 1, results: [movie]), at: 0)
        
        XCTAssertEqual(sut.numberOfRenderedMovies(), 1)
        
        assertThat(sut: sut, isRendering: [movie], at: 0)
    }
    
    private func assertThat(sut: PopularMoviesViewController, isRendering movies: [Movie], at index: Int) {
       
        guard let cell = sut.movieCellAt(row: index),
              let movieTableViewCell = cell as? MovieTableViewCell else { return }
        
        movies.forEach {
            XCTAssertEqual(movieTableViewCell.title.text, $0.title)
            XCTAssertEqual(movieTableViewCell.popularity.text, String($0.popularity))
            XCTAssertEqual(movieTableViewCell.releaseYear.text, $0.releaseDate)
            XCTAssertEqual(movieTableViewCell.score.text, String($0.voteAverage))
        }
        
    }
    
    private func makeSUT() -> (PopularMoviesViewController, MovieLoaderSpy) {
        let spy = MovieLoaderSpy()
        let viewModel = PopularMoviesViewModel(movieLoader: spy)
        let storyboard = UIStoryboard(name: "Movie", bundle: Bundle(for: PopularMoviesViewController.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "PopularMoviesViewController") as! PopularMoviesViewController
    
        viewController.viewModel = viewModel
        return (viewController, spy)
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
    
    func movieCellAt(row: Int) -> UITableViewCell? {
        let datasource = tableView.dataSource
        return datasource?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: movieSection))
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
