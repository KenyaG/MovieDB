//
//  HTTPMethod.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 9/16/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `HTTPMethod`s represent HTTP methods. It is implemented as a typed extensible enum with out-of-the-box constants
/// for DELETE, GET, PATCH, POST, and PUT. Other HTTP methods can be added as needed using extensions.
public struct HTTPMethod : TypedExtensibleEnum {
    public let rawValue: String


    /// Creates a new instance with the specified HTTP method string. The string is automatically uppercased before
    /// being stored.
    ///
    /// - Parameter rawValue: The HTTP method string.
    public init(_ rawValue: String) {
        self.rawValue = rawValue.uppercased()
    }
}


public extension HTTPMethod {
    /// The HTTP DELETE method.
    static let delete = HTTPMethod("DELETE")

    /// The HTTP GET method.
    static let get = HTTPMethod("GET")

    /// The HTTP PATCH method.
    static let patch = HTTPMethod("PATCH")

    /// The HTTP POST method.
    static let post = HTTPMethod("POST")

    /// The HTTP PUT method.
    static let put = HTTPMethod("PUT")
}


public extension URLRequest {
    /// The `HTTPMethod` for the request.
    var httpRequestMethod: HTTPMethod? {
        get {
            return httpMethod.flatMap { HTTPMethod($0) }
        }

        set {
            httpMethod = newValue?.rawValue
        }
    }
}
