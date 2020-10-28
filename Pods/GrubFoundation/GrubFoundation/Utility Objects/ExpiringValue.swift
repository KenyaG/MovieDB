//
//  ExpiringValue.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 2/28/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `ExpiringValue` pairs a value with a lifetime date interval. A value is considered “expired” if the current date
/// does not fall within the lifetime date interval or if the value was manually expired using the `expire()` method.
///
/// `ExpiringValue`s are ideal to use when implementing values that need to be refreshed after some freshness
/// interval has elapsed. For example, suppose you wanted to store the result of some expensive operation. For
/// efficiency, you might want to cache the previously fetched value for 60 seconds before fetching it again. You could
/// implement that scheme using an expiring value:
///
///     var fetchedValue: ExpiringValue<SomeType>?
///
///     // Fetches the value unconditionally
///     private func fetchValue(completion: @escaping (Result<SomeType, Error>) -> Void) {
///         // Do something to fetch the value
///         doSomethingToFetchTheValue { (result) in
///             if let value = result.value {
///                 self.fetchedValue = ExpiringValue(value, lifetimeDuration: 60)
///             }
///
///             completion(result)
///         }
///     }
///
///     // Fetches the value only if it’s not expired
///     func fetchValueIfNeeded(completion: @escaping (Result<SomeType, Error>) -> Void) {
///         if let fetchedValue = fetchedValue, !fetchedValue.isExpired {
///             completion(.success(fetchedValue.value))
///             return
///         }
///
///         fetchValue(completion: completion)
///     }
///
/// Because we used an expiring value, `fetchValueIfNeeded(completion:)` would only fetch once every 60 seconds, i.e.,
/// only after the value expired. If we wanted to force a fetch, e.g., because the value was invalidated by some other
/// operation, we might do the following:
///
///     func valueInvalidatingMethod() {
///         // Do something to invalidate our fetched value
///         …
///         fetchedValue.expire()
///     }
///
/// After invoking this method, the next invocation of `fetchValueIfNeeded(completion:)` would fetch a new value.
public struct ExpiringValue<Value> {
    /// The value being stored.
    public let value: Value

    /// The date interval spanning the instance’s lifetime. If the current date is outside of this interval, the value
    /// is considered expired.
    public let lifetimeDateInterval: DateInterval

    /// Whether the value was manually marked as expired via the `expire()` method.
    private(set) var isManuallyExpired = false


    /// Creates a new `ExpiringValue` instance with the specified value and lifetime date interval.
    ///
    /// - Parameters:
    ///   - value: The value.
    ///   - lifetimeDateInterval: A date interval that spans the lifetime of the value. If the current date is outside
    ///     this interval, the value is expired.
    public init(value: Value, lifetimeDateInterval: DateInterval) {
        self.value = value
        self.lifetimeDateInterval = lifetimeDateInterval
    }


    /// Marks the value as expired. Any subsequent invocations of `isExpired` or `isExpired(at:)` will return `true`
    /// after invoking this method.
    public mutating func expire() {
        isManuallyExpired = true
    }


    /// Returns whether the instance is expired on the current date. This is equivalent to
    ///
    ///     expiringValue.isExpired(at: Date()).
    public var isExpired: Bool {
        return isExpired(at: Date())
    }


    /// Returns whether the instance is expired at `date`. This method returns `true` if `date` is not contained within
    /// the instance’s `lifetimeDateInterval` or if the `expire()` method was previously invoked on the instance.
    ///
    /// - Parameter date: The date for which to determine if the instance is expired.
    /// - Returns: Whether the value is expired at `date`.
    public func isExpired(at date: Date) -> Bool {
        return isManuallyExpired || !lifetimeDateInterval.contains(date)
    }
}


extension ExpiringValue {
    /// Creates a new `ExpiringValue` instance with the specified value and a lifetime date interval that starts now
    /// and ends after `lifetimeDuration` seconds.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - lifetimeDuration: The duration of the value’s lifetime.
    public init(value: Value, lifetimeDuration: TimeInterval) {
        self.init(value: value, lifetimeDateInterval: DateInterval(start: Date(), duration: lifetimeDuration))
    }
}


// MARK: Synthesized conformances to Codable, Equatable, and Hashable

extension ExpiringValue : Codable where Value : Codable { }
extension ExpiringValue : Equatable where Value : Equatable { }
extension ExpiringValue : Hashable where Value : Hashable { }
