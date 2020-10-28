//
//  GrubFoundation.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 11/7/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// The `GrubFoundation` type provides an interface for configuring the GrubFoundation framework.
public enum GrubFoundation {
    /// An object with which to configure GrubFoundation’s networking logger. By default, the networking logger has no
    /// loggable levels and no configured destinations.
    ///
    /// The networking logger logs messages pertaining to network activity and reachability. The logger is very
    /// low-traffic and should only really be used when diagnosing errors. Here are a few examples of the messages it
    /// logs:
    ///
    ///   - At the `.info` level, `NetworkReachability` logs whenever network reachability changes.
    ///   - At the `.verbose` level, `HTTPClient`, `AuthenticatingHTTPClient`, and `WebServiceClient` log every response
    ///     they receive.
    public static let networkingLoggerConfiguration: LoggerConfigurable = networkingLogger
}


/// The networking logger used by GrubFoundation.
let networkingLogger = Logger(module: "GrubFoundation", subsystem: "networking")


extension Bundle {
    /// The `Bundle` for GrubFoundation.
    static var grubFoundation: Bundle {
        return Bundle(identifier: "com.grubhub.GrubFoundation")!
    }
}


/// Returns a localized string from the framework’s string table.
///
/// - Parameter key: The key for the string in the table.
/// - Returns: A localized version of the string designated by `key` in GrubFoundation’s string table.
func localizedString(_ key: String) -> String {
    return NSLocalizedString(key, bundle: .grubFoundation, comment: "")
}
