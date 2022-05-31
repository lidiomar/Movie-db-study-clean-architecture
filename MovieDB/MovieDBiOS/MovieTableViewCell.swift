//
//  MovieTableViewCell.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 30/05/22.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    @IBOutlet private(set) var thumbnail: UIImageView!
    @IBOutlet private(set) var title: UILabel!
    @IBOutlet private(set) var popularity: UILabel!
    @IBOutlet private(set) var score: UILabel!
    @IBOutlet private(set) var releaseYear: UILabel!
}
