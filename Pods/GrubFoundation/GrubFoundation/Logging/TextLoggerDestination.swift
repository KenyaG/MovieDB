//
//  TextLoggerDestination.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 6/12/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `TextLoggerDestination`s write log messages to their destinations as text. They are appropriate to use to write
/// to a console device, e.g., standard error, or to a text file. This can be easily accomplished using `FileHandle`.
/// The type provides a convenient factory method for creating a text destination for the standard error device.
///
/// Each instance has an associated data writer, log message formatter, and string encoding. When writing a log message,
/// the instance converts the log message to a string using the formatter and appends a newline to the result. It then
/// encodes that string as `Data` in its associated string encoding. Finally, it writes that data using its data writer.
///
/// Because writing text to a destination should typically happen serially, `TextLoggerDestination` has an
/// initializer that conveniently wraps a data writer in a serial data writer. In general, you should use this API
/// unless you have a specific reason not to.
public class TextLoggerDestination : LoggerDestination {
    /// The instance’s data writer.
    public let dataWriter: DataWriter

    /// The string encoding for the destination. Defaults to `.utf8`.
    public let encoding: String.Encoding

    /// The instance’s log message formatter.
    ///
    /// The default formatter is a `LogMessageFormatter` configured with the default date and log level formatters.
    public var formatter: LogMessageFormatting = LogMessageFormatter()


    /// Creates a new `TextLoggerDestination` with the specified data writer and encoding.
    ///
    /// - Note: You should only use this method if you are sure you do not want serial writes to the data writer,
    ///   because, e.g., your data writer already enforces a serial policy or you only perform writes on one thread.
    ///   Otherwise, use `init(serializingWritesTo:encoding:)`.
    ///
    /// - Parameters:
    ///   - dataWriter: The data writer.
    ///   - encoding: The encoding to use when converting strings to data.
    public init(dataWriter: DataWriter, encoding: String.Encoding = .utf8) {
        self.dataWriter = dataWriter
        self.encoding = encoding
    }


    /// Creates a new `TextLoggerDestination` that performs serial writes to the data writer. It does this by
    /// wrapping the data writer in a serial data writer if it is not a `SerialDataWriter` instance.
    ///
    /// - Parameters:
    ///   - dataWriter: The data writer to write serially to.
    ///   - encoding: The encoding to use when converting strings to data.
    public convenience init(serializingWritesTo dataWriter: DataWriter, encoding: String.Encoding = .utf8) {
        let serialDataWriter = dataWriter as? SerialDataWriter ?? SerialDataWriter(dataWriter)
        self.init(dataWriter: serialDataWriter, encoding: encoding)
    }


    /// Returns a new text destination that writes serially to the standard error device using UTF-8.
    public static func standardError() -> TextLoggerDestination {
        return TextLoggerDestination(dataWriter: SerialDataWriter.standardError)
    }


    /// Writes the log message to the instance’s data writer.
    ///
    /// The data written to the data writer is a formatted version of the log message (from the instance’s formatter)
    /// with a newline appended to it encoded using the instance’s string encoding.
    ///
    /// No guarantees are made about whether writes are synchronous or not.
    ///
    /// - Parameter logMessage: The log message to write.
    public func write(_ logMessage: LogMessage) {
        let text = formatter.string(from: logMessage).appending("\n")
        guard let data = text.data(using: encoding) else {
            return
        }

        dataWriter.write(data)
    }
}
