//
//  JSONDecoder+SingleKey.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 7/12/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension JSONDecoder {
    /// Returns a value of the type you specify, decoded from a single top-level key in a JSON object.
    ///
    /// This method is useful when the JSON body you’re decoding contains a single key/value pair, and you want to
    /// decode just the value while discarding the key.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - key: The top-level key at which to start decoding.
    ///   - data: The JSON data to decode.
    /// - Throws: If the data is not valid JSON, this method throws the DecodingError.dataCorrupted(_:) error. If a
    ///   value within the JSON fails to decode, this method throws the corresponding error.
    func decode<Key, Value>(_ type: Value.Type, for key: Key, from data: Data) throws -> Value
        where Key : CodingKey, Value : Decodable {
            // Set the key in the userInfo dictionary, but remove it before we return from this method
            userInfo[.keyToDecode] = key
            defer { userInfo[.keyToDecode] = nil }
            return try decode(KeyedValue<Key, Value>.self, from: data).value
    }
}


private extension CodingUserInfoKey {
    /// The coding key whose corresponding value is the key that a `KeyedValue` will decode.
    ///
    /// This is set in `JSONDecoder.decode(_:for:from:)` and read from `KeyedValue.init(from:)`.
    static let keyToDecode = CodingUserInfoKey(rawValue: "com.grubhub.GrubFoundation.keyToDecode")!
}


/// A `KeyedValue` represents a value associated with a coding key. It is used to decode a single value for a given key
/// in JSON data. The key to decode is communicated to the type via `JSONDecoder`’s `userInfo` dictionary.
private struct KeyedValue<Key, Value> : Decodable where Key : CodingKey, Value : Decodable {
    /// The decoded value.
    let value: Value


    init(from decoder: Decoder) throws {
        // If key isn’t present, this will crash, but the key is declared and set inside of this file, so
        // we can ensure that it will never be missing or of the wrong type
        let key = decoder.userInfo[.keyToDecode] as! Key
        let container = try decoder.container(keyedBy: Key.self)
        self.value = try container.decode(Value.self, forKey: key)
    }
}
