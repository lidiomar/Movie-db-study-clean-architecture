//
//  MovieDBUICreator.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 01/06/22.
//

import Foundation
import MovieDB
import UIKit

public final class MovieDBUICreator {
    
    public static func popularMoviesCreatedWith(loader: MovieLoader, imageDataLoader: MovieImageDataLoader) -> PopularMoviesViewController {
        let viewModel = PopularMoviesViewModel(movieLoader: loader)
        let storyboard = UIStoryboard(name: "Movie", bundle: Bundle(for: PopularMoviesViewController.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "PopularMoviesViewController") as! PopularMoviesViewController
    
        viewController.viewModel = viewModel
        viewController.imageDataLoader = imageDataLoader
        return viewController
    }
}
