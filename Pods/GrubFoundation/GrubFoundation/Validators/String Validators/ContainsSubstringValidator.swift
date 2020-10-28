//
//  ContainsSubstringValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 8/2/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `ContainsSubstringValidator`s validate that a string contains a particular substring.
public struct ContainsSubstringValidator : Validator {
    /// The substring to search for.
    public let substring: String

    /// The string compare options to use when searching for the substring.
    public let options: String.CompareOptions

    /// The locale to use while searching for the substring. Use `nil` for the system locale. To use the user’s current
    /// locale, use `Locale.autoupdatingCurrent` or `Locale.current`.
    public let locale: Locale?


    /// Creates a new `ContainsSubstringValidator` with the specified substring, options, and locale.
    ///
    /// A wide range of flexibility can be achieved by using different string compare options. For example, substring
    /// search can be case-insensitive, ignore diacritics, and start from the end using the following options:
    ///
    ///     [.caseInsensitive, .diacriticsInsensitive, .backwards]
    ///
    /// - Note: We recommend against using the `.regularExpression` option. Use `MatchesRegularExpressionValidator`
    ///   instead, as that should perform much better when used mulitple times.
    ///
    /// - Parameters:
    ///   - substring: The substring to search for.
    ///   - options: The compare options to use when searching for `substring`.
    ///   - locale: The locale to use while searching for the substring. Use `nil` for the system locale. To use the
    ///     user’s current locale, use `Locale.autoupdatingCurrent` or `Locale.current`.
    public init(_ substring: String, options: String.CompareOptions = [], locale: Locale? = nil) {
        self.substring = substring
        self.options = options
        self.locale = locale
    }


    /// Creates a new substring validator that searches for the specified prefix. This is equivalent to invoking
    /// `init(_:options:locale:)` with an option of `.anchored`. If `isCaseInsensitive` is true, the
    /// `.caseInsensitive` option is also used.
    ///
    /// - Parameters:
    ///   - prefix: The prefix string to search for.
    ///   - isCaseInsensitive: Whether searches should be case-insensitive.
    ///   - locale: The locale to use while searching for the prefix. Use `nil` for the system locale. To use the user’s
    ///     current locale, use `Locale.autoupdatingCurrent` or `Locale.current`.
    public init(prefix: String, isCaseInsensitive: Bool = false, locale: Locale? = nil) {
        var options: String.CompareOptions = [.anchored]
        if isCaseInsensitive {
            options.insert(.caseInsensitive)
        }

        self.init(prefix, options: options, locale: locale)
    }


    /// Creates a new substring validator that searches for the specified suffix. This is equivalent to invoking
    /// `init(_:options:locale:)` with options of `[.anchored, .backwards]`. If `isCaseInsensitive` is true, the
    /// `.caseInsensitive` option is also used.
    ///
    /// - Parameters:
    ///   - suffix: The suffix string to search for.
    ///   - isCaseInsensitive: Whether searches should be case-insensitive.
    ///   - locale: The locale to use while searching for the prefix. Use `nil` for the system locale. To use the user’s
    ///     current locale, use `Locale.autoupdatingCurrent` or `Locale.current`.
    public init(suffix: String, isCaseInsensitive: Bool = false, locale: Locale? = nil) {
        var options: String.CompareOptions = [.anchored, .backwards]
        if isCaseInsensitive {
            options.insert(.caseInsensitive)
        }

        self.init(suffix, options: options, locale: locale)
    }


    /// Throws a `ValidationError` if `substring` is not found within `value`.
    ///
    /// - Parameter value: The value being validated.
    public func validate(_ value: String) throws {
        if value.range(of: substring, options: options, locale: locale) == nil {
            throw ValidationError("\"\(value)\" does not contain \"\(substring)\" (options=\(options), locale=\(String(describing: locale))")
        }
    }


    public var debugDescription: String {
        return "ContainsSubstringValidator(\"\(substring)\", options: \(options), locale: \(String(describing: locale))"
    }
}
