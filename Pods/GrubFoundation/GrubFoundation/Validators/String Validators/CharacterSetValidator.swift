//
//  CharacterValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 8/2/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `CharacterValidator`s validate that strings contain no characters from a set of invalid characters.
public struct CharacterValidator : Validator {
    /// The set of invalid characters.
    public let invalidCharacters: CharacterSet


    /// Creates a new `CharacterValidator` with the specified set of valid characters.
    ///
    /// This simply invokes `self.init(invalidCharacters: validCharacters.inverted)`.
    ///
    /// - Parameter validCharacters: The set of valid characters.
    public init(validCharacters: CharacterSet) {
        self.init(invalidCharacters: validCharacters.inverted)
    }


    /// Creates a new `CharacterValidator` with the specified set of invalid characters.
    ///
    /// - Parameter invalidCharacters: The set of invalid characters.
    public init(invalidCharacters: CharacterSet) {
        self.invalidCharacters = invalidCharacters
    }


    /// Throws a `ValidationError` if `value` contains any characters in `invalidCharacters`.
    ///
    /// - Parameter value: The value being validated.
    public func validate(_ value: String) throws {
        if let invalidCharacterRange = value.rangeOfCharacter(from: invalidCharacters) {
            throw ValidationError("\"\(value)\" contains invalid character \"\(value[invalidCharacterRange])\"")
        }
    }


    public var debugDescription: String {
        return "CharacterValidator(invalidCharacters: \(invalidCharacters))"
    }
}
