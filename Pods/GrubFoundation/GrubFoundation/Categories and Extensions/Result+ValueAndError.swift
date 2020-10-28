//
//  Result+ValueAndError.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 9/17/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension Result {
    /// If the instance is `.success`, returns its associated value, otherwise returns `nil`.
    ///
    /// The utility of this property is limited and should only be used when you want the value and don’t need it to be
    /// non-optional. It is primarily intended for use when aggregating the values of many results at once:
    ///
    ///     let results: [Result<String, Error>] = …
    ///     let values = results.compactMap { $0.value }
    ///
    /// More explicitly, the following usage is considered an anti-pattern and should be avoided:
    ///
    ///     if let value = result.value {
    ///         …
    ///     } else if let error = result.error {
    ///         …
    ///     }
    ///
    /// In such cases, use a do-try block with `get()` instead.
    var value: Success? {
        return try? get()
    }


    /// If the instance is `.failure`, returns its associated error, otherwise returns `nil`.
    ///
    /// The utility of this property is limited and should only be used when you want the error and don’t need it to be
    /// non-optional. It is primarily intended for use when aggregating the errors of many results at once:
    ///
    ///     let results: [Result<String, Error>] = …
    ///     let errors = results.compactMap { $0.error }
    ///
    /// More explicitly, the following usage is considered an anti-pattern and should be avoided:
    ///
    ///     if let value = result.value {
    ///         …
    ///     } else if let error = result.error {
    ///         …
    ///     }
    ///
    /// In such cases, use a do-try block with `get()` instead.
    var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
