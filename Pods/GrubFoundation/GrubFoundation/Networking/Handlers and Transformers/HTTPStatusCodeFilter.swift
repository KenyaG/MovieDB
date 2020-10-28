//
//  HTTPStatusCodeFilter.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 4/2/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `HTTPStatusCodeFilter`s filter out HTTP responses whose status codes fulfill a rejection predicate. Its
/// `transform(_:)` method maps responses with those status codes to an invalid status code error:
/// `HTTPResponseError.invalidStatusCode(_)`. Other responses are simply passed through.
public struct HTTPStatusCodeFilter : Transformer {
    public typealias Input = HTTPResponse<Data>
    public typealias Output = HTTPResponse<Data>

    /// A status code filter that filters out any error status codes.
    public static let error = HTTPStatusCodeFilter { $0.isError }

    /// A status code filter that filters out any status codes that aren’t success.
    public static let notSuccess = HTTPStatusCodeFilter { !$0.isSuccess }

    /// A closure that returns whether an HTTP status code should be filtered out.
    public let rejectionPredicate: (HTTPStatusCode) -> Bool


    /// Initializes a new `HTTPStatusCodeFilter` with the specified rejection predicate closure.
    ///
    /// - Parameter rejectionPredicate: A closure that returns whether an HTTP status code should be mapped to an
    ///   invalid status code error.
    public init(rejectionPredicate: @escaping (HTTPStatusCode) -> Bool) {
        self.rejectionPredicate = rejectionPredicate
    }


    /// Initializes a new `HTTPStatusCodeFilter` that filters out status codes in `statusCodes`.
    ///
    /// - Parameter statusCodes: A set of status codes to filter out
    public init(statusCodes: Set<HTTPStatusCode>) {
        self.init { statusCodes.contains($0) }
    }


    public func transform(_ input: HTTPResponse<Data>) throws -> HTTPResponse<Data> {
        if rejectionPredicate(input.response.httpStatusCode) {
            throw HTTPResponseError.invalidStatusCode(input)
        }

        return input
    }
}
