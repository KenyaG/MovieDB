//
//  ErrorTransformer.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 2/4/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `ErrorTransformer` is an analogue to `Transformer` that passes the value case through unmodified, but
/// transforms the error. This might be useful if an error case needs to be inspected further. For example, if an HTTP
/// error occurs due to an invalid status code, a subsequent transformer might inspect the HTTP body and convert the
/// generic invalid status code error to something more specific.
///
/// An implicit prerequisite to using an error transformer is that the errors being transformed should contain enough
/// information that there is something to transform. For example, `HTTPResponseError.invalidStatusCode` has an
/// associated `HTTPResponse<Data>` with data to transform.
public protocol ErrorTransformer : Handler where Input == Output {
    /// Transforms `error` into another error type.
    ///
    /// - Parameter input: The error to transform.
    /// - Returns: The transformed error.
    func transform(_ error: Error) -> Error
}


public extension ErrorTransformer {
    /// If `result` is a value, passes result to `completion`. Otherwise, calls `transform(_:)` with the result’s error
    /// as the input and wraps the resulting error in a `Result` which is then passed to `completion`.
    ///
    /// - Parameters:
    ///   - result: The result to handle.
    ///   - completion: The completion handler which is passed the transformer’s result after transformation.
    func handle(_ result: Result<Input, Error>, completion: @escaping (Result<Output, Error>) -> Void) {
        completion(result.mapError(transform(_:)))
    }
}


/// `AdHocErrorTransformer`s are used to conveniently create ad-hoc error transformers using closures to perform
/// error transformation.
public struct AdHocErrorTransformer<Value> : ErrorTransformer {
    public typealias Input = Value
    public typealias Output = Value

    /// The closure used to perform transformation. Its input is the instance’s input.
    public let body: (Error) -> Error


    /// Initializes an ad-hoc error transformer with the specified closure.
    ///
    /// - Parameter body: The closure used to perform error transformation.
    public init(body: @escaping (Error) -> Error) {
        self.body = body
    }


    public func transform(_ error: Error) -> Error {
        return body(error)
    }
}
