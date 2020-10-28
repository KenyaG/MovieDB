//
//  JSONDecoder+DateDecoding.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 3/12/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension JSONDecoder.DateDecodingStrategy {
    /// Returns a custom date decoding strategy that behaves as follows:
    ///
    ///   - If the decoded value is a string, it is interpreted as an ISO 8601 string. For more details, see
    ///     `AdaptiveISO8601DateFormatter`
    ///   - If the decoded value is numeric, it is initially interpreted as the number of seconds since 1970. If that
    ///     date is on or before `latestDateToInterpretUsingSeconds`, then the date is returned. Otherwise, the decoded
    ///     value is interpreted as the number of milliseconds since 1970.
    ///   - If the date is in any other format, a `DecodingError` is thrown.
    ///
    /// - Parameter latestDateToInterpretUsingSeconds: The latest date to interpret using seconds. By default, this date
    ///   is 3,153,600,000 seconds—approximately 100 years—in the future. This should enable unambiguous interpretation
    ///   of any date after late February 1970.
    /// - Returns: A custom date decoding strategy that behaves as described above.
    static func adaptiveDateDecodingStrategy(latestDateToInterpretUsingSeconds: Date? = nil) -> JSONDecoder.DateDecodingStrategy {
        return .custom { (decoder) in
            let container = try decoder.singleValueContainer()

            if let string = try? container.decode(String.self),
                let date = AdaptiveISO8601DateFormatter.default.date(from: string) {
                return date
            } else if let double = try? container.decode(Double.self) {
                let secondsDate = Date(timeIntervalSince1970: double)
                let latestSecondsDate = latestDateToInterpretUsingSeconds ?? Date(timeIntervalSinceNow: 3_153_600_000)
                return secondsDate <= latestSecondsDate ? secondsDate : Date(millisecondsSince1970: double)
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "date does not match any known format")
        }
    }
}


public extension JSONDecoder {
    /// Creates a new, reusable JSON decoder with the default formatting settings and decoding strategies, except that
    /// date decoding strategy is the `adaptiveDateDecodingStrategy`.
    ///
    /// - Parameter date: The latest date to interpret using seconds. This is used to initialize the
    ///  `adaptiveDateDecodingStrategy`. If nil, the default is used.
    /// - Returns: A JSON decoder that uses the `adaptiveDateDecodingStrategy` for date decoding. You can further
    ///   customize the JSON decoder after it is returned.
    static func adaptiveDateDecodingJSONDecoder(latestDateToInterpretUsingSeconds date: Date? = nil) -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .adaptiveDateDecodingStrategy(latestDateToInterpretUsingSeconds: date)
        return jsonDecoder
    }
}
