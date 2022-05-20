//
//  FailableMovieStoreSpecs.swift
//  MovieDBTests
//
//  Created by Lidiomar Machado on 20/05/22.
//

import Foundation

protocol MovieStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectOnEmptyCacheWhenCalledTwice()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
    
    func test_insert_overridesPreviouslyInsertedCacheValues()
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    
    func test_delete_emptiesPreviouslyInsertedCache()
    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()


    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveMovieStoreSpecs: MovieStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertMovieStoreSpecs: MovieStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnFailure()
}

protocol FailableDeleteMovieStoreSpecs: MovieStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnFailure()
}

typealias FailableMovieStoreSpecs = FailableRetrieveMovieStoreSpecs & FailableInsertMovieStoreSpecs & FailableDeleteMovieStoreSpecs
