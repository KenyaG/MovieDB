//
//  LogMessageFormatter.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 6/12/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `LogMessageFormatting` provides an interface to convert log messages into strings.
public protocol LogMessageFormatting {
    /// Returns a string representation of the log message.
    ///
    /// - Parameter logMessage: The log message.
    /// - Returns: A string representation of the log message.
    func string(from logMessage: LogMessage) -> String
}


/// Instances of `LogMessageFormatter` convert `LogMessage`s into strings. Each instance has a log message format
/// string that defines the format of the log message as well as date and log message level formatters to format the
/// message’s level and date.
public class LogMessageFormatter : LogMessageFormatting {
    /// The template string that is used to implement log message formatting..
    private lazy var template = StringTemplate<LogMessagePlaceholder>("[{date} {module}.{subsystem}] {level}: {text}")


    /// The instance’s log message format. Each format string can contain a set of placeholders along with any other
    /// characters you want. During formatting, the placeholders are replaced with data from the log message.
    ///
    /// The placeholders and their corresponding replacements are as follows:
    ///
    ///   - `{date}`: the message’s date (after it is formatted using the formatter’s date formatter)
    ///   - `{file}`: the message’s file
    ///   - `{filename}`: the last path component of the message’s file
    ///   - `{function}`: the message’s function
    ///   - `{level}`: the message’s level (converted using the formatter’s log level formatter)
    ///   - `{line}`: the message’s line
    ///   - `{module}`: the message’s module
    ///   - `{subsystem}`: the message’s subsystem
    ///   - `{text}`: the message’s text
    ///
    /// All other characters in the format string are left untouched. For example, suppose you want to format log messages
    /// like so:
    ///
    ///     [«Date» «Level»] «Module».«Subsystem»: «Text»
    ///
    /// To do this, we would set the log message format as follows
    ///
    ///     formatter.logMessageFormat = "[{date} {level}] {module}.{subsystem}: {text}";
    public var logMessageFormat: String {
        get {
            return template.template
        }

        set {
            template.template = newValue
        }
    }


    /// The date formatter that the instance uses to format log message dates. The default date formatter has a fixed
    /// date format of "y-MM-dd HH:mm:ss.SSS" and uses the auto-updating current locale and the local time zone.
    public lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale.autoupdatingCurrent
        formatter.timeZone = TimeZone.autoupdatingCurrent
        return formatter
    }()


    /// The instance’s log message level formatter
    public var logMessageLevelFormatter: LogMessageLevelFormatting = LogMessageLevelFormatter()


    /// Creates a new `LogMessageFormatter`.
    public init() {
        // Intentionally empty.
    }


    /// Returns a string representation of the specified log message using the formatter’s current settings.
    ///
    /// - Parameter logMessage: The log message to format.
    /// - Returns: A formatted log message string.
    public func string(from logMessage: LogMessage) -> String {
        let values = LogMessagePlaceholder.Values(
            logMessage: logMessage,
            dateFormatter: dateFormatter,
            logMessageLevelFormatter: logMessageLevelFormatter
        )
        return template.substituting(values)
    }
}


/// LogMessagePlaceholder defines the placeholders that can be substituted in a log message format string.
private enum LogMessagePlaceholder : String, StringTemplatePlaceholder {
    /// `Values` combines a log message with the date formatter and log message level formatter needed to format it.
    struct Values {
        /// The log message whose data is being substituted for the placeholder values.
        let logMessage: LogMessage

        /// The date formatter used to substitute the log message’s `date`.
        let dateFormatter: DateFormatter

        /// The log message level formatter used to substitute the log message’s `level`.
        let logMessageLevelFormatter: LogMessageLevelFormatting
    }


    /// The date placeholder. This is replaced with a formatted version of the log message’s `date`.
    case date = "{date}"

    /// The file placeholder. This is replaced with the log message’s `file`.
    case file = "{file}"

    /// The filename placeholder. This is replaced with the last path component of the log message’s `file`.
    case filename = "{filename}"

    /// The function placeholder. This is replaced with the log message’s `function`.
    case function = "{function}"

    /// The level placeholder. This is replaced with a formatted version of the log message’s `level`.
    case level = "{level}"

    /// The line placeholder. This is replaced with the log message’s `line`.
    case line = "{line}"

    /// The line placeholder. This is replaced with the log message’s `module`.
    case module = "{module}"

    /// The line placeholder. This is replaced with the log message’s `subsystem`.
    case subsystem = "{subsystem}"

    /// The line placeholder. This is replaced with the log message’s `text`.
    case text = "{text}"


    func substitution(from values: Values) -> String {
        let message = values.logMessage

        switch self {
        case .date:
            return values.dateFormatter.string(from: message.date)
        case .file:
            return message.file
        case .filename:
            return (message.file as NSString).lastPathComponent
        case .function:
            return message.function
        case .level:
            return values.logMessageLevelFormatter.string(from: message.level)
        case .line:
            return String(message.line)
        case .module:
            return message.module
        case .subsystem:
            return message.subsystem
        case .text:
            return message.text
        }
    }
}
