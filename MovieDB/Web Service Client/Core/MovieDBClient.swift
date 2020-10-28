//
//  MovieDBClient.swift
//  MovieApp
//
//  Created by Kenya Gordon on 10/4/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation
import GrubFoundation

internal typealias MovieDBClient = WebServiceClient<
    AuthenticatingHTTPClient<URLSession, MovieDBAuthenticator>,
    SingleBaseURLConfiguration
>


internal extension MovieDBClient {
    convenience init() {
        self.init(
            authenticatingHTTPClient: AuthenticatingHTTPClient(
                urlSession: .shared,
                authenticator: MovieDBAuthenticator()
            ),
            baseURLConfiguration: SingleBaseURLConfiguration(url: URL(string: "https://api.themoviedb.org/3/")!)
        )
    }
}
