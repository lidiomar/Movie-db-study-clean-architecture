//
//  DispatchMainQueueDecorator.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 01/06/22.
//

import Foundation
import MovieDB

final class DispatchMainQueueDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    private func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async(execute: completion)
            return
        }
        completion()
    }
}

extension DispatchMainQueueDecorator: MovieLoader where T == MovieLoader {
    func load(completion: @escaping (MovieLoaderResult) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
