//
//  NotValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 8/2/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// A `NotValidator` considers a value valid when its child validator consider the value invalid.
///
/// As the name implies, `NotValidator`s act as logical NOT expressions on its validator. They can be useful when
/// combined with `AndValidator`s and `OrValidator`s.
public struct NotValidator<Value> : Validator {
    /// The instance’s child validator.
    public let validator: AnyValidator<Value>


    /// Creates a new `NotValidator` with the specified child validator.
    ///
    /// - Parameter validators: The validator’s child validator.
    public init<ChildValidator>(_ validator: ChildValidator)
        where ChildValidator : Validator, ChildValidator.Value == Value {
            self.validator = AnyValidator(validator)
    }


    /// Throws a `ValidationError` if the instance’s child validator validates `value`.
    ///
    /// - Parameter value: The value being validated.
    public func validate(_ value: Value) throws {
        do {
            try validator.validate(value)
        } catch {
            return
        }

        throw ValidationError("\(value) is valid according to NOT validator’s \(validator.debugDescription)")
    }


    public var debugDescription: String {
        return "NotValidator(\(validator.debugDescription))"
    }
}
