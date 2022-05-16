//
//  ValidCachePolicy.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 16/05/22.
//

import Foundation

final class ValidCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let numberOfDaysForCache = 7
    
    static func validTimeStamp(_ timestamp: Date, against date: Date) -> Bool {
      guard let maxCacheAge = calendar.date(byAdding: .day, value: numberOfDaysForCache, to: timestamp) else {
          return false
      }
      
      return date < maxCacheAge
    }
}
