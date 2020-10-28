//
//  URLPathComponent.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 2/1/2020.
//  Copyright © 2020 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `URLPathComponent`s represent individual components of a URL’s path. They are used to securely create paths for
/// `WebServiceRequest`s.
public struct URLPathComponent : Codable, ExpressibleByStringLiteral, Hashable, RawRepresentable {
    public typealias StringLiteralType = String
    public let rawValue: String


    /// Creates a new `URLPathComponent` whose raw value is the specified string with `"/"` characters removed.
    ///
    /// If a `"/"` character is removed, a message will be logged at `warning` level to GrubFoundation’s networking
    /// logger.
    ///
    /// - Parameter rawValue: The raw
    public init(_ rawValue: String) {
        self.rawValue = rawValue.replacingOccurrences(of: "/", with: "")

        if self.rawValue.count < rawValue.count {
            networkingLogger.logWarning("Created URLPathComponent with rawValue=\"\(rawValue)\"; Using \"\(self.rawValue)\" instead.")
        }
    }


    public init(rawValue: String) {
        self.init(rawValue)
    }


    public init(stringLiteral value: String) {
        self.init(value)
    }
}
