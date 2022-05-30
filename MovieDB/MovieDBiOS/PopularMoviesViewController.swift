//
//  PopularMoviesViewController.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 29/05/22.
//

import UIKit
import MovieDB

public class PopularMoviesViewController: UIViewController {
    private var loader: MovieLoader?
    
    public convenience init(loader: MovieLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        loader?.load { _ in }
    }
}
