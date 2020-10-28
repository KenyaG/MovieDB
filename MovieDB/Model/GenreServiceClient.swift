//
//  GenreServiceClient.swift
//  MovieDB
//
//  Created by Kenya Gordon on 10/11/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation
import GrubFoundation

internal protocol GenreServiceClient {
    func fetchGenres(genreType: GenreType, completion: @escaping (Result<HTTPResponse<[Genre]>, Error>) -> Void)
}

extension MovieDBClient: GenreServiceClient {
    public func fetchGenres(genreType: GenreType, completion: @escaping (Result<HTTPResponse<[Genre]>, Error>) -> Void) {
        loadData(for: FetchGenresRequest(genreType: genreType), completion: completion)
    }
}
