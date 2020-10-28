//
//  AnyCodingKey.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 7/13/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `AnyCodingKey`s type erase `CodingKey`s.
public struct AnyCodingKey : CodingKey {
    /// The type erased coding key.
    public let base: CodingKey


    /// Creates a new `AnyCodingKey` that type erases the specified coding key.
    ///
    /// - Parameter base: The coding key to wrap.
    public init(_ base: CodingKey) {
        self.base = base
    }


    /// Always returns `nil`.
    ///
    /// `AnyCodingKey`s are meant to wrap existing coding keys. If you need to create a custom coding keys, we
    /// recommend either create them idiomatically using an enum or create a custom type that semantically describes
    /// the keys you need to represent.
    ///
    /// - Parameter stringValue: The string value with which to initialize the instance. This parameter is ignored.
    public init?(stringValue: String) {
        return nil
    }


    /// The erased key’s string value.
    public var stringValue: String {
        return base.stringValue
    }


    /// Always returns `nil`.
    ///
    /// `AnyCodingKey`s are meant to wrap existing coding keys. If you need to create a custom coding keys, we
    /// recommend either create them idiomatically using an enum or create a custom type that semantically describes
    /// the keys you need to represent.
    ///
    /// - Parameter intValue: The integer value with which to initialize the instance. This parameter is ignored.
    public init?(intValue: Int) {
        return nil
    }


    /// The erased key’s integer value.
    public var intValue: Int? {
        return base.intValue
    }
}
