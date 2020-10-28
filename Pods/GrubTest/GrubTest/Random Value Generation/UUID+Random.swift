//
//  UUID+Random.swift
//  GrubTest
//
//  Created by Sergii Rykovskyi on 08.11.2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension UUID {
    /// Returns a UUID whose bytes are generated using `generator`. This enables pseudo-random UUID generation.
    ///
    /// - Parameter generator: The random number generator to use when creating the new random value.
    /// - Returns: A randomly generated UUID.
    static func random<RNG>(using generator: inout RNG) -> UUID where RNG : RandomNumberGenerator {
        let data = Data.random(count: 16, using: &generator)
        let uuidBuffer: uuid_t = (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7],
                                  data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15])
        return UUID(uuid: uuidBuffer)
    }
}
