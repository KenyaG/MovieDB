//
//  ThrowingStub.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 5/30/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `ThrowingStub`s aid in stubbing methods in automated tests. It is closely related to `Stub`, but supports
/// stubbing methods that can throw errors.
///
/// Similar to `Stub`s, each throwing stub has an `invoke(with:)` method that records its parameters and either
/// returns a predefined value or throws an error. These recorded invocations can then be used in your automated tests
/// to verify that the stub received the correct parameters and trigger next steps.
///
/// Throwing stubs use `Result`s to specify whether to return a value or throw an error. The result of an invocation can
/// be specified using a stub’s result queue and default result. When invoked, a throwing stub will first check if its
/// result queue is non-empty; if so, the first element of the queue is removed and used to respond to the invocation.
/// Otherwise, the stub’s default result is used instead. When the result is `.success`, the stub returns a value; when
/// the result is `.error`, an error is thrown.
///
/// The intended pattern for using `ThrowingStub` is to first stub methods in your mock object. For example,
///
///     protocol ThingProtocol {
///         func doSomething(withStrings: [String]) throws -> Int
///     }
///
///     final class StubbedThing : ThingProtocol {
///         var doSomethingStub: ThrowingStub<[String], Int>!
///
///         func doSomething(withStrings strings: [String]) throws -> Int {
///             return try doSomethingStub.invoke(with: strings)
///         }
///     }
///
/// Then in your test, you set up the stub, trigger the method invocation, and use the `ThrowingStub` to verify your
/// expectations:
///
///     func testThings() {
///         // Create stub with default return value
///         let stubbedThing = StubbedThing()
///         stubbedThing.doSomethingStub = ThrowingStub(defaultResult: .success(100))
///
///         // Create system-under-test with stubbed object and trigger stub invocation
///         let systemUnderTest = SystemUnderTest(thing: stubbedThing)
///
///         do {
///             let value = try systemUnderTest.doSomethingWithThing(strings: ["a", "b"])
///
///             // Verify that the return value was passed through
///             XCTAssertEqual(value, 100, "returns wrong value")
///
///             // Verify that the parameters were correct
///             XCTAssertEqual(stubbedThing.doSomethingStub.parameters, [["a", "b"]], "invoked with wrong parameters")
///         } catch {
///             XCTFail("throws unexpected error: \(error)")
///         }
///     }
public final class ThrowingStub<Parameters, ReturnType> {
    /// `Invocation`s record the parameters and return value when a stub is invoked.
    public struct Invocation {
        /// The parameters that were passed when the stub was invoked.
        public let parameters: Parameters

        /// The result of invoking the stub.
        public let result: Result<ReturnType, Error>
    }


    /// The result with which the stub will respond when its result queue is empty.
    public var defaultResult: Result<ReturnType, Error>

    /// A queue of results that the stub will respond with when invoked. If empty, `defaultResult` will be used instead.
    public var resultQueue: [Result<ReturnType, Error>] = []

    /// The invocations that the stub has. These can be reset using the `clearInvocations()` method.
    public private(set) var invocations: [Invocation] = []


    /// Creates a new `ThrowingStub` with the specified default result.
    ///
    /// - Parameter defaultResult: The result with which to respond when the stub is invoked and has an empty result
    ///   queue.
    public init(defaultResult: Result<ReturnType, Error>) {
        self.defaultResult = defaultResult
    }


    /// The parameters with which the stub has been invoked.
    public var parameters: [Parameters] {
        return invocations.map { $0.parameters }
    }


    /// The values that the stub has returned.
    public var results: [Result<ReturnType, Error>] {
        return invocations.map { $0.result }
    }


    /// Simulates an invocation of a method, recording the invocation’s parameters and the value it returned or error it
    /// threw.
    ///
    /// If `resultQueue` is non-empty, this method removes and uses the first element of the queue to respond to the
    /// invocation. Otherwise, `defaultResult` is used. When the result is `.success`, the stub returns a value; when
    /// the result is `.error`, an error is thrown.
    ///
    /// - Parameter parameters: The parameters with which to invoke the stub.
    /// - Returns: A value if its result is a `.success`.
    /// - Throws: An error if its result is a `.failure`.
    public func invoke(with parameters: Parameters) throws -> ReturnType {
        let result = resultQueue.isEmpty ? defaultResult : resultQueue.removeFirst()
        invocations.append(Invocation(parameters: parameters, result: result))
        return try result.get()
    }


    /// Removes the stub’s previously recorded invocations.
    public func clearInvocations() {
        invocations = []
    }
}


public extension ThrowingStub where Parameters == Void {
    /// Invokes the instance with `()` as the parameters. Equivalent to `try invoke(with: ())`
    func invoke() throws -> ReturnType {
        return try invoke(with: ())
    }
}


public extension ThrowingStub where ReturnType == Void {
    /// Creates a new `ThrowingStub` with a default result that wraps the specified error.
    ///
    /// - Parameter defaultError: The error to use as the default result. If non-`nil`, the default result is
    ///   `.failure(defaultError)`. Otherwise, the default result is `.success(())`.
    convenience init(defaultError: Error?) {
        self.init(defaultResult: defaultError.map { .failure($0) } ?? .success(()))
    }
}
