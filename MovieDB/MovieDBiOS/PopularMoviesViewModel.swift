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
    
    var successMovieCompletion: ((MovieRoot?) -> Void)?
    var errorMovieCompletion: ((Error) -> Void)?
    
    init(movieLoader: MovieLoader) {
        self.movieLoader = movieLoader
    }
    
    func loadMovie() {
        movieLoader.load { [weak self] result in
            switch result {
            case let .success(movieRoot):
                self?.successMovieCompletion?(movieRoot)
            case let .failure(error):
                self?.errorMovieCompletion?(error)
            }
        }
    }
}
