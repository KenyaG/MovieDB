//
//  Optional+Random.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 6/4/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension Optional {
    /// Randomly returns either `nil` or the return value of the value closure. This method can be useful when you
    /// optionally need another value, for example:
    ///
    ///     let givenName = …
    ///     let optionalGivenName = Optional<String>.random(givenName, using: &randomNumberGenerator)
    ///
    /// In this example, `optionalGivenName` will be `nil` roughly half the time and will be `givenName` the other half.
    ///
    /// - Parameters:
    ///   - value: An autoclosure that returns a value. When this method returns `nil`, the closure is not invoked.
    ///   - generator: The random number generator to use when creating the new random value.
    /// - Returns: Either the result of invoking `value` or `nil`.
    static func random<Value, RNG>(_ value: @autoclosure () -> Value, using generator: inout RNG) -> Value?
        where RNG : RandomNumberGenerator {
            return Bool.random(using: &generator) ? value() : nil
    }
}
