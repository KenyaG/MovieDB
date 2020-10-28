//
//  Data+Random.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 6/3/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension Data {
    /// Returns a random `Data` instance with the specified number of bytes.
    ///
    /// - Parameters:
    ///   - count: The number of random bytes to generate.
    ///   - generator: The random number generator to use when creating the new random value.
    /// - Returns: A random `Data` object.
    static func random<RNG>(count: Int, using generator: inout RNG) -> Data where RNG : RandomNumberGenerator {
        precondition(count >= 0, "count must be non-negative")
        var data = Data()

        guard count > 0 else {
            return data
        }

        // Generate enough UInt64s to cover the majority of the count
        let bytesPerNumber = UInt64.bitWidth / 8
        let generationCount = count / bytesPerNumber
        for _ in 0 ..< generationCount {
            var value = generator.next()
            withUnsafePointer(to: &value) { (pointer) in
                data.append(UnsafeBufferPointer(start: pointer, count: 1))
            }
        }

        // If there are no more bytes remaining, we’re done
        let remainingByteCount = UInt64(count % bytesPerNumber)
        guard remainingByteCount > 0 else {
            return data
        }

        // Otherwise, generate one last UIn64 and append each remaining byte one-by-one
        let lastValue = generator.next()
        for i in 0 ..< remainingByteCount {
            data.append(UInt8(truncatingIfNeeded: lastValue >> (i * 8)))
        }

        return data
    }
}
