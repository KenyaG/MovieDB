//
//  FetchGenresRequest.swift
//  MovieDB
//
//  Created by Kenya Gordon on 10/5/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation
import GrubFoundation

internal struct FetchGenresRequest : WebServiceRequest {

    /// The type of authenticator that can authenticate requests of this type.
    public typealias Authenticator = MovieDBAuthenticator

    /// The type of base URL that can be used for requests of this type.
    public typealias BaseURLConfiguration = SingleBaseURLConfiguration

    public typealias Success = HTTPResponse<[Genre]>

    public var genreType: GenreType

     public init (genreType: GenreType) {
        self.genreType = genreType
    }

    public let httpMethod: HTTPMethod = .get
    public let authenticationContext: MovieDBAuthenticator.Context = .authenticated

    public var pathComponents: [URLPathComponent] {
        return ["genre", URLPathComponent(genreType.rawValue), "list"]
    }

    public var responseHandler: AnyHandler<HTTPResponse<Data>, HTTPResponse<[Genre]>> {
        let handler = HTTPStatusCodeFilter.notSuccess
            .chaining(JSONResponseTransformer<[Genre]>(rootObjectKey: GenreCodingKeys.genres))
        return AnyHandler(handler)
    }
}

private enum GenreCodingKeys : String, CodingKey {
    case genres
}

public enum GenreType: String {
    case movie = "movie"
    case tv = "tv"
}
