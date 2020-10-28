//
//  InSetValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 7/31/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `InSetValidator`s validate that a value is one of a set of valid values.
public struct InSetValidator<Element> : Validator where Element : Hashable {
    /// The set of valid values.
    public let values: Set<Element>


    /// Creates a new `InSetValidator` with the specified valid values.
    ///
    /// - Parameter values: The values the validator should accept.
    public init(_ values: Set<Element>) {
        self.values = values
    }


    /// Throws a `ValidationError` if `values` does not contain `value`.
    ///
    /// - Parameter value: The value being validated.
    public func validate(_ value: Element) throws {
        if !values.contains(value) {
            throw ValidationError("\(value) is not in set \(values)")
        }
    }


    public var debugDescription: String {
        return "InSetValidator(\(values))"
    }
}
