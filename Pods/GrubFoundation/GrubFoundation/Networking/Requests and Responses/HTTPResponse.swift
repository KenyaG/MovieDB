//
//  HTTPResponse.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 8/18/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// Instances of `HTTPResponse` pair an `HTTPURLResponse` with a representation of the response’s body as a
/// particular type. This enables rich representations of an HTTP URL response to be passed downstream to interested
/// parties. For example, a chain of handlers may start by representing the body as `Data` but progressively transform
/// it into a generic JSON dictionary (`[String : Any]`) followed by an actual rich object. That rich object can then be
/// passed to the calling code along with the original HTTP URL response.
public struct HTTPResponse<Body> {
    /// The HTTP URL response with which the body is associated.
    public let response: HTTPURLResponse

    /// The body of the HTTP response.
    public let body: Body


    /// Initializes a new `HTTPResponse` with the specified HTTP URL response and body.
    ///
    /// - Parameters:
    ///   - response: The HTTP URL response, presumably as returned by the URL loading system.
    ///   - body: The body of the HTTP response.
    public init(response: HTTPURLResponse, body: Body) {
        self.response = response
        self.body = body
    }


    /// Returns a new `HTTPResponse` whose `response` is the same as this one, but whose `body` is the return value of
    /// `transform(body)`. This can be useful if you’re processing an HTTP body through successive transformations but
    /// want to continue passing the original HTTP URL response along with the transformed body.
    ///
    /// - Parameter transform: A closure that transforms `body`.
    /// - Returns: A new response with the same `HTTPURLResponse` as the instance’s, but with a transformed body.
    public func mapBody<TransformedBody>(_ transform: (Body) throws -> TransformedBody) rethrows -> HTTPResponse<TransformedBody> {
        return HTTPResponse<TransformedBody>(response: response, body: try transform(body))
    }
}


extension HTTPResponse : Equatable where Body : Equatable { }
extension HTTPResponse : Hashable where Body : Hashable { }
