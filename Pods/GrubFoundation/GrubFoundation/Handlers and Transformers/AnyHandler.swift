//
//  AnyHandler.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 4/1/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// The `AnyHandler` type forwards `Handler` operations to an underlying handler value, hiding its specific
/// underlying type. This can be useful when you need to store references to one or more handlers with specific input
/// and output types, but you don’t care about the handler types themselves.
public struct AnyHandler<Input, Output> : Handler {
    /// Private box base class. No instances of this type are ever created. Instead, it is used so that we can define
    /// the underlying handler of our `AnyHandler` instance generically on the handler’s input and output types.
    private class BoxBase<Input, Output> : Handler {
        func handle(_ result: Result<Input, Error>, completion: @escaping (Result<Output, Error>) -> Void) {
            // Raises a fatal error, as BoxBase instances are not meant to be instantiated or used.
            fatalError()
        }
    }


    /// Private subclass of our base box class. Unlike the base box class, which is generic on the underlying handler’s
    /// input and output types, this is generic on the handler’s type itself. This allows us to actually invoke the
    /// the underlying handler while erasing its original type.
    private final class Box<BoxedHandler> : BoxBase<BoxedHandler.Input, BoxedHandler.Output> where BoxedHandler : Handler {
        /// The box’s base object.
        let base: BoxedHandler


        /// Initializes a `Box` with the specified base.
        ///
        /// - Parameter base: The base object this box contains.
        init(_ base: BoxedHandler) {
            self.base = base
        }


        /// Simply forwards its parameters to its underyling handler’s `handle(_:completion:)` method.
        override func handle(_ result: Result<BoxedHandler.Input, Error>,
                             completion: @escaping (Result<BoxedHandler.Output, Error>) -> Void) {
            base.handle(result, completion: completion)
        }
    }


    /// The type-erased box in which we will store our underlying handler. It is defined as a `BoxBase` instance, though
    /// it will only ever be a `Box`. This allows us to define `AnyHandler` as generic on the handler’s input and
    /// output types instead of the underlying handler’s type, which we’re erasing.
    private let box: BoxBase<Input, Output>


    /// Initializes a new `AnyHandler` instance with the specified underyling handler.
    ///
    /// - Parameter base: The underyling handler that the instance wraps.
    public init<BoxedHandler>(_ base: BoxedHandler) where BoxedHandler : Handler, BoxedHandler.Input == Input, BoxedHandler.Output == Output {
        self.box = Box(base)
    }


    /// Simply forwards its parameters to its underyling handler’s `handle(_:completion:)` method.
    public func handle(_ result: Result<Input, Error>, completion: @escaping (Result<Output, Error>) -> Void) {
        box.handle(result, completion: completion)
    }
}
