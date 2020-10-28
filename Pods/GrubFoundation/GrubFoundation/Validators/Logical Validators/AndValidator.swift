//
//  AndValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 7/31/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// A `AndValidator` considers a value valid when all of its child validators consider the value valid.
///
/// As the name implies, `AndValidator`s act as logical AND expressions on their validators. They can be used to
/// describe a complex set of validation requirements using pre-built validators. For example, the following validator
/// ensures that passwords contain only alphanumeric and punctuation characters and are between 8–64 characters long.
///
///     var validCharacterSet = CharacterSet.alphanumerics
///     validCharacterSet.formUnion(.punctuationCharacters)
///
///     let countValidator = CharacterCountValidator(validRange: 8 ... 64)
///     let validCharactersValidator = CharacterValidator(validCharacters: validCharacterSet)
///
///     var passwordValidator = AndValidator<String>()
///     passwordValidator.add(countValidator)
///     passwordValidator.add(validCharactersValidator)
///
///     …
///
///     do {
///         try passwordValidator.validate(password)
///         passwordField.validityIndicator.state = .valid
///     } catch {
///         let invalidPasswordMessage = NSLocalizedString("Passwords must be 8–64 …", "invalid password message")
///         passwordField.validityIndicator.state = .invalid(invalidPasswordMessage)
///     }
public struct AndValidator<Value> : Validator {
    /// The instance’s child validators.
    public var validators: [AnyValidator<Value>]


    /// Creates a new `AndValidator` with the specified child validators.
    ///
    /// While you can pass child validators to this method, it’s probably easier to use the `add(_:)` method, as that
    /// doesn’t require you to wrap child validators in `AnyValidator`s.
    ///
    /// - Parameter validators: The validator’s child validators. `[]` by default.
    public init(_ validators: [AnyValidator<Value>] = []) {
        self.validators = validators
    }


    /// Adds the specified validator to the instance’s child validators.
    ///
    /// - Parameter validator: The child validator to add.
    public mutating func add<ChildValidator>(_ validator: ChildValidator) where ChildValidator : Validator, ChildValidator.Value == Value {
        validators.append(AnyValidator(validator))
    }


    /// Throws an error if any of the instance’s child validators fail to validate `value`.
    ///
    /// - Parameter value: The value being validated.
    public func validate(_ value: Value) throws {
        for validator in validators {
            try validator.validate(value)
        }
    }


    public var debugDescription: String {
        return "AndValidator(\(validators.debugDescription))"
    }
}
