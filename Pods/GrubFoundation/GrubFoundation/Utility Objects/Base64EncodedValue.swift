//
//  Base64EncodedValue.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 11/5/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `Base64EncodedValue` provides an interface via which any `DataConvertible` type can be automatically encoded
/// or decoded as a Base64-encoded string. `Base64EncodedValue` also conditionally conforms to `Equatable` and
/// `Hashable` if `Value` does.
public struct Base64EncodedValue<Value> : Codable where Value : DataConvertible {
    /// The wrapped value.
    public let value: Value


    /// Creates a new `Base64EncodedValue` that wraps the specified value.
    ///
    /// - Parameter value: The value to wrap.
    public init(value: Value) {
        self.value = value
    }


    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let base64Encoded = try container.decode(String.self)

        guard let data = Data(base64Encoded: base64Encoded), let value = Value(data: data) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "string is not base64 encoded \(Value.self)")
        }

        self.value = value
    }


    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.data.base64EncodedString())
    }
}


extension Base64EncodedValue : Equatable where Value : Equatable { }
extension Base64EncodedValue : Hashable where Value : Hashable { }
