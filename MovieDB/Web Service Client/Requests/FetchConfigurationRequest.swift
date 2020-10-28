//
//  FetchConfigurationRequest.swift
//  MovieDB
//
//  Created by Kenya Gordon on 10/18/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation
import GrubFoundation

internal struct FetchConfigurationRequest : WebServiceRequest {

    /// The type of authenticator that can authenticate requests of this type.
    public typealias Authenticator = MovieDBAuthenticator

    /// The type of base URL that can be used for requests of this type.
    public typealias BaseURLConfiguration = SingleBaseURLConfiguration

    public typealias Success = HTTPResponse<APIConfiguration>

    public let httpMethod: HTTPMethod = .get
    public let authenticationContext: MovieDBAuthenticator.Context = .authenticated

    public var pathComponents: [URLPathComponent] = ["configuration"]

    public var responseHandler: AnyHandler<HTTPResponse<Data>, HTTPResponse<APIConfiguration>> {
        let handler = HTTPStatusCodeFilter.notSuccess
            .chaining(JSONResponseTransformer<APIConfiguration>())
        return AnyHandler(handler)
    }
}
