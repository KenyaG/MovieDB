//
//  CharacterCountValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 7/31/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `CharacterCountValidator`s validate that a string’s `count` is within a given range.
public struct CharacterCountValidator<RangeExpression> : Validator
where RangeExpression : Swift.RangeExpression, RangeExpression.Bound == Int {
    /// The range in which the validated string’s count must lie.
    public let range: RangeExpression


    /// Creates a new `CharacterCountValidator` that validates that strings have a count within `range`.
    ///
    /// - Parameter range: The range of valid character counts that a `String` can have.
    public init(range: RangeExpression) {
        self.range = range
    }


    /// Throws a `ValidationError` if `string.count` is not contained in `range`.
    ///
    /// - Parameter string: The `String` whose count is being validated.
    public func validate(_ string: String) throws {
        if !range.contains(string.count) {
            throw ValidationError("Character count of \"\(string)\" is not in range \(range)")
        }
    }


    public var debugDescription: String {
        return "CharacterCountValidator(range: \(range))"
    }
}
