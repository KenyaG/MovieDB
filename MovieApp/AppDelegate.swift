//
//  AppDelegate.swift
//  MovieApp
//
//  Created by Kenya Gordon on 9/28/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import UIKit
import MovieDB
import GrubFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureLoggers()
        fetchMovieGenres()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    private func configureLoggers() {
           let loggerEnvironmentVariables = [
               "LOGGER_LEVELS_GHF_NETWORK": GrubFoundation.networkingLoggerConfiguration,
           ]
           let environment = ProcessInfo.processInfo.environment
           // Set up our destination to be standard error
           let consoleDestination = TextLoggerDestination.standardError()
           // Set up our log message formatter to use the log message and date formats from the
           // environment
           let formatter = LogMessageFormatter()
           consoleDestination.formatter = formatter
           if let format = environment["LOGGER_LOG_MESSAGE_FORMAT"], !format.isEmpty {
               formatter.logMessageFormat = format
           }
           if let format = environment["LOGGER_DATE_FORMAT"], !format.isEmpty {
               formatter.dateFormatter.dateFormat = format
           }
           // Set up our loggers' loggable levels by reading them from the environment
           for (variable, logger) in loggerEnvironmentVariables {
               logger.loggableLevels = Logger.LoggableLevels(environment[variable] ?? "")
               logger.destinations = [consoleDestination]
           }
       }


    func fetchMovieGenres() {
        let provider = MovieDBProvider()
        let dataSource = provider.genreDataSource()
        dataSource.fetchGenres(genreType: .movie) { (result) in
            dump(result)
        }
    }
}




    //Mechanical way
//    func fetchGenres() {
//        let client = MovieDBClient()
//        client.loadData(for: FetchGenresRequest()) { (result) in
//            dump(result)
//        }
//    }
