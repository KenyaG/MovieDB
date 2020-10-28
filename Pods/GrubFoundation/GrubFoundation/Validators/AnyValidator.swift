//
//  AnyValidator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 7/31/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// The `AnyValidator` type forwards `Validator` operations to an underlying validator, hiding its specific
/// underlying type. This can be useful when you need to store references to one or more validators with a specific
/// value type, but you don’t care about the validator types themselves.
public struct AnyValidator<Value> : Validator {
    /// Private box base class. No instances of this type are ever created. Instead, it is used so that we can define
    /// the underlying validator of our `AnyValidator` instance generically on the validator’s value type.
    private class BoxBase<BoxValue> : Validator {
        typealias Value = BoxValue


        func validate(_ value: BoxValue) throws {
            // Raises a fatal error, as BoxBase instances are not meant to be instantiated or used.
            fatalError()
        }


        var debugDescription: String {
            // Raises a fatal error, as BoxBase instances are not meant to be instantiated or used.
            fatalError()
        }
    }


    /// Private subclass of our base box class. Unlike the base box class, which is generic on the underlying
    /// validator’s value type, this is generic on the validator’s type itself. This allows us to actually invoke the
    /// the underlying validator while erasing its original type.
    private class Box<BoxedValidator> : BoxBase<BoxedValidator.Value> where BoxedValidator : Validator {
        /// The box’s base object.
        let base: BoxedValidator


        /// Initializes a `Box` with the specified base.
        ///
        /// - Parameter base: The base object this box contains.
        init(_ base: BoxedValidator) {
            self.base = base
        }


        /// Simply forwards its parameters to its underyling validator’s `validate(_:)` method.
        ///
        /// - Parameter value: The value to validate.
        override func validate(_ value: BoxedValidator.Value) throws {
            try base.validate(value)
        }


        /// Simply returns its underlying validator’s debug description
        override var debugDescription: String {
            return base.debugDescription
        }
    }


    /// The type-erased box in which we will store our underlying validator. It is defined as a `BoxBase` instance,
    /// though it will only ever be a `Box`. This allows us to define `AnyValidator` as a generic on the validator’s
    /// value type instead of the underlying validator’s type, which we’re erasing.
    private let box: BoxBase<Value>


    /// Creates a new `AnyValidator` instance with the specified underyling validator.
    ///
    /// - Parameter base: The underyling validator that the instance wraps.
    public init<BoxedValidator>(_ base: BoxedValidator) where BoxedValidator : Validator, BoxedValidator.Value == Value {
        self.box = Box(base)
    }


    /// Simply forwards its parameter to its underyling validator’s `validate(_:)` method.
    ///
    /// - Parameter value: The value to validate.
    public func validate(_ value: Value) throws {
        try box.validate(value)
    }


    /// Simply returns its underlying validator’s debug description
    public var debugDescription: String {
        return box.debugDescription
    }
}
