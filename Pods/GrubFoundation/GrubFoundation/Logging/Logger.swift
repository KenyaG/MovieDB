//
//  Logger.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 10/22/2016.
//  Copyright © 2016 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `Logger` instances log messages for a specific module and subsystem. Each logger has an associated
/// `loggableLevels` property that represents the log message levels for which it outputs log messages. This property
/// can be used to limit the output of a logger to only certain levels, e.g., `.info` or higher.
///
/// Loggers cannot write their log messages to a console, file, or other destination on their own. For that, they need
/// one or more logger destinations, which can be set using the logger’s `destinations` property. Interestingly,
/// `Logger` conforms to the `LoggerDestination` protocol and can thus be a destination for another logger. This
/// allows you to, e.g., create a logger which logs messages to the console and a file, but has a child logger that only
/// writes higher severity log messages to a database.
///
/// Here’s an example of how to initialize and use a logger that logs to the standard error device.
///
///     let logger = Logger(module: "FrameworkX", subsystem: "SubsystemY")
///     logger.destinations = [TextLoggerDestination.standardError()]
///     logger.loggableLevels = .infoOrHigher
///
///     let error = …
///     logger.logError("Uh oh, an error occurred \(error)")
///
///     let array = …
///     logger.logWarning("Something may be wrong with this array’s count: \(array.count)")
///
///     logger.logInfo("Just logging some information")
///
/// While you can initialize loggers in this way, it is probably better to create and configure a few loggers that are
/// accessible throughout your module or subsystem.
///
/// For frameworks, it is highly recommended that you include a public interface for configuring your loggers’ levels
/// and destinations and default to logging nothing and having no destinations. This allows consumers of your framework
/// to configure what they want to log, how they want it to look, and where it should be logged.
public class Logger : LoggerConfigurable, LoggerDestination {
    /// `LoggableLevels` represent the message levels that a logger will log.
    public struct LoggableLevels : OptionSet, CustomStringConvertible, Hashable {
        public let rawValue: UInt8


        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }


        /// Creates a new `LoggableLevels` instance using the specified string.
        ///
        /// This initializer exists primarily to support configuring loggers with environment variables, command-line
        /// arguments, or configuration files.
        ///
        /// The string is expected to be a space-separated list of loggable level names. The following names are
        /// recognized:
        ///
        ///   - `"verbose"`: Interpreted as `.verbose`
        ///   - `"debug"`: Interpreted as `.debug`
        ///   - `"info"`: Interpreted as `.info`
        ///   - `"warning"`: Interpreted as `.warning`
        ///   - `"error"`: Interpreted as `.error`
        ///   - `"all"`: Interpreted as `.all`
        ///   - `"debug+"`: Interpreted as `.debugAndHigher`
        ///   - `"info+"`: Interpreted as `.infoAndHigher`
        ///   - `"warning+"`: Interpreted as `.warningAndHigher`
        ///
        /// All other names are ignored. If no recognizable names are found, the new instance is `.none`.
        ///
        /// ## Examples
        ///
        ///     // Equivalent to [.verbose, .debug, .error]
        ///     let loggableLevels = Logger.LoggableLevels("verbose debug error")
        ///
        ///     // Equivalent to .none
        ///     let loggableLevels = Logger.LoggableLevels("random garbage")
        ///
        ///     // Equivalent to .debugAndHigher
        ///     let loggableLevels = Logger.LoggableLevels("debug+ random garbage")
        ///
        /// - Parameter string: A string repreentation of the loggable levels.
        public init(_ string: String) {
            self = string.lowercased().split(separator: " ").reduce(into: LoggableLevels.none) { (levels, levelString) in
                switch levelString {
                case "verbose":
                    levels.insert(.verbose)
                case "debug":
                    levels.insert(.debug)
                case "info":
                    levels.insert(.info)
                case "warning":
                    levels.insert(.warning)
                case "error":
                    levels.insert(.error)
                case "all":
                    levels.insert(.all)
                case "debug+":
                    levels.insert(.debugAndHigher)
                case "info+":
                    levels.insert(.infoAndHigher)
                case "warning+":
                    levels.insert(.warningAndHigher)
                default:
                    return
                }
            }
        }


        /// Indicates that the logger logs `.verbose` messages.
        public static let verbose = LoggableLevels(rawValue: 1 << LogMessage.Level.verbose.rawValue)

        /// Indicates that the logger logs `.debug` messages.
        public static let debug = LoggableLevels(rawValue: 1 << LogMessage.Level.debug.rawValue)

        /// Indicates that the logger logs `.info` messages.
        public static let info = LoggableLevels(rawValue: 1 << LogMessage.Level.info.rawValue)

        /// Indicates that the logger logs `.warning` messages.
        public static let warning = LoggableLevels(rawValue: 1 << LogMessage.Level.warning.rawValue)

        /// Indicates that the logger logs `.error` messages.
        public static let error = LoggableLevels(rawValue: 1 << LogMessage.Level.error.rawValue)

        /// Indicates that the logger logs all messages.
        public static let all: LoggableLevels = [.verbose, .debug, .info, .warning, .error]

        /// Indicates that the logger logs messages at the `.debug` level and higher.
        public static let debugAndHigher: LoggableLevels = [.debug, .info, .warning, .error]

        /// Indicates that the logger logs messages at the `.info` level and higher.
        public static let infoAndHigher: LoggableLevels = [.info, .warning, .error]

        /// Indicates that the logger logs messages at the `.warning` level and higher.
        public static let warningAndHigher: LoggableLevels = [.warning, .error]

        /// Indicates that the logger logs no messages.
        public static let none: LoggableLevels = []


        public var description: String {
            guard self != .none else {
                return "none"
            }

            return LogMessage.Level.allCases.compactMap { containsLevel($0) ? $0.description : nil }.joined(separator: " ")
        }


        /// Returns whether the instance contains the specified level.
        ///
        /// - Parameter level: The level.
        /// - Returns: Whether the instance contains the level.
        func containsLevel(_ level: LogMessage.Level) -> Bool {
            return contains(LoggableLevels(rawValue: 1 << level.rawValue))
        }
    }


    /// The log message levels that the logger logs.
    public var loggableLevels: LoggableLevels = .none

    /// The destinations to which the logger writes its messages.
    public var destinations: [LoggerDestination] = []

    /// The logger’s module.
    public let module: String

    /// The logger’s subsystem.
    public let subsystem: String


    /// Creates a new `Logger` with the specified module and subsystem.
    ///
    /// - Parameters:
    ///   - module: The logger’s module.
    ///   - subsystem: The logger’s subsytem.
    public init(module: String, subsystem: String) {
        self.module = module
        self.subsystem = subsystem
    }


    /// Returns whether the logger logs at the specified level.
    ///
    /// - Parameter level: The level.
    /// - Returns: Whether the logger logs at `level`.
    public func logs(at level: LogMessage.Level) -> Bool {
        return loggableLevels.containsLevel(level)
    }


    /// Logs a message at the specified level. Slightly more readable versions of this method are provided in the form
    /// of `logVerbose`, `logDebug`, `logInfo`, `logWarning`, or `logError`.
    ///
    /// - Parameters:
    ///   - text: The text of the message. This is not evalutated unless the logger logs messages at `level` and has
    ///     at least one destination.
    ///   - level:  The level of the message.
    ///   - date: The date of the message.
    ///   - file: The source file from which the message is logged.
    ///   - function: The name of the function or method from which the message is logged.
    ///   - line: The source file line number from which the message is logged.
    public func log(_ text: @autoclosure () -> String,
                    level: LogMessage.Level,
                    date: Date = Date(),
                    file: String = #file,
                    function: String = #function,
                    line: UInt = #line) {
        invokeDidLogIfNeeded(for: level)

        guard !destinations.isEmpty, logs(at: level) else {
            return
        }

        let logMessage = LogMessage(
            module: module,
            subsystem: subsystem,
            text: text(),
            level: level,
            date: date,
            file: file,
            function: function,
            line: line
        )

        writeUnconditionally(logMessage)
    }


    public func write(_ logMessage: LogMessage) {
        invokeDidLogIfNeeded(for: logMessage.level)

        if logs(at: logMessage.level) {
            writeUnconditionally(logMessage)
        }
    }


    private func writeUnconditionally(_ logMessage: LogMessage) {
        for destination in destinations {
            destination.write(logMessage)
        }
    }


    /// Invokes `DidLogWarningOrError` if `level` is `.warning` or `.error`.
    ///
    /// - Parameter level: The log level for the message being logged.
    private func invokeDidLogIfNeeded(for level: LogMessage.Level) {
        switch level {
        case .warning, .error:
            DidLogWarningOrError()
        default:
            break
        }
    }
}


/// This method exists so that programmers can add a symbolic breakpoint when an attempt is made to log a warning or
/// error message is logged, regardless of the logger configuration.
// swiftlint:disable identifier_name
private func DidLogWarningOrError() { }


public extension Logger {
    /// Logs a verbose message. The date of the message is the current date.
    ///
    /// - Parameters:
    ///   - text: The text of the message. This is not evalutated unless the logger logs verbose messages.
    ///   - file: The source file from which the message is logged.
    ///   - function: The name of the function or method from which the message is logged.
    ///   - line: The source file line number from which the message is logged.
    func logVerbose(_ text: @autoclosure () -> String,
                    file: String = #file,
                    function: String = #function,
                    line: UInt = #line) {
        log(text(), level: .verbose, file: file, function: function, line: line)
    }


    /// Logs a debug message. The date of the message is the current date.
    ///
    /// - Parameters:
    ///   - text: The text of the message. This is not evalutated unless the logger logs debug messages.
    ///   - file: The source file from which the message is logged.
    ///   - function: The name of the function or method from which the message is logged.
    ///   - line: The source file line number from which the message is logged.
    func logDebug(_ text: @autoclosure () -> String,
                  file: String = #file,
                  function: String = #function,
                  line: UInt = #line) {
        log(text(), level: .debug, file: file, function: function, line: line)
    }


    /// Logs an info message. The date of the message is the current date.
    ///
    /// - Parameters:
    ///   - text: The text of the message. This is not evalutated unless the logger logs info messages.
    ///   - file: The source file from which the message is logged.
    ///   - function: The name of the function or method from which the message is logged.
    ///   - line: The source file line number from which the message is logged.
    func logInfo(_ text: @autoclosure () -> String,
                 file: String = #file,
                 function: String = #function,
                 line: UInt = #line) {
        log(text(), level: .info, file: file, function: function, line: line)
    }


    /// Logs a warning message. The date of the message is the current date.
    ///
    /// - Parameters:
    ///   - text: The text of the message. This is not evalutated unless the logger logs warning messages.
    ///   - file: The source file from which the message is logged.
    ///   - function: The name of the function or method from which the message is logged.
    ///   - line: The source file line number from which the message is logged.
    func logWarning(_ text: @autoclosure () -> String,
                    file: String = #file,
                    function: String = #function,
                    line: UInt = #line) {
        log(text(), level: .warning, file: file, function: function, line: line)
    }


    /// Logs an error message. The date of the message is the current date.
    ///
    /// - Parameters:
    ///   - logger: The logger to log the message.
    ///   - text: The text of the message. This is not evalutated unless the logger logs error messages.
    ///   - file: The source file from which the message is logged.
    ///   - function: The name of the function or method from which the message is logged.
    ///   - line: The source file line number from which the message is logged.
    func logError(_ text: @autoclosure () -> String,
                  file: String = #file,
                  function: String = #function,
                  line: UInt = #line) {
        log(text(), level: .error, file: file, function: function, line: line)
    }
}


/// The `LoggerConfigurable` protocol declares an interface with which to configure loggers. It’s useful to modules
/// that wish to provide a public configuration API for their loggers without exposing the loggers themselves. Instead,
/// they can return a `LoggerConfigurable` via some public API, and that object can be used to configure one or more
/// loggers.
///
/// `Logger` conforms to `LoggerConfigurable`, so loggers can be returned directly as `LoggerConfigurable`s,
/// but frameworks can also wrap multiple loggers behind a single `LoggerConfigurable` if they want to provide fewer
/// points of configuration for multiple loggers.
public protocol LoggerConfigurable : AnyObject {
    /// The levels for which the logger will log.
    var loggableLevels: Logger.LoggableLevels { get set }

    /// The configured logger destinations.
    var destinations: [LoggerDestination] { get set }
}


/// `LoggerDestination` is a protocol to which all a `Logger`’s destinations must conform. It has a single method,
/// `write(_:)`, that writes a log message. Logger destinations can be binary or text files, databases, web services, or
/// anything else that can be represented by an object conforming to this protocol.
public protocol LoggerDestination {
    /// Writes the specified log message. The instance is free to only write certain log messages based on any filtering
    /// criteria it deems fit.
    func write(_ logMessage: LogMessage)
}
