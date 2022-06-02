//
//  RemoteMovieLoaderTests.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 03/05/22.
//

import XCTest
import MovieDB

class RemoteMovieLoaderTests: XCTestCase {
    
    func test_loader_requestURL() {
        let url = URL(string: "http://any-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        
        XCTAssertEqual(httpClient.urls, [url])
    }
    
    func test_loader_requestURLTwice() {
        let url = URL(string: "http://any-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        sut.load(completion: { _ in })
        
        XCTAssertEqual(httpClient.urls, [url, url])
    }
    
    func test_loader_deliversErrorOnClientError() {
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toCompleteWith: .connectionError) {
            httpClient.completeWith(error: NSError(domain: "test", code: 0), at: 0)
        }
    }
    
    func test_loader_deliversErrorOnNon200HTTPStatus() {
        let (sut, httpClient) = makeSUT()
        let httpSamples = [404, 401, 500, 502]
        
        httpSamples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .invalidData) {
                httpClient.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_loader_deliversNoItemsOn200HTTPStatusResponseWithEmptyResult() {
        let (sut, httpClient) = makeSUT()
        let json: [String: Any] = ["page": 1, "results": []]
        let data = try! JSONSerialization.data(withJSONObject: json)
        var captureMovies: [Movie] = []
        
        sut.load { result in
            switch result {
            case let .success(movieRoot):
                captureMovies = movieRoot!.results
            default:
                XCTFail("Expected success but got \(result)")
            }
        }
        
        httpClient.complete(withStatusCode: 200, at: 0, withData: data)
        XCTAssertEqual(captureMovies, [])
    }
    
    func test_loader_deliversItemsOn200HTTPStatusResponseWithResult() {
        let (sut, httpClient) = makeSUT()
        var capturedMovieRoot: MovieRoot?
        
        sut.load { result in
            switch result {
            case let .success(movieRoot):
                capturedMovieRoot = movieRoot
            default:
                XCTFail("Expected success but \(result) was retrieved")
            }
        }
        
        let result1 = makeResult(posterPath: "http://a-poster-path.com",
                                 overview: "An overview",
                                 releaseDate: "2016-08-03",
                                 genreIds: [0, 1, 2],
                                 id: 1,
                                 title: "Movie title",
                                 popularity: 3.0,
                                 voteCount: 150,
                                 voteAverage: 2.5)
        
        let result2 = makeResult(posterPath: "http://another-poster-path.com",
                                 overview: "Another overview",
                                 releaseDate: "2017-05-01",
                                 genreIds: [5],
                                 id: 2,
                                 title: "Another movie title",
                                 popularity: 3.0,
                                 voteCount: 100,
                                 voteAverage: 1.5)

        let popularMovieData = makePopularMovieData(page: 1, dataResults: [result1.dataModel, result2.dataModel], objectResults: [result1.objectModel, result2.objectModel])
        let data = popularMovieData.dataModel
        let obj = popularMovieData.objectModel
        
        httpClient.complete(withStatusCode: 200, at: 0, withData: data)
        
        XCTAssertEqual(obj, capturedMovieRoot)
    }
    
    func test_loader_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let httpClient = HTTPClientSpy()
        let url = URL(string: "http://any-url.com")!
        var sut: RemoteMovieLoader? = RemoteMovieLoader(url: url, httpClient: httpClient)

        sut?.load { _ in
            XCTFail("Completion was called after SUT has been deallocated.")
        }

        sut = nil
        httpClient.complete(withStatusCode: 200, at: 0)
    }
    
    private func makePopularMovieData(page: Int, dataResults: [[String: Any]], objectResults: [Movie]) -> (dataModel: Data, objectModel: MovieRoot) {
        let popularMovieData: [String: Any] = ["page": page,
                                               "results": dataResults]
        
        let movieRoot = MovieRoot(page: page, results: objectResults)
        
        let data = try! JSONSerialization.data(withJSONObject: popularMovieData)
        return (data, movieRoot)
    }
    
    private func makeResult(posterPath: String,
                            overview: String,
                            releaseDate: String,
                            genreIds: [Int],
                            id: Int,
                            title: String,
                            popularity: Double,
                            voteCount: Int,
                            voteAverage: Double) -> (dataModel: [String: Any], objectModel: Movie) {
        
        let dataModel: [String: Any] = ["poster_path": posterPath,
                         "overview": overview,
                         "release_date": releaseDate,
                         "genre_ids": genreIds,
                         "id": id,
                         "title": title,
                         "popularity": popularity,
                         "vote_count": voteCount,
                         "vote_average": voteAverage]
        
        let objectModel = Movie(posterPath: posterPath,
                          overview: overview,
                          releaseDate: releaseDate,
                          genreIds: genreIds,
                          id: id,
                          title: title,
                          popularity: popularity,
                          voteCount: voteCount,
                          voteAverage: voteAverage)
        
        return (dataModel, objectModel)
    }
    
    private func expect(_ sut: RemoteMovieLoader,
                        toCompleteWith result: RemoteMovieLoader.Error,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        var capture = [RemoteMovieLoader.Error]()
        
        sut.load { result in
            switch result {
            case let .failure(error):
                capture.append(error as! RemoteMovieLoader.Error)
            default:
                XCTFail("Expected failure but \(result) was found", file: file, line: line)
            }
        }
        
        action()
        
        XCTAssertEqual(capture, [result])
    }
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (RemoteMovieLoader, HTTPClientSpy) {
        let httpClientSpy = HTTPClientSpy()
        let sut = RemoteMovieLoader(url: url, httpClient: httpClientSpy)
        
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "\(String(describing: sut)) is not being deallocated, potential memory leak", file: file, line: line)
        }
        
        return (sut, httpClientSpy)
    }
}

class HTTPClientSpy: HTTPClient {
    private struct TaskSpy: HTTPClientTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    var urls: [URL] = []
    var completions: [(Result<(Data, HTTPURLResponse), Error>) -> Void] = []
    var cancelledImageUrls: [URL?] = []

    func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        urls.append(url)
        completions.append(completion)
        return TaskSpy { [weak self] in
            self?.cancelledImageUrls.append(url)
        }
    }
    
    func completeWith(error: Error, at index: Int) {
        completions[index](.failure(error))
    }
    
    func complete(withStatusCode statusCode: Int, at index: Int, withData data: Data = Data()) {
        let response = HTTPURLResponse(url: urls[index],
                                       statusCode: statusCode,
                                       httpVersion: nil,
                                       headerFields: nil)!
        completions[index](.success((data, response)))
    }
}
