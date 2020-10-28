//
//  OrValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 8/2/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// A `OrValidator` considers a value valid when any of its child validators consider the value valid.
///
/// As the name implies, `OrValidator`s act as logical OR expressions on their validators. They can be used to
/// describe a complex set of validation requirements using pre-built validators. For example, the following validator
/// ensures that strings are either between 1–3 characters long or are one of either "value1", "value2", or "value3".
///
///     let countValidator = CharacterCountValidator(validRange: 1 ... 3)
///     let setMembershipValidator = InSetValidator(["value1", "value2", "value3"])
///
///     var stringValidator = OrValidator<String>()
///     stringValidator.add(countValidator)
///     stringValidator.add(validCharactersValidator)
///
///     …
///
///     do {
///         try stringValidator.validate(string)
///         …
///     } catch {
///         let invalidPasswordMessage = NSLocalizedString("Strings must b 1–3 …", "invalid string message")
///         …
///     }
public struct OrValidator<Value> : Validator {
    /// The instance’s child validators.
    public var validators: [AnyValidator<Value>] = []


    /// Creates a new `OrValidator` with the specified child validators.
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
    public mutating func add<ChildValidator>(_ validator: ChildValidator)
        where ChildValidator : Validator, ChildValidator.Value == Value {
            validators.append(AnyValidator(validator))
    }


    /// Throws a `ValidationError` if all of the instance’s child validators fail to validate `value`.
    ///
    /// - Parameter value: The value being validated.
    public func validate(_ value: Value) throws {
        for validator in validators {
            do {
                // As soon as one of the validator’s pass, return
                try validator.validate(value)
                return
            } catch {
            }
        }

        throw ValidationError("\(value) does not pass validation for any of \(validators.debugDescription)")
    }


    public var debugDescription: String {
        return "OrValidator(\(validators.debugDescription))"
    }
}
