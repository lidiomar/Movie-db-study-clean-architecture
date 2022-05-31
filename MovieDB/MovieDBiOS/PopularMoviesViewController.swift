//
//  PopularMoviesViewController.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 29/05/22.
//

import UIKit
import MovieDB

protocol MovieImageDataLoader {
    func loadImageData(url: URL, completion: (Result<Data, Error>) -> Void)
}

class PopularMoviesViewController: UITableViewController {
    var viewModel: PopularMoviesViewModel?
    
    private var movies: [MovieModel] = [] {
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
            self?.movies = movies
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
        cell.popularity.text = movie.popularity
        cell.title.text = movie.title
        cell.score.text = movie.score
        cell.releaseYear.text = movie.releaseYear
        
        return cell
    }
}
