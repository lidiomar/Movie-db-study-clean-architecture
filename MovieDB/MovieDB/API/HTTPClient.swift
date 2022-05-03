//
//  HTTPClient.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 03/05/22.
//

import Foundation

public protocol HTTPClient {
    func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
}
