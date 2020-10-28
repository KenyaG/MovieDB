//
//  JSONResponseTransformer.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 9/14/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `JSONResponseTransformer` uses `JSONDecoder` and the `Decodable` protocol to transform HTTP responses with JSON
/// bodies into rich objects. The output type is a `HTTPResponse` whose body is a type that conforms to `Decodable`.
public struct JSONResponseTransformer<DecodableOutput> : Transformer where DecodableOutput : Decodable {
    public typealias Input = HTTPResponse<Data>
    public typealias Output = HTTPResponse<DecodableOutput>

    /// The JSON decoder used to decode the HTTP response’s JSON body into an object.
    public let jsonDecoder: JSONDecoder

    /// The coding key at which to start decoding JSON. If `nil`, the entire JSON body is decoded. `nil` by default.
    public let rootObjectKey: AnyCodingKey?


    /// Initializes a new instance with the specified JSON decoder.
    ///
    /// - Parameter jsonDecoder: The JSON decoder used to decode the HTTP response’s JSON body into an object.
    public init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        self.rootObjectKey = nil
    }


    /// Initializes a new instance with the specified JSON decoder and root object key.
    ///
    /// - Parameters:
    ///   - jsonDecoder: The JSON decoder used to decode the HTTP response’s JSON body into an object.
    ///   - rootObjectKey: The key at which to begin decoding. Use this parameter if you wish to decode only one object
    ///     from a JSON body. This is useful when your top-level JSON body contains a single key, and you want to
    ///     exclude it from the decoded output.
    public init<Key>(jsonDecoder: JSONDecoder = JSONDecoder(), rootObjectKey: Key) where Key : CodingKey {
        self.jsonDecoder = jsonDecoder
        self.rootObjectKey = AnyCodingKey(rootObjectKey)
    }


    public func transform(_ input: HTTPResponse<Data>) throws -> HTTPResponse<DecodableOutput> {
        return try input.mapBody { (body) in
            if let rootObjectKey = rootObjectKey {
                return try jsonDecoder.decode(DecodableOutput.self, for: rootObjectKey, from: body)
            } else {
                return try jsonDecoder.decode(DecodableOutput.self, from: body)
            }
        }
    }
}
