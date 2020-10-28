//
//  ValueChange.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 10/8/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `ValueChange`s describe an object’s change in value by storing an old value and a new value.
public struct ValueChange<Value> {
    /// The old value.
    public let old: Value

    /// The new value.
    public let new: Value


    /// Creates a new instance with the specified old and new values.
    ///
    /// - Parameters:
    ///   - old: The old value.
    ///   - new: The new value.
    public init(old: Value, new: Value) {
        self.old = old
        self.new = new
    }
}
