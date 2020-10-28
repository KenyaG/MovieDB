//
//  LogMessage.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 6/11/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `LogMessage` models a message in a log. While they are often presented to the user as strings, representing log
/// messages as objects with distinct fields enables other higher-fidelity representations as well, for example database
/// rows.
///
/// Log messages should almost never be created directly. They are created automatically by the GrubFoundation logging
/// system.
///
/// To convert a log message into a string, use a `LogMessageFormatter`.
public struct LogMessage : Codable, Hashable {
    /// `LogMessage.Level`s indicate the level or severity of a log message.
    public enum Level : UInt8, CaseIterable, Codable, Hashable, CustomStringConvertible {
        /// Indicate that a message is very detailed and is useful only in very specific diagnostic scenarios.
        case verbose = 0

        /// Indicates that a message is fairly detailed and is useful primarily for debugging.
        case debug = 1

        /// Indicates that a message is informational.
        case info = 2

        /// Indicates that a message describes a potential problem.
        case warning = 3

        /// Indicates that a message describes an error or software fault.
        case error = 4


        public var description: String {
            switch self {
            case .verbose:
                return "verbose"
            case .debug:
                return "debug"
            case .info:
                return "info"
            case .warning:
                return "warning"
            case .error:
                return "error"
            }
        }
    }


    /// The module to which the log message pertains.
    public let module: String

    /// The subsystem to which the log message pertains.
    public let subsystem: String

    /// The text of the log message.
    public let text: String

    /// The level or severity of the log message.
    public let level: Level

    /// The date of the log message.
    public let date: Date

    /// The source file which contains the log message.
    public let file: String

    /// The function or method that contains the log message.
    public let function: String

    /// The source file line number on which the log message appears.
    public let line: UInt


    /// Creates a new `LogMessage` with the specified properties.
    ///
    /// - Parameters:
    ///   - module: The module to which the log message pertains.
    ///   - subsystem: The subsystem to which the log message pertains.
    ///   - text: The text of the log message.
    ///   - level: The level or severity of the log message.
    ///   - date: The date of the log message.
    ///   - file: The source file which contains the log message.
    ///   - function: The function or method that contains the log message.
    ///   - line: The source file line on which the log message appears.
    public init(module: String,
                subsystem: String,
                text: String,
                level: Level,
                date: Date,
                file: String,
                function: String,
                line: UInt) {
        self.module = module
        self.subsystem = subsystem
        self.text = text
        self.level = level
        self.date = date
        self.file = file
        self.function = function
        self.line = line
    }
}
