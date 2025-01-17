//
//  XCTestCase+CollectionGeneration.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 10/23/2016.
//  Copyright © 2016 Grubhub, Inc. All rights reserved.
//

import Foundation
import XCTest


public extension XCTestCase {
    /// Generates an array with `count` elements generated by `elementGenerator`.
    ///
    /// - Parameters:
    ///   - count: The number of elements in the generated array
    ///   - elementGenerator: A block that takes an array index as a parameter and generates a corresponding element for
    ///     that index
    /// - Returns: A generated array
    func generatedArray<Element>(count: Int, elementGenerator: (Int) throws -> Element) rethrows -> [Element] {
        return try (0 ..< count).map(elementGenerator)
    }


    /// Generates a dictionary with `count` elements whose keys are generated by `keyGenerator`
    /// and whose values are generated `valueGenerator`.
    ///
    /// `keyGenerator` will be invoked repeatedly until the generated dictionary contains `count` elements. As such,
    /// care must be taken to ensure that the key generator can produce `count` unique values, otherwise this function
    /// will not terminate. For example, the following invocation will never return, as the key generator can only
    /// return four values, but the requested element count is 5.
    ///
    ///     let randomValues = generatedDictionary(count: 5, keyGenerator: {
    ///         return arc4random_uniform(4)
    ///     }, valueGenerator: {
    ///         return "\($0)"
    ///     })
    ///
    /// - Parameters:
    ///   - count: The number of elements in the generated dictionary
    ///   - keyGenerator: A block that generates a key to put into the dictionary
    ///   - valueGenerator: A block that takes a generated key as a parameter and generates a corresponding value for 
    ///         that key
    /// - Returns: A generated dictionary
    func generatedDictionary<Key, Value>(count: Int,
                                         keyGenerator: () throws -> Key,
                                         valueGenerator: (Key) throws -> Value) rethrows -> [Key : Value] {
        var dictionary: [Key : Value] = [:]

        while dictionary.count < count {
            let key = try keyGenerator()
            dictionary[key] = try valueGenerator(key)
        }

        return dictionary
    }


    /// Generates a set with `count` elements generated by `elementGenerator`.
    ///
    /// `elementGenerator` will be invoked repeatedly until the generated set contains `count` elements. As such, care
    /// must be taken to ensure that the element generator can produce `count` unique values, otherwise this function
    /// will not terminate. For example, the following invocation will never return, as the element generator can only
    /// return four values, but the requested element count is 5.
    ///
    ///     let randomValues = generatedSet(count: 5) {
    ///         return arc4random_uniform(4)
    ///     }
    ///
    /// - Parameters:
    ///   - count: The number of elements in the generated dictionary
    ///   - elementGenerator: A block that generates an element to put into the set
    /// - Returns: A generated set
    func generatedSet<Element>(count: Int, elementGenerator: () throws -> Element) rethrows -> Set<Element> {
        var set: Set<Element> = []

        while set.count < count {
            set.insert(try elementGenerator())
        }

        return set
    }
}
