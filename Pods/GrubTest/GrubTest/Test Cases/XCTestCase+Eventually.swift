//
//  XCTestCase+Eventually.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 1/27/2020.
//  Copyright © 2020 Grubhub, Inc. All rights reserved.
//

import Foundation
import XCTest


public extension XCTestCase {
    /// Periodically evaluates `condition` until it is `true` or `timeout` seconds have elapsed. Records an assertion
    /// failure if the timeout elapses without `condition` being true.
    ///
    /// - Parameters:
    ///   - condition: The boolean condition to periodically evaluate.
    ///   - timeout: The timeout after which to record a failure.
    ///   - message: An optional description of the failure.
    ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function
    ///     was called.
    ///   - line: The line number on which failure occurred. Defaults to the line number on which this function was
    ///     called.
    func assertEventuallyTrue(
        _ condition: @autoclosure () -> Bool,
        timeout: TimeInterval,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assert(timeout >= 0, "timeout must be non-negative")

        let start = Date()
        var conditionResult = condition()
        while !conditionResult {
            guard Date().timeIntervalSince(start) <= timeout else {
                recordAssertionFailure(message: message(), filePath: file.description, lineNumber: Int(line))
                return
            }

            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
            conditionResult = condition()
        }
    }


    /// Periodically executes `generator` until it returns a non-`nil` value or `timeout` seconds have elapsed. If
    /// `generator` returns a non-`nil` value before the timeout has elapsed, returns that value. Otherwise, records an
    /// assertion failure.
    ///
    /// - Parameters:
    ///   - generator: The expression to periodically execute.
    ///   - timeout: The timeout after which to record a failure.
    ///   - message: A description of the failure.
    ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function
    ///     was called.
    ///   - line: The line number on which failure occurred. Defaults to the line number on which this function was
    ///     called.
    func eventuallyUnwrap<T>(
        _ generator: @autoclosure () -> T?,
        timeout: TimeInterval,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T {
        assert(timeout >= 0, "timeout must be non-negative")
        let start = Date()
        var generatedValue = generator()
        while generatedValue == nil {
            guard Date().timeIntervalSince(start) <= timeout else {
                recordAssertionFailure(message: message(), filePath: file.description, lineNumber: Int(line))
                throw TimeoutElapsedError()
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
            generatedValue = generator()
        }
        return generatedValue!
    }


    /// Records an assertion failure with the specified message and source code location.
    ///
    /// - Parameters:
    ///   - message: The message to output.
    ///   - filePath: The path to the file at which the failure occurred.
    ///   - lineNumber: The line number on which the failure occurred.
    private func recordAssertionFailure(message: String, filePath: String, lineNumber: Int) {
        #if XCODE_11
        recordFailure(withDescription: message, inFile: filePath, atLine: lineNumber, expected: true)
        #else
        let issue = XCTIssue(
            type: .assertionFailure,
            compactDescription: message,
            sourceCodeContext: XCTSourceCodeContext(
                location: XCTSourceCodeLocation(filePath: filePath, lineNumber: lineNumber)
            )
        )
        
        record(issue)
        #endif
    }
}


private struct TimeoutElapsedError : Error {
    // Intentionally empty
}
