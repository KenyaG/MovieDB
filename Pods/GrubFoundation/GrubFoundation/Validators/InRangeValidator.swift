//
//  InRangeValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 7/31/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `InRangeValidator`s validate that a value falls within a given range. They can be used to validate any type that
/// conforms to `Comparable`, including `Int`, `Decimal`, and `Double`, but also `Date` and `Measurement`.
public struct InRangeValidator<RangeExpression> : Validator where RangeExpression : Swift.RangeExpression {
    /// The range of valid values.
    public let range: RangeExpression


    /// Creates a new `InRangeValidator` with the specified range of valid values.
    ///
    /// - Parameter range: The range of valid values.
    public init(_ range: RangeExpression) {
        self.range = range
    }


    /// Throws a `ValidationError` if `range` does not contain `value`.
    ///
    /// - Parameter value: The value being validated.
    public func validate(_ value: RangeExpression.Bound) throws {
        if !range.contains(value) {
            throw ValidationError("\(value) is not in range \(range)")
        }
    }


    public var debugDescription: String {
        return "InRangeValidator(\(range))"
    }
}
