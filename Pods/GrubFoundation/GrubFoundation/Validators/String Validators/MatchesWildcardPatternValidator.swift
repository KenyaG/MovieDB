//
//  MatchesWildcardPatternValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 8/2/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `MatchesWildcardPatternValidator`s validate that a string matches a wildcard pattern, e.g., "f*b?r". A `*`
/// character in a wildstring pattern matches zero or more characters; a `?` character matches exactly one.
public struct MatchesWildcardPatternValidator : Validator {
    /// The predicate we use to perform searches.
    private let predicate: NSPredicate


    /// Creates a new `MatchesWildcardPatternValidator` with the specified pattern.
    ///
    /// - Parameters:
    ///   - pattern: The wildcard pattern to search for.
    ///   - isCaseInsensitive: Whether wildcard matching should be case-insensitive. Defaults to `false`.
    public init(_ pattern: String, isCaseInsensitive: Bool = false) {
        self.predicate = NSPredicate(format: "SELF LIKE\(isCaseInsensitive ? "[c]" : "") %@", pattern)
    }


    /// Throws a `ValidationError` if `value` does not match the instance’s wildcard pattern.
    ///
    /// - Parameter value: The value being validated.
    public func validate(_ value: String) throws {
        if !predicate.evaluate(with: value) {
            throw ValidationError("\"\(value)\" does not match predicate \"\(predicate.predicateFormat)\"")
        }
    }


    public var debugDescription: String {
        return "MatchesWildcardPatternValidator(\"\(predicate.predicateFormat)\")"
    }
}
