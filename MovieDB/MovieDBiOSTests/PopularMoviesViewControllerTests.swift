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
    
    func test_loadMoviesCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (sut, loader) = makeSUT()
        let movie = makeUniqueMovie()
        sut.loadViewIfNeeded()
        
        loader.complete(withMovieRoot: MovieRoot(page: 1, results: [movie]), at: 0)
        loader.complete(withError: anyError(), at: 0)
        
        assertThat(sut: sut, isRendering: [movie], at: 0)
    }
    
    func test_loadMoviesCompletion_loadsImageURLWhenVisible() {
        let (sut, loader) = makeSUT()
        let movie = makeUniqueMovie()
        
        sut.loadViewIfNeeded()
        loader.complete(withMovieRoot: MovieRoot(page: 1, results: [movie]), at: 0)
        XCTAssertEqual(loader.loadedURLs, [])
        
        sut.simulateCellVisible(at: 0)
        loader.complete(withImageData: Data(), at: 0)
        XCTAssertTrue(loader.loadedURLs[0]!.absoluteString.contains(movie.posterPath!))
    }
    
    func test_loadMovies_cancelsImageLoadingWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let movie = makeUniqueMovie()
        
        sut.loadViewIfNeeded()
        loader.complete(withMovieRoot: MovieRoot(page: 1, results: [movie]), at: 0)
        XCTAssertEqual(loader.loadedURLs, [])
        
        sut.simulateCellVisible(at: 0)
        loader.complete(withImageData: Data(), at: 0)
        sut.simulateNotVisibleCell(at: 0)
        
        XCTAssertTrue(loader.cancelledImageUrls[0]!.absoluteString.contains(movie.posterPath!))
    }
    
    func test_loadMovies_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        let movie = makeUniqueMovie()
        let imageData = UIImage.make(withColor: .red).pngData()!
        
        sut.loadViewIfNeeded()
        loader.complete(withMovieRoot: MovieRoot(page: 1, results: [movie]), at: 0)
        let cell = sut.simulateCellVisible(at: 0)
        loader.complete(withImageData: imageData, at: 0)
        
        XCTAssertEqual(cell.renderedImage(), imageData)
    }
    
    func test_loadMovies_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        let movie = makeUniqueMovie()
        let exp = expectation(description: "Wait for background queue")
        sut.loadViewIfNeeded()
        
        DispatchQueue.global().async {
            loader.complete(withMovieRoot: MovieRoot(page: 1, results: [movie]), at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
        let movieLoader = MovieLoaderSpy()
        let viewController = MovieDBUICreator.popularMoviesCreatedWith(loader: movieLoader, imageDataLoader: movieLoader)
        return (viewController, movieLoader)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "domain", code: 0, userInfo: nil)
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
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
    
    func simulateNotVisibleCell(at index: Int) {
        let cell = simulateCellVisible(at: index)
        let delegate = tableView.delegate
        
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: IndexPath(row: index, section: movieSection))
    }
    
    @discardableResult
    func simulateCellVisible(at index: Int) -> MovieTableViewCell {
        let datasource = tableView.dataSource
        let cell = datasource?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: movieSection))
        return cell as! MovieTableViewCell
    }
    
    private var movieSection: Int {
        return 0
    }
}

private extension MovieTableViewCell {
    func renderedImage() -> Data? {
        return thumbnail.image?.pngData()
    }
}

class MovieLoaderSpy: MovieLoader, MovieImageDataLoader {
    
    private struct TaskSpy: MovieImageDataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    
    var completions: [(MovieLoaderResult) -> Void] = []
    var loadImageCompletions: [(URL?,(Result<Data, Error>) -> Void)] = []
    var cancelledImageUrls: [URL?] = []
    var loadedURLs: [URL?] = []
    
    func load(completion: @escaping (MovieLoaderResult) -> Void) {
        completions.append(completion)
    }
    
    func complete(withMovieRoot movieRoot: MovieRoot, at index: Int) {
        completions[index](.success(movieRoot))
    }
    
    func complete(withError error: Error, at index: Int) {
        completions[index](.failure(error))
    }
    
    func loadImageData(url: URL?, completion: @escaping (Result<Data, Error>) -> Void) -> MovieImageDataLoaderTask {
        loadImageCompletions.append((url, completion))
        return TaskSpy { [weak self] in
            self?.cancelledImageUrls.append(url)
        }
    }
    
    func complete(withImageData data: Data, at index: Int) {
        let (url, completion) = loadImageCompletions[index]
        loadedURLs.append(url)
        completion(.success(data))
    }
    
}
