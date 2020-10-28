//
//  CaseIterable+Random.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 6/4/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension CaseIterable {
    /// Returns a random case. Returns `nil` if there are no cases.
    ///
    /// - Parameter generator: The random number generator to use when creating the new random value.
    /// - Returns: A random case.
    static func random<RNG>(using generator: inout RNG) -> Self? where RNG : RandomNumberGenerator {
        return allCases.randomElement(using: &generator)
    }
}
