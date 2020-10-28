//
//  Stub.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 5/30/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `Stub`s aid in stubbing methods in automated tests. Each stub has an `invoke(with:)` method that records its
/// parameters and returns a predefined value. These recorded invocations can then be used in your automated tests to
/// verify that the stub received the correct parameters and trigger next steps.
///
/// To provide a return value, stubs have both a return value queue and a default return value. You can use one or both
/// to affect which value is returned. When invoking a stub whose return value queue is non-empty, the first element of
/// the queue is removed and returned; if the queue is empty, the default return value is returned instead. If you only
/// ever wish to return one value, you can forego use of the queue entirely.
///
/// The intended pattern for using `Stub` is to first stub methods in your mock object. For example,
///
///     protocol ThingProtocol {
///         func doSomething(withStrings: [String]) -> Int
///     }
///
///     final class StubbedThing : ThingProtocol {
///         var doSomethingStub: Stub<[String], Int>!
///
///         func doSomething(withStrings strings: [String]) -> Int {
///             return doSomethingStub.invoke(with: strings)
///         }
///     }
///
/// Then in your test, you set up the stub, trigger the method invocation, and use the `Stub` to verify your
/// expectations:
///
///     func testThings() {
///         // Create stub with default return value
///         let stubbedThing = StubbedThing()
///         stubbedThing.doSomethingStub = Stub(defaultReturnValue: 100)
///
///         // Create system-under-test with stubbed object and trigger stub invocation
///         let systemUnderTest = SystemUnderTest(thing: stubbedThing)
///         let value = systemUnderTest.doSomethingWithThing(strings: ["a", "b"])
///
///         // Verify that the return value was passed through
///         XCTAssertEqual(value, 100, "returns wrong value")
///
///         // Verify that the parameters were correct
///         XCTAssertEqual(stubbedThing.doSomethingStub.parameters, [["a", "b"]], "invoked with wrong parameters")
///     }
///
/// - Note: `Stub` does not support stubbing methods that throw errors. If you need to stub such methods, use
///   `ThrowingStub` instead.
public final class Stub<Parameters, ReturnType> {
    /// `Invocation`s record the parameters and return value when a stub is invoked.
    public struct Invocation {
        /// The parameters that were passed when the stub was invoked.
        public let parameters: Parameters

        /// The return value that was returned when the stub was invoked.
        public let returnValue: ReturnType
    }


    /// The value that the stub will return when its return value queue is empty.
    public var defaultReturnValue: ReturnType

    /// A queue of values that the stub will return when it is invoked. If empty, `defaultReturnValue` will be returned
    /// instead.
    public var returnValueQueue: [ReturnType] = []

    /// The invocations that the stub has. These can be reset using the `clearInvocations()` method.
    public private(set) var invocations: [Invocation] = []


    /// Creates a new `Stub` with the specified default return value.
    ///
    /// - Parameter defaultReturnValue: The value to return when the stub is invoked and has an empty return value
    ///   queue.
    public init(defaultReturnValue: ReturnType) {
        self.defaultReturnValue = defaultReturnValue
    }


    /// The parameters with which the stub has been invoked.
    public var parameters: [Parameters] {
        return invocations.map { $0.parameters }
    }


    /// The values that the stub has returned.
    public var returnValues: [ReturnType] {
        return invocations.map { $0.returnValue }
    }


    /// Simulates an invocation of a method, recording the invocation’s parameters and the value that was returned.
    ///
    /// If `returnValueQueue` is non-empty, this method removes and returns the first element of the queue. Otherwise,
    /// `defaultReturnValue` is returned.
    ///
    /// - Parameter parameters: The parameters with which to invoke the stub.
    /// - Returns: Either the first element in `returnValueQueue` or `defaultReturnValue` if `returnValueQueue` is
    ///   empty.
    public func invoke(with parameters: Parameters) -> ReturnType {
        let returnValue = returnValueQueue.isEmpty ? defaultReturnValue : returnValueQueue.removeFirst()
        invocations.append(Invocation(parameters: parameters, returnValue: returnValue))
        return returnValue
    }


    /// Removes the stub’s previously recorded invocations.
    public func clearInvocations() {
        invocations = []
    }
}


public extension Stub where Parameters == Void {
    /// Invokes the instance with `()` as the parameters. Equivalent to `invoke(with: ())`
    func invoke() -> ReturnType {
        return invoke(with: ())
    }
}


public extension Stub where ReturnType == Void {
    /// Creates a new `Stub` with a default return value of `()`.
    convenience init() {
        self.init(defaultReturnValue: ())
    }
}
