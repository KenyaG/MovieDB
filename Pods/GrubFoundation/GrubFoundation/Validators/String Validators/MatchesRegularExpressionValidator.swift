//
//  MatchesRegularExpressionValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 8/2/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `MatchesRegularExpressionValidator`s validate that a string matches a regular expression.
public struct MatchesRegularExpressionValidator : Validator {
    /// The regular expression to search for.
    public let regularExpression: NSRegularExpression


    /// Creates a new `MatchesRegularExpressionValidator` with the specified regular expression.
    ///
    /// - Parameter regularExpression: The regular expression to search for.
    public init(_ regularExpression: NSRegularExpression) {
        self.regularExpression = regularExpression
    }


    /// Throws a `ValidationError` if `value` does not match `regularExpression`.
    ///
    /// - Parameter value: The value being validated.
    public func validate(_ value: String) throws {
        if regularExpression.numberOfMatches(in: value, range: NSRange(value.startIndex ..< value.endIndex, in: value)) == 0 {
            throw ValidationError("\"\(value)\" does not match regular expression \(regularExpression)")
        }
    }


    public var debugDescription: String {
        return "MatchesRegularExpressionValidator(\(regularExpression))"
    }
}
