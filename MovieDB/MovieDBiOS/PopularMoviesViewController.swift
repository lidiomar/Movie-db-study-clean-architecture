//
//  PopularMoviesViewController.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 29/05/22.
//

import UIKit
import MovieDB

class PopularMoviesViewController: UITableViewController {
    private var viewModel: PopularMoviesViewModel?
    private var movies: [Movie] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    convenience init(viewModel: PopularMoviesViewModel) {
        self.init()
        self.viewModel = viewModel
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
        return UITableViewCell()
    }
}
