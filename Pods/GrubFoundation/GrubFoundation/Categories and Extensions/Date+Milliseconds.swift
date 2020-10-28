//
//  Date+Milliseconds.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 3/12/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension Date {
    /// Creates a date value initialized relative to 00:00:00 UTC on 1 January 1970 by a given number of milliseconds.
    /// - Parameter millisecondsSince1970: The number of milliseconds since 1970.
    init(millisecondsSince1970: Int64) {
        self.init(millisecondsSince1970: Double(millisecondsSince1970))
    }


    /// Creates a date value initialized relative to 00:00:00 UTC on 1 January 1970 by a given number of milliseconds.
    /// - Parameter millisecondsSince1970: The number of milliseconds since 1970.
    init(millisecondsSince1970: Double) {
        self.init(timeIntervalSince1970: millisecondsSince1970 / 1000)
    }


    /// The number of milliseconds between the date value and 00:00:00 UTC on 1 January 1970.
    ///
    /// This property’s value is negative if the date object is earlier than 00:00:00 UTC on 1 January 1970.
    var millisecondsSince1970: Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}
