//
//  HTTPURLResponse+StatusCode.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 02/06/22.
//

import Foundation

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
