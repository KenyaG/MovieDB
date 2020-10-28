//
//  Transformer.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 4/2/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `Transformer` provides a simplified path to `Handler`-conformance for synchronous handlers that just transform
/// their input value into an output value. Rather than implementing `handle(_:completion:)`, which requires unwrapping
/// the input `Result`, performing a transformation, wrapping the output in `Result` and invoking the completion
/// closure, `Transformer`s implement `transform(_:)`. This method takes the already unwrapped input and returns output
/// without wrapping it in a `Result`. If an error occurs during transformation, the method can simply throw it. The
/// default implementation of `handle(_:completion)` performs all the `Result` wrapping and unwrapping for you.
public protocol Transformer : Handler {
    /// Transforms input into an instance of `Output`.
    ///
    /// - Parameter input: The input to transform.
    /// - Returns: The transformed input as an `Output`.
    /// - Throws: An error if transformation fails.
    func transform(_ input: Input) throws -> Output
}


public extension Transformer {
    /// If `result` is an error, passes result to `completion`. Otherwise, calls `transform(_:)` with the result’s value
    /// as the input and wraps the resulting value or error in a `Result` which is then passed to `completion`.
    ///
    /// - Parameters:
    ///   - result: The result to handle.
    ///   - completion: The completion closure which is passed the transformer’s result after transformation.
    func handle(_ result: Result<Input, Error>, completion: @escaping (Result<Output, Error>) -> Void) {
        completion(Result(catching: { try transform(result.get()) }))
    }
}


/// `ArrayTransformer` uses an element transformer to transform the elements of an input array into a different
/// array. Its input type is an array of the element transformer’s input type, and its output type is an array of the
/// element transformer’s output type.
///
/// `ArrayTransformer` can be thought of as a transformer version of the `map` method that that uses
/// `elementTransformer`’s `transform(_:)` as its closure. In fact, this is essentially how it implements
/// `transform(_:)`. If the element transformer throws an error while transformation any element of the input array, the
/// entire transformation fails with that error.
public struct ArrayTransformer<ElementTransformer> : Transformer where ElementTransformer : Transformer {
    public typealias Input = [ElementTransformer.Input]
    public typealias Output = [ElementTransformer.Output]

    /// A transformer that transforms individual elements of the input array into an element of the output array.
    public let elementTransformer: ElementTransformer


    /// Initializes a new `ArrayTransformer` with the specified element transformer.
    ///
    /// - Parameter elementTransformer: The transformer to use to transform elements of the input array.
    public init(elementTransformer: ElementTransformer) {
        self.elementTransformer = elementTransformer
    }


    public func transform(_ input: [ElementTransformer.Input]) throws -> [ElementTransformer.Output] {
        return try input.map { try elementTransformer.transform($0) }
    }
}


/// `AdHocTransformer`s are used to conveniently create ad-hoc transformers using closures to perform transformation.
public struct AdHocTransformer<ClosureInput, ClosureOutput> : Transformer {
    public typealias Input = ClosureInput
    public typealias Output = ClosureOutput


    /// The closure used to perform transformation. Its input is the instance’s input.
    public let body: (ClosureInput) throws -> ClosureOutput


    /// Initializes an ad-hoc transformer with the specified closure.
    ///
    /// - Parameter body: The closure used to perform transformation.
    public init(body: @escaping (ClosureInput) throws -> ClosureOutput) {
        self.body = body
    }


    public func transform(_ input: ClosureInput) throws -> ClosureOutput {
        return try body(input)
    }
}
