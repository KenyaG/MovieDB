//
//  Validator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 7/31/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// The `Validator` protocol defines an interface by which an object can validate that a value fulfills some
/// criteria.
public protocol Validator : CustomDebugStringConvertible {
    /// The type of value the validator can validate.
    associatedtype Value

    /// Validates `value`, throwing an error if `value` is invalid.
    ///
    /// - Parameter value: The value to validate.
    /// - Throws: An error if the `value` is invalid.
    func validate(_ value: Value) throws
}
