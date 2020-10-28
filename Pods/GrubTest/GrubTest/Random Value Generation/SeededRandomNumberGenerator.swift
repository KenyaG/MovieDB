//
//  SeededRandomNumberGenerator.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 6/2/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `SeededRandomNumberGenerator` is a very fast, memory-efficient, thread-safe pseudo-random number generator. Its
/// implementation is derived from the [public domain C implementation][Xoroshiro128+].
///
/// The lowest order bit of generated numbers is a [linear feedback shift-register][LFSR] and shouldn’t be used to
/// generate random booleans. That is, don’t use `result & 01` or `result % 2 == 0`. Instead, convert the result into a
/// signed integer and use its sign bit. Likewise, when extracting a subset of bits, right shift the result to exclude
/// the lower order bits.
///
/// [Xoroshiro128+]: http://xoroshiro.di.unimi.it/xoroshiro128plus.c
/// [LFSR]: https://en.wikipedia.org/wiki/Linear-feedback_shift_register
public struct SeededRandomNumberGenerator : RandomNumberGenerator {
    /// This is an implementation of the splitmix64 pseudo-random number generator, translated from the [public domain
    /// C implementation][Splitmix64]. It is used to seed the xoroshiro128+ algorithm’s initial state using a 64-bit
    /// value, as recommended by the xoroshiro128+ C implementation.
    ///
    /// [Splitmix64]: http://xoroshiro.di.unimi.it/splitmix64.c
    private struct SplitMix64RandomNumberGenerator {
        /// The internal state of the random number generator.
        private var state: UInt64


        /// Creates and initializes a new `SplitMix64RandomNumberGenerator` with the specified initial state.
        ///
        /// - Parameter state: The initial state of the random number generator.
        init(state: UInt64) {
            self.state = state
        }


        /// Generates and returns the next random value.
        ///
        /// - Returns: The random value.
        mutating func next() -> UInt64 {
            state = state &+ 0x9e3779b97f4a7c15

            var z = state
            z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
            z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
            return z ^ (z >> 31)
        }
    }


    /// An unfair lock used to synchronize access to the `state` variable.
    private var stateLock: os_unfair_lock

    /// The internal state of the random number generator.
    private var state: (UInt64, UInt64)


    /// The random number generator’s seed.
    public var seed: UInt64 {
        didSet {
            os_unfair_lock_lock(&stateLock)
            var seedGenerator = SplitMix64RandomNumberGenerator(state: seed)
            state.0 = seedGenerator.next()
            state.1 = seedGenerator.next()
            os_unfair_lock_unlock(&stateLock)
        }
    }


    /// Creates and initializes a new `SeededRandomNumberGenerator` with the specified seed. The seed is input into
    /// a splitmix64 random number generator to generate the instance’s 128-bits of initial state.
    ///
    /// - Parameter seed: A value to seed the initial state of the random number generator. By default, this is derived
    ///   from the current date.
    public init(seed: UInt64 = Date.timeIntervalSinceReferenceDate.bitPattern) {
        stateLock = os_unfair_lock()

        self.seed = seed

        var seedGenerator = SplitMix64RandomNumberGenerator(state: seed)
        state.0 = seedGenerator.next()
        state.1 = seedGenerator.next()
    }


    public mutating func next() -> UInt64 {
        os_unfair_lock_lock(&stateLock)

        let s0 = state.0
        var s1 = state.1
        let result = s0 &+ s1

        s1 ^= s0

        state.0 = s0.rotateLeft(by: 24) ^ s1 ^ (s1 << 16)
        state.1 = s1.rotateLeft(by: 37)

        os_unfair_lock_unlock(&stateLock)

        return result
    }


    public mutating func next<T>(upperBound: T) -> T where T : FixedWidthInteger, T : UnsignedInteger {
        precondition(upperBound > 0, "upperBound may not be 0")

        let firstUnbiasedValue = (T.max - upperBound + 1) % upperBound
        var value: T
        repeat {
            value = next()
        } while value < firstUnbiasedValue

        return value % upperBound
    }
}


private extension UInt64 {
    /// Rotates the instance left by the specified number of bits.
    ///
    /// - Parameter distance: The number of bits by which to rotate the instance left.
    /// - Returns: A version of the instance that has been rotated left by `distance` bits.
    func rotateLeft(by distance: Int) -> UInt64 {
        return (self << distance) | (self >> (64 - distance))
    }
}
