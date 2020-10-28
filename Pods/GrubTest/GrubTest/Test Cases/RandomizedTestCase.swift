//
//  RandomizedTestCase.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 12/16/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation
import XCTest


/// `RandomizedTestCase` provides basic infrastructure for writing repeatable tests using random data.
///
/// `RandomizedTestCase` uses a `SeededRandomValueGenerator` to generate its values. In its `setUp()` method, it seeds
/// the random number generator using the current time and writes the new seed to the log; if you have a test that
/// fails, you can find the seed value that was used in your test method, and set it on your test case instance at the
/// top of the failing test method. Doing so will cause the test to run with the same random values as before.
///
/// In order to get consistent random values, you must use `RandomizedTestCase`’s random number generator. You should
/// *not* use `SystemRandomNumberGenerator`, as it is not seedable and thus cannot produce repeatable values.
///
/// For convenience, `RandomizedTestCase` provides methods to generate `Int`s, `Bool`s, `Double`s, `String`s, and other
/// common data types.
open class RandomizedTestCase : XCTestCase {
    /// The instance’s random number generator.
    public var randomNumberGenerator = SeededRandomNumberGenerator()


    /// The seed for the instance’s random number generator. Setting the seed prints the new value to the standard
    /// output device.
    public var randomSeed: UInt64 {
        get {
            return randomNumberGenerator.seed
        }

        set {
            randomNumberGenerator.seed = newValue
            print("Using random seed \(newValue)")
        }
    }


    /// Performs the superclass’s setup and updates the instance’s random seed using the current date.
    open override func setUp() {
        super.setUp()
        randomSeed = Date.timeIntervalSinceReferenceDate.bitPattern
    }


    // MARK: - Repeated Testing

    /// Repeatedly invokes the specified closure `count` times. This is useful if you want to run the same test code
    /// many times with lots of different random values.
    ///
    /// - Parameters:
    ///   - count: The number of times to run the closure. Must be non-negative. Defaults to 512.
    ///   - body: The code to repeatedly execute.
    public func repeatedlyTest(count: Int = 512, body: () throws -> Void) rethrows {
        for _ in 0 ..< count {
            try body()
        }
    }


    // MARK: - Booleans

    /// Returns a random boolean value.
    ///
    /// This is equivalent to invoking `Bool.random(using: &randomNumberGenerator)`.
    ///
    /// - Returns: A random `Bool`.
    public func randomBool() -> Bool {
        return Bool.random(using: &randomNumberGenerator)
    }


    // MARK: - Collections

    /// Returns a random element in the specified collection. Returns `nil` if `collection` is empty.
    ///
    /// This is equivalent to invoking `collection.randomElement(using: &randomNumberGenerator)`.
    ///
    /// - Parameter collection: The collection from which a random element should be returned.
    /// - Returns: A random element in `collection`.
    public func randomElement<Collection>(in collection: Collection) -> Collection.Element? where Collection : Swift.Collection {
        return collection.randomElement(using: &randomNumberGenerator)
    }


    /// Returns a random case of the specified case iterable type. Returns `nil` if the type has no cases.
    ///
    /// This is equivalent to invoking `caseIterableType.random(using: &randomNumberGenerator)`.
    ///
    /// - Parameter caseIterableType: The type from which a case should be returned.
    /// - Returns: A random case in `caseIterableType`.
    public func randomCase<CaseIterable>(of caseIterableType: CaseIterable.Type) -> CaseIterable? where CaseIterable : Swift.CaseIterable {
        return caseIterableType.random(using: &randomNumberGenerator)
    }


    // MARK: - Data

    /// Returns a random `data` instance with the specified number of bytes.
    ///
    /// This method uses `Data.random(count:using:)` to generate the returned instance.
    ///
    /// - Parameter count: The number of bytes. Must be non-negative. If `nil`, the returned instance will contain
    ///   between 1 and 128 bytes. `nil` by default.
    /// - Returns: A random `data` instance.
    public func randomData(count: Int? = nil) -> Data {
        let count = count ?? Int.random(in: 1 ... 128, using: &randomNumberGenerator)
        return Data.random(count: count, using: &randomNumberGenerator)
    }


    // MARK: - Dates

    /// Returns a random date in the specified range.
    ///
    /// This is equivalent to invoking `Date.random(in: range, using: &randomNumberGenerator)`.
    ///
    /// - Parameter range: The range from which to choose a random date. By default, the range is the current date ±25
    ///   years.
    /// - Returns: A random date in the specified range.
    public func randomDate(in range: Range<Date> = Date(timeIntervalSinceNow: -Date.maxRandomTimeInterval) ..< Date(timeIntervalSinceNow: Date.maxRandomTimeInterval)) -> Date {
        return Date.random(in: range, using: &randomNumberGenerator)
    }


    /// Returns a random date in the specified range.
    ///
    /// This is equivalent to invoking `Date.random(in: range, using: &randomNumberGenerator)`.
    ///
    /// - Parameter range: The range from which to choose a random date.
    /// - Returns: A random date in the specified range.
    public func randomDate(in range: ClosedRange<Date>) -> Date {
        return Date.random(in: range, using: &randomNumberGenerator)
    }


    /// Returns a random date before the specified date.
    ///
    /// This is equivalent to invoking `Date.random(before: date, using: &randomNumberGenerator)`.
    ///
    /// - Parameter date: The date before which to return a random date.
    /// - Returns: A random date before the specified date.
    public func randomDate(before date: Date) -> Date {
        return Date.random(before: date, using: &randomNumberGenerator)
    }


    /// Returns a random date after the specified date.
    ///
    /// This is equivalent to invoking `Date.random(after: date, using: &randomNumberGenerator)`.
    ///
    /// - Parameter date: The date after which to return a random date.
    /// - Returns: A random date after the specified date.
    public func randomDate(after date: Date) -> Date {
        return Date.random(after: date, using: &randomNumberGenerator)
    }


    // MARK: - Numeric Values

    /// Returns a random `Int` in the specified range.
    ///
    /// This is equivalent to invoking `Int.random(in: range, using: &randomNumberGenerator)`.
    ///
    /// - Parameter range: The range from which to return a random `Int`.
    /// - Returns: A random `Int` in the specified range.
    public func randomInt(in range: ClosedRange<Int>) -> Int {
        return Int.random(in: range, using: &randomNumberGenerator)
    }


    /// Returns a random `Int` in the specified range.
    ///
    /// This is equivalent to invoking `Int.random(in: range, using: &randomNumberGenerator)`.
    ///
    /// - Parameter range: The range from which to return a random `Int`.
    /// - Returns: A random `Int` in the specified range.
    public func randomInt(in range: Range<Int>) -> Int {
        return Int.random(in: range, using: &randomNumberGenerator)
    }


    /// Returns a random `UInt` in the specified range.
    ///
    /// This is equivalent to invoking `UInt.random(in: range, using: &randomNumberGenerator)`.
    ///
    /// - Parameter range: The range from which to return a random `UInt`.
    /// - Returns: A random `UInt` in the specified range.
    public func randomUInt(in range: ClosedRange<UInt>) -> UInt {
        return UInt.random(in: range, using: &randomNumberGenerator)
    }


    /// Returns a random `UInt` in the specified range.
    ///
    /// This is equivalent to invoking `UInt.random(in: range, using: &randomNumberGenerator)`.
    ///
    /// - Parameter range: The range from which to return a random `UInt`.
    /// - Returns: A random `UInt` in the specified range.
    public func randomUInt(in range: Range<UInt>) -> UInt {
        return UInt.random(in: range, using: &randomNumberGenerator)
    }


    /// Returns a random `Double` in the specified range.
    ///
    /// This is equivalent to invoking `Double.random(in: range, using: &randomNumberGenerator)`.
    ///
    /// - Parameter range: The range from which to return a random `Double`.
    /// - Returns: A random `Double` in the specified range.
    public func randomDouble(in range: Range<Double>) -> Double {
        return Double.random(in: range, using: &randomNumberGenerator)
    }


    /// Returns a random `Double` in the specified range.
    ///
    /// This is equivalent to invoking `Double.random(in: range, using: &randomNumberGenerator)`.
    ///
    /// - Parameter range: The range from which to return a random `Double`.
    /// - Returns: A random `Double` in the specified range.
    public func randomDouble(in range: ClosedRange<Double>) -> Double {
        return Double.random(in: range, using: &randomNumberGenerator)
    }


    // MARK: - Optionals

    /// Randomly returns either `nil` or the return value of the generator closure.
    ///
    /// This is equivalent to invoking `Bool.random(using: &randomNumberGenerator) ? generator() : nil`.
    ///
    /// - Parameter generator: An autoclosure that returns a value. The closure is not invoked when this method returns
    ///   `nil`.
    /// - Returns: Either the result of invoking `generator` or `nil`.
    public func randomOptional<Value>(_ generator: @autoclosure () -> Value) -> Value? {
        return Bool.random(using: &randomNumberGenerator) ? generator() : nil
    }


    // MARK: - Strings

    /// Returns a random `String` with the specified number of alphanumeric characters.
    ///
    /// This method uses `String.randomAlphanumeric(count:using:)` to generate the returned instance.
    ///
    /// - Parameter count: The number of characters. Must be non-negative. If `nil`, the returned instance will contain
    ///   between 1 and 128 characters. `nil` by default.
    /// - Returns: A random alphanumeric `String` instance.
    public func randomAlphanumericString(count: Int? = nil) -> String {
        let count = count ?? Int.random(in: 1 ... 128, using: &randomNumberGenerator)
        return String.randomAlphanumeric(count: count, using: &randomNumberGenerator)
    }


    /// Returns a random `String` with the specified number of “international” characters.
    ///
    /// This method uses `String.randomInternational(count:using:)` to generate the returned instance.
    ///
    /// - Parameter count: The number of characters. Must be non-negative. If `nil`, the returned instance will contain
    ///   between 1 and 128 characters. `nil` by default.
    /// - Returns: A random international `String` instance.
    public func randomInternationalString(count: Int? = nil) -> String {
        let count = count ?? Int.random(in: 1 ... 128, using: &randomNumberGenerator)
        return String.randomInternational(count: count, using: &randomNumberGenerator)
    }


    /// Returns a random `String` containing characters from `characters`.
    ///
    /// This is equivalent to invoking
    ///
    ///     String.random(withCharactersFrom: characters, count: count, using: &randomNumberGenerator)
    ///
    /// - Parameters:
    ///   - characters: A collection from which random characters will be selected. May only be empty if `count` is 0.
    ///   - count: The number of random characters in the string. Must be non-negative.
    /// - Returns: A random international `String` instance.
    public func randomString<CharacterCollection>(withCharactersFrom characters: CharacterCollection, count: Int) -> String
        where CharacterCollection : Collection, CharacterCollection.Element == Character {
            return String.random(withCharactersFrom: characters, count: count, using: &randomNumberGenerator)
    }


    // MARK: - URLs

    /// Returns a randomly generated URL.
    ///
    /// This is equivalent to invoking `URL.random(using: &randomNumberGenerator)`.
    ///
    /// - Returns: A randomly generated URL.
    public func randomURL() -> URL {
        return URL.random(using: &randomNumberGenerator)
    }


    /// Returns randomly generated URL components.
    ///
    /// This is equivalent to invoking `URLComponents.random(using: &randomNumberGenerator)`.
    ///
    /// - Returns: Randomly generated URL components.
    public func randomURLComponents() -> URLComponents {
        return URLComponents.random(using: &randomNumberGenerator)
    }


    /// Returns a randomly generated URL request.
    ///
    /// This is equivalent to invoking `URLRequest.random(using: &randomNumberGenerator)`.
    ///
    /// - Returns: A randomly generated URL request.
    public func randomURLRequest() -> URLRequest {
        return URLRequest.random(using: &randomNumberGenerator)
    }


    // MARK: - UUIDs

    /// Returns a randomly generated UUID.
    ///
    /// This is equivalent to invoking `UUID.random(using: &randomNumberGenerator)`.
    ///
    /// - Returns: A randomly generated UUID.
    public func randomUUID() -> UUID {
        return UUID.random(using: &randomNumberGenerator)
    }
}
