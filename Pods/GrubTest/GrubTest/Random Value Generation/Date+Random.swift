//
//  SeedableRandomNumberGenerator+Dates.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 6/3/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension Date {
    /// The maximum random time interval used by random date generation methods. This value is used to limit random
    /// dates that are generated. Specifically, it used by `random(before:using:)` and `random(after:using:)` to control
    /// the earliest and latest dates generated, respectively.
    ///
    /// - Note: Currently this value is 788,400,000 seconds—roughly 25 years—but that might change in future versions.
    static var maxRandomTimeInterval: TimeInterval {
        return 788_400_000
    }


    /// Returns a random `Date` in `range`.
    ///
    /// - Parameters:
    ///   - range: The range of dates from which to randomly select a date.
    ///   - generator: The random number generator to use when creating the new random value.
    /// - Returns: A random Date in the specified range.
    static func random<RNG>(in range: Range<Date>, using generator: inout RNG) -> Date where RNG : RandomNumberGenerator {
        precondition(!range.isEmpty, "range must be non-empty")
        let timeIntervalRange = range.lowerBound.timeIntervalSinceReferenceDate ..< range.upperBound.timeIntervalSinceReferenceDate
        let timeInterval = Double.random(in: timeIntervalRange, using: &generator)
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }


    /// Returns a random `Date` in `range`.
    ///
    /// - Parameters:
    ///   - range: The range of dates from which to randomly select a date.
    ///   - generator: The random number generator to use when creating the new random value.
    /// - Returns: A random Date in the specified range.
    static func random<RNG>(in range: ClosedRange<Date>, using generator: inout RNG) -> Date where RNG : RandomNumberGenerator {
        let timeIntervalRange = range.lowerBound.timeIntervalSinceReferenceDate ... range.upperBound.timeIntervalSinceReferenceDate
        let timeInterval = Double.random(in: timeIntervalRange, using: &generator)
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }


    /// Returns a random `Date` that is at least 1 second before `date`.
    ///
    /// - Note: The date returned is not more than `maxRandomTimeInterval` seconds before `date`.
    ///
    /// - Parameters:
    ///   - date: The date that returned dates are before.
    ///   - generator: The random number generator to use when creating the new random value.
    /// - Returns: A random `Date` before `date`.
    static func random<RNG>(before date: Date, using generator: inout RNG) -> Date where RNG : RandomNumberGenerator {
        return random(in: date.addingTimeInterval(-maxRandomTimeInterval) ..< date.addingTimeInterval(-1), using: &generator)
    }


    /// Returns a random `Date` that is at least 1 second after `date`.
    ///
    /// - Note: The date returned is not more than `maxRandomTimeInterval` seconds after `date`.
    ///
    /// - Parameters:
    ///   - date: The date that returned dates are after.
    ///   - generator: The random number generator to use when creating the new random value.
    /// - Returns: A random `Date` after `date`.
    static func random<RNG>(after date: Date, using generator: inout RNG) -> Date where RNG: RandomNumberGenerator {
        return random(in: date.addingTimeInterval(1) ..< date.addingTimeInterval(maxRandomTimeInterval), using: &generator)
    }
}
