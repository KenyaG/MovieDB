//
//  MovieDBProviding.swift
//  MovieDB
//
//  Created by Kenya Gordon on 10/25/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation
import GrubFoundation

public protocol MovieDBProviding {
    func genreDataSource() -> GenreDataSource
}

public class MovieDBProvider: MovieDBProviding {
    private let movieDBClient: MovieDBClient

    init(movieDBClient: MovieDBClient) {
        self.movieDBClient = movieDBClient
    }

    public convenience init() {
        self.init(movieDBClient: MovieDBClient())
    }

    public func genreDataSource() -> GenreDataSource {
        return InternalGenreDataSource(serviceClient: self.movieDBClient)
    }
}
