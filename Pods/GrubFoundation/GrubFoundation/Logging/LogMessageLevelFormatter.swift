//
//  LogMessageLevelFormatter.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 6/12/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `LogMessageLevelFormatting` provides an interface to convert log message levels into strings.
public protocol LogMessageLevelFormatting {
    /// Returns a string representation of the log message level.
    ///
    /// - Parameter level: The log message level.
    /// - Returns: A string representation of the log message level.
    func string(from level: LogMessage.Level) -> String
}


/// `LogMessageLevelFormatter` formats log message levels by returning an uppercased version of their name, e.g.,
/// "VERBOSE" for `.verbose`, "DEBUG" for `.debug`, etc.
public struct LogMessageLevelFormatter : LogMessageLevelFormatting {
    /// Creates a new `LogMessageLevelFormatter`.
    public init() {
        // Intentionally empty
    }


    public func string(from level: LogMessage.Level) -> String {
        // We duplicate functionality from `LogMessage.Level.description` because this is more efficient than
        // dynamically uppercasing the result of that method, especially since it’ll be invoked from the log message
        // formatter for every message that is logged to the console or a text file
        switch level {
        case .verbose:
            return "VERBOSE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        }
    }
}
