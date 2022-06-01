//
//  PopularMoviesMapperTests.swift
//  MovieDBiOSTests
//
//  Created by Lidiomar Machado on 31/05/22.
//

import XCTest
import MovieDB
@testable import MovieDBiOS

class PopularMoviesMapperTests: XCTestCase {
    
    func test_toMovieModel_retrieveConvertedMovieToMovieModel() {
        let path = "/posterPath"
        let overview = "An overview"
        let releaseDate = "2018-09-09"
        let genreIds = [1, 2]
        let id = UUID().hashValue
        let title = "a title"
        let popularity = 0.0
        let voteCount = 0
        let urlString = "\(Constants.baseImageURL)\(Constants.imageWidth)\(path)"
        
        let movie = makeUniqueMovie(posterPath: path,
                                    overview: overview,
                                    releaseDate: releaseDate,
                                    genreIds: genreIds,
                                    id: id,
                                    title: title,
                                    popularity: popularity,
                                    voteCount: voteCount)
        
        let movieModels = PopularMoviesMapper.toMovieModel([movie])
        
        XCTAssertEqual(movieModels.first!.thumbnailURL!.absoluteString, urlString, "Expected \(urlString)")
        XCTAssertEqual(movieModels.first!.releaseYear, releaseDate, "Expected \(releaseDate)")
        XCTAssertEqual(movieModels.first!.title, title, "Expected \(title)")
        XCTAssertEqual(movieModels.first!.popularity, String(popularity), "Expected \(popularity)")
    }
}
