//
//  SceneDelegate.swift
//  MovieDBApp
//
//  Created by Lidiomar Machado on 02/06/22.
//

import UIKit
import MovieDBiOS
import MovieDB
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private lazy var store: MovieStore = {
        try! CoreDataMovieStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("movie-store.sqlite"))
    }()
    
    private let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=44bc59c6e912b1afda251960c4f46658&language=en-US&page=1")!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let httpClient = URLSessionHTTPClient()
        let localMovieLoader = LocalMovieLoader(movieStore: store, timestamp: Date.init)
        let remoteMovieloader = RemoteMovieLoader(url: url, httpClient: httpClient)
        let remoteImageLoader = RemoteImageDataLoader(httpClient: httpClient)
        
        let removeMovieLoaderWithCacheFallback = MovieLoaderWithCacheDecorator(decoratee: remoteMovieloader, cache: localMovieLoader)
        let movieLoaderComposite = MovieLoaderWithFallbackComposite(primaryLoader: removeMovieLoaderWithCacheFallback, fallbackLoader: localMovieLoader)
        
        let popularMoviesViewController = MovieDBUICreator.popularMoviesCreatedWith(loader: movieLoaderComposite, imageDataLoader: remoteImageLoader)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = popularMoviesViewController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

