//
//  AdaptiveISO8601DateFormatter.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 12/29/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `AdaptiveISO8601DateFormatter`s convert dates to and from the ISO 8601 date format. Specifically, it interprets dates
/// in the following formats: `y-MM-dd'T'HH:mm:ss.SSSZZZZZ` and `y-MM-dd'T'HH:mm:ssZZZZZ`.
///
/// - Note: While it would be preferred to use Foundation’s `ISO8601DateFormatter`, that class does not support
///   interpreting dates with two different formats (with and without fractional seconds) using the same formatter.
///   If this issue is not important to you, we recommend you use `ISO8601DateFormatter` instead of this class.
public final class AdaptiveISO8601DateFormatter : Formatter {
    /// The time zone that the formatter uses when converting dates to strings.
    public let timeZone: TimeZone


    /// The underlying date formatter that interprets ISO 8601 dates that include fractional seconds. This formatter is
    /// preferred over the no-fractional-seconds date formatter when converting strings to dates. It is the only
    /// formatter used when converting dates to strings.
    private lazy var fractionalSecondsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        return formatter
    }()


    /// The underlying date formatter that interprets ISO 8601 dates that do not include fractional seconds. When
    /// converting strings to dates, this formatter is only used if `fractionalSecondsDateFormatter` fails. It is not
    /// used when converting dates to strings.
    private lazy var noFractionalSecondsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        return formatter
    }()


    /// Creates and returns a new `AdaptiveISO8601DateFormatter` that uses `timeZone` when converting dates to strings.
    ///
    /// - Note: You should only create your own instance of `AdaptiveISO8601DateFormatter` if you need to output a
    ///   non-GMT/UTC time zone when converting dates to strings. Otherwise, it is more efficient to use the default
    ///   instance (`AdaptiveISO8601DateFormatter.default`).
    ///
    /// - Parameter timeZone: The time zone to use when converting dates to strings.
    public init(timeZone: TimeZone) {
        self.timeZone = timeZone
        super.init()
    }


    /// The shared default ISO 8601 date formatter. Its time zone is set to GMT/UTC. For memory efficiency, you should
    /// prefer using this instance unless you need to output a non-GMT/UTC time zone when converting dates to strings.
    @objc(defaultFormatter)
    public static let `default`: AdaptiveISO8601DateFormatter = {
        return AdaptiveISO8601DateFormatter(timeZone: TimeZone(secondsFromGMT: 0)!)
    }()


    // MARK: - NSCoding compliance

    /// The keys for encoding and decoding instances with keyed coders.
    private struct CodingKey {
        /// The coding key used for the `timeZone` property.
        static let timeZone = "timeZone"
    }


    public required convenience init?(coder: NSCoder) {
        guard let timeZone = coder.decodeObject(forKey: CodingKey.timeZone) as? NSTimeZone else {
            return nil
        }

        self.init(timeZone: timeZone as TimeZone)
    }


    public override func encode(with encoder: NSCoder) {
        encoder.encode(timeZone as NSTimeZone, forKey: CodingKey.timeZone)
        super.encode(with: encoder)
    }


    // MARK: - NSCopying compliance

    public override func copy(with zone: NSZone? = nil) -> Any {
        // All of our properties are immutable, so we can safely just return self
        return self
    }


    // MARK: - Formatter methods

    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                                        for string: String,
                                        errorDescription: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        // Boolean short circuiting will cause the second formatter to be invoked only if the first fails
        return fractionalSecondsDateFormatter.getObjectValue(obj, for: string, errorDescription: errorDescription) ||
            noFractionalSecondsDateFormatter.getObjectValue(obj, for: string, errorDescription: errorDescription)
    }


    public override func string(for obj: Any?) -> String? {
        return (obj as? Date).map(string(from:))
    }


    /// Creates and returns a `Date` from the specified ISO 8601 formatted string representation.
    ///
    /// - Parameter string: The ISO 8601 formatted string representation of a date.
    /// - Returns: A date, or `nil` if no valid date could be found. Valid dates are either of the form
    ///   `y-MM-dd'T'HH:mm:ss.SSSZZZZZ` and `y-MM-dd'T'HH:mm:ssZZZZZ`
    @objc(dateFromString:)
    public func date(from string: String) -> Date? {
        var date: AnyObject?
        return getObjectValue(&date, for: string, errorDescription: nil) ? date as? Date : nil
    }


    /// Creates and returns an ISO 8601 formatted string representation of the specified date.
    ///
    /// - Parameter date: The date to be represented.
    /// - Returns: An ISO 8601 formatter string representation of the specified date. The string representation includes
    ///   fractional seconds. Specifically, its format is `y-MM-dd'T'HH:mm:ss.SSSZZZZZ`.
    @objc(stringFromDate:)
    public func string(from date: Date) -> String {
        return fractionalSecondsDateFormatter.string(from: date)
    }
}
