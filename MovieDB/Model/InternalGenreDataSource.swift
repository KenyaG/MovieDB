//
//  InternalGenreDataSource.swift
//  MovieDB
//
//  Created by Kenya Gordon on 10/11/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation

public protocol GenreDataSource {
    func fetchGenres(genreType: GenreType, completion: @escaping (Result<[Genre], Error>) -> Void)
}

final class InternalGenreDataSource: GenreDataSource {
    let serviceClient: MovieDBClient
    init(serviceClient: MovieDBClient) {
        self.serviceClient = serviceClient
    }
    
    func fetchGenres(genreType: GenreType, completion: @escaping (Result<[Genre], Error>) -> Void) {
        serviceClient.fetchGenres(genreType: genreType) { (result) in
            completion(result.map { $0.body })
        }
    }
}
