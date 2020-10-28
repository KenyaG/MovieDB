//
//  SeedableRandomNumberGenerator+Strings.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 6/3/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension String {
    /// Returns a `String` containing `count` characters randomly chosen from `characters`.
    ///
    /// - Parameters:
    ///   - characters: A collection from which random characters will be selected. May only be empty if `count` is 0.
    ///   - count: The number of random characters in the string. Must be non-negative.
    ///   - generator: The random number generator to use when creating the new random value.
    /// - Returns: A `String` containing `count` characters randomly chosen from `characters`.
    static func random<RNG, CharacterCollection>(withCharactersFrom characters: CharacterCollection,
                                                 count: Int,
                                                 using generator: inout RNG) -> String
        where RNG : RandomNumberGenerator, CharacterCollection : Collection, CharacterCollection.Element == Character {
            precondition(count == 0 || !characters.isEmpty, "characters must be non-empty when count > 0")
            guard count > 0 else {
                return ""
            }

            let characters = (0 ..< count).map { _ in characters.randomElement(using: &generator)! }
            return String(characters)
    }


    /// Returns a `String` of the specified length containing random alphanumeric characters, i.e., A-Z, a-z, 0-9.
    ///
    /// - Note: We acknowledge that this is a particularly simplistic definition of “alphanumeric.”
    ///
    /// - Parameters:
    ///   - count: The number of random characters in the string. Must be non-negative.
    ///   - generator: The random number generator to use when creating the new random value.
    /// - Returns: A random `String` of alphanumeric characters.
    static func randomAlphanumeric<RNG>(count: Int, using generator: inout RNG) -> String where RNG : RandomNumberGenerator {
        return random(withCharactersFrom: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", count: count, using: &generator)
    }


    /// Returns a `String` of the specified length containing random characters from the Basic Latin, Latin-1
    /// Supplement, Greek and Coptic, Cyrillic, Hebrew, Arabic, Devanagari, Hiragana, and Katakana character sets.
    ///
    /// - Parameters:
    ///   - count: The number of random characters in the string. Must be non-negative.
    ///   - generator: The random number generator to use when creating the new random value.
    /// - Returns: A random `String` of characters used in a variety of international languages.
    static func randomInternational<RNG>(count: Int, using generator: inout RNG) -> String where RNG : RandomNumberGenerator {
        return random(withCharactersFrom: internationalCharacters, count: count, using: &generator)
    }


    /// Characters from the Basic Latin, Latin-1 Supplement, Greek and Coptic, Cyrillic, Hebrew, Arabic, Devanagari,
    /// Hiragana, and Katakana character sets.
    private static var internationalCharacters: [Character] = {
        let codePointRanges: [ClosedRange<UInt16>] = [
            0x0020 ... 0x007e,  // Basic Latin
            0x00a0 ... 0x00ff,  // Latin 1 Supplement
            0x0391 ... 0x03a1,  // Greek and Coptic 1
            0x03a3 ... 0x03ff,  // Greek and Coptic 2
            0x0400 ... 0x046f,  // Cyrillic
            0x05d0 ... 0x05ea,  // Hebrew
            0x0621 ... 0x063a,  // Arabic
            0x0904 ... 0x0939,  // Devanagari
            0x3041 ... 0x3096,  // Hiragana
            0x30a0 ... 0x30f0   // Katakana
        ]

        return codePointRanges.flatMap { (codePointRange) in
            codePointRange.map { (codePoint) in
                Character(Unicode.Scalar(codePoint)!)
            }
        }
    }()
}
