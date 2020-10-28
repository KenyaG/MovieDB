//
//  Base64URLEncodedValue.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 11/8/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `Base64URLEncodedValue` provides an interface via which any `DataConvertible` type can be automatically
/// encoded or decoded as a Base64URL-encoded string. `Base64URLEncodedValue` also conditionally conforms to
/// `Equatable` and `Hashable` if `Value` does.
public struct Base64URLEncodedValue<Value> : Codable where Value : DataConvertible {
    /// The wrapped value.
    public let value: Value


    /// Creates a new `Base64URLEncodedValue` that wraps the specified value.
    ///
    /// - Parameter value: The value to wrap.
    public init(value: Value) {
        self.value = value
    }


    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let base64URLEncoded = try container.decode(String.self)

        guard let data = Data(base64URLEncoded: base64URLEncoded), let value = Value(data: data) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "string is not base64url encoded \(Value.self)")
        }

        self.value = value
    }


    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.data.base64URLEncodedString)
    }
}


extension Base64URLEncodedValue : Equatable where Value : Equatable { }
extension Base64URLEncodedValue : Hashable where Value : Hashable { }
