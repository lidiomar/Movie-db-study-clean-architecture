//
//  PopularMoviesViewModel.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 30/05/22.
//

import Foundation
import MovieDB

class PopularMoviesViewModel {
    private var movieLoader: MovieLoader
    
    var successMovieCompletion: (([MovieModel]) -> Void)?
    var errorMovieCompletion: ((Error) -> Void)?
    
    init(movieLoader: MovieLoader) {
        self.movieLoader = movieLoader
    }
    
    func loadMovie() {
        movieLoader.load { [weak self] result in
            switch result {
            case let .success(movieRoot):
                guard let movies = movieRoot?.results else {
                    self?.successMovieCompletion?([])
                    return
                }
                self?.successMovieCompletion?(movies.toMovieModel())
            case let .failure(error):
                self?.errorMovieCompletion?(error)
            }
        }
    }
}

private extension Array where Element == Movie {
    func toMovieModel() -> [MovieModel] {
        self.map { MovieModel(popularity: String($0.popularity),
                              title: $0.title,
                              score: String($0.voteAverage),
                              releaseYear: $0.releaseDate,
                              thumbnailURL: thumbURL(posterPath: $0.posterPath))}
    }
    
    private func thumbURL(posterPath: String?) -> URL? {
        guard let path = posterPath else {
            return nil
        }
        return URL(string: "\(baseImageURL)\(imageWidth)\(path)")
    }
    
    private var baseImageURL: String { "" }
    private var imageWidth: String { "" }
}
