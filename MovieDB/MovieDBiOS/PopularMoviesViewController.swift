//
//  PopularMoviesViewController.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 29/05/22.
//

import UIKit
import MovieDB

class PopularMoviesViewController: UITableViewController {
    var viewModel: PopularMoviesViewModel?
    
    private var movies: [Movie] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel?.loadMovie()
    }
    
    private func bindViewModel() {
        viewModel?.errorMovieCompletion = { error in
            print(error)
        }
        
        viewModel?.successMovieCompletion = { [weak self] movies in
            guard let results = movies?.results, !results.isEmpty else { return }
            self?.movies = results
        }
    }
}

extension PopularMoviesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieTableViewCell = tableView.dequeueReusableCell()
        let movie = movies[indexPath.row]
        cell.popularity.text = String(movie.popularity)
        cell.title.text = movie.title
        cell.score.text = String(movie.voteAverage)
        cell.releaseYear.text = movie.releaseDate
        return cell
    }
}
