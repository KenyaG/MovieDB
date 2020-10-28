//
//  Handler.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 3/25/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// The `Handler` protocol defines an interface by which an object can declare that it can handle a result of a
/// particular type and produce a result of a possibly different type. The interface enables the handler to do this
/// synchronously or asynchronously, though synchronous handlers can simplify protocol conformance by conforming to
/// `Transformer` instead. All `Transformer`s are also `Handler`s.
///
/// Handlers are at the core of GrubFoundation’s HTTP response handling. For more information, see `HTTPClient` and
/// `AuthenticatingHTTPClient`.
public protocol Handler {
    /// The type of result that the handler accepts as input.
    associatedtype Input

    /// The type of result the handler produces.
    associatedtype Output

    /// Handles `result` and invokes `completion` with its output.
    ///
    /// - Parameters:
    ///   - result: The result to be handled.
    ///   - completion: A closure to be invoked upon completion of handling with the handler’s result as a parameter.
    func handle(_ result: Result<Input, Error>, completion: @escaping (Result<Output, Error>) -> Void)
}


/// `AdHocHandler`s are used to conveniently create ad-hoc handlers using closures to perform handling.
public struct AdHocHandler<Input, Output> : Handler {
    /// The closure used to perform handling. Its input is the instance’s input. When it is done, it should invoke
    /// the completion handler with its result.
    public let body: (Result<Input, Error>, @escaping (Result<Output, Error>) -> Void) -> Void


    /// Initializes an ad-hoc handler with the specified closure.
    ///
    /// - Parameter body: The closure used to perform handling.
    public init(body: @escaping (Result<Input, Error>, @escaping (Result<Output, Error>) -> Void) -> Void) {
        self.body = body
    }


    public func handle(_ result: Result<Input, Error>, completion: @escaping (Result<Output, Error>) -> Void) {
        body(result, completion)
    }
}


/// `HandlerLink`s links the output of one handler to the input of another. `HandlerLink` conforms to
/// `Handler`, so links can used anywhere handlers are used, including as as the input or output of a handler link.
/// This allows you to construct a chain of handlers. The first handler in a chain handles an input and passes its
/// result to the next handler, which handles its input and passes its result to the next handler, and so on. This all
/// happens automatically by invoking `handle(_:completion:)` on the first handler link.
///
///     let handlerChain = handler1.chaining(handler2).chaining(handler3). … .chaining(handlerN)
///     handlerChain.handle(input1) { (outputN, completion) in
///         …
///     }
public struct HandlerLink<First, Next> : Handler where First : Handler, Next : Handler, First.Output == Next.Input {
    /// The handler that handles the input for this link.
    private let first: First

    /// The handler that produces the output of this link. It handles `handler`’s output.
    private let next: Next


    /// Initializes a new handler link that links `handler` to `next`.
    ///
    /// - Parameters:
    ///   - first: The handler that handles the input for this link.
    ///   - next: The handler that produces the output of this link. Its input is `handler`’s output.
    fileprivate init(first: First, next: Next) {
        self.first = first
        self.next = next
    }


    public func handle(_ input: Result<First.Input, Error>, completion: @escaping (Result<Next.Output, Error>) -> Void) {
        first.handle(input) { result in
            self.next.handle(result, completion: completion)
        }
    }
}


public extension Handler {
    /// Returns a new handler link that links the output of this instance to the input of `next`.
    ///
    /// - Parameter next: The next handler in the chain.
    /// - Returns: A handler link that links the output of this instance to the input of `next`.
    func chaining<Next>(_ next: Next) -> HandlerLink<Self, Next> where Next : Handler {
        return HandlerLink(first: self, next: next)
    }
}
