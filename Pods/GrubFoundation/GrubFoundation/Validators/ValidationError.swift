//
//  ValidationError.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 8/2/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `ValidationError`s indicate that an error occurred when validating a value. They are meant to convey information
/// to a programmer about a validation failure. They are not meant to be used to communicate validation failures to
/// users.
///
/// While the validators included with GrubFoundation throw `ValidationError`s, you may throw any error you wish in
/// your own validators.
public struct ValidationError : LocalizedError {
    /// A textual explanation for why validation failed. No guarantee is made that this string is localized.
    public let reason: String


    /// Creates a new `ValidationError` with the specified reason message.
    ///
    /// - Parameter reason: A textual explanation for why validation failed.
    public init(_ reason: String) {
        self.reason = reason
    }


    public var errorDescription: String? {
        return String(format: localizedString("ValidationError.descriptionFormat"), reason)
    }
}
