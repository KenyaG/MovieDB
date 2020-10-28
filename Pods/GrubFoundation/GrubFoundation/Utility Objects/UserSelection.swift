//
//  UserSelection.swift
//  GrubFoundation
//
//  Created by Pooja Pujari on 7/22/19.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `UserSelection` provides an interface for storing a user’s selected value and a default value in the same single
/// object. Each instance has two mutable properties: `defaultValue` and `selectedValue`. It also has a computed
/// property called `value`, which returns `defaultValue` if `selectedValue` is `nil`, and otherwise returns
/// `selectedValue`.
///
/// While this may initially seem like it could be easily replaced with a ternary operator, `UserSelection`
/// maintains both values, which can be useful when you need to distinguish between whether the `defaultValue` or
/// `selectedValue` is being used.
///
/// For example, suppose we want to store a user setting, but if the user hasn’t explicitly set a value, we want to fall
/// back to a value from the server. In this case, we never want to overwrite the user’s setting with a server setting.
/// We can’t store the data in a single variable, because doing so doesn’t indicate where the data came from. That is,
/// if the server value is X and the value of our variable is X, we can’t be sure that the user didn’t explicitly set
/// the value to X. This doesn’t really matter until the server value changes to Y. In that case, should we continue
/// using X or start using Y? If the user set the value to X, we should use X. Otherwise, we should use Y.
///
/// We can use a `UserSelection` instance to help with this situation. Whenever we get a value from the server, we
/// can set the instance’s `defaultValue`. Whenever the user explicitly sets a value, we can set the instance’s
/// `selectedValue`. Whenever we need to use the value, we can just access the instance’s `value` property. This ensures
/// that we never lose track of the user’s setting or conflate it with the server value.
public struct UserSelection<Value> {
    /// The value that the instance represents when its `selectedValue` is `nil`.
    ///
    /// In practice, this property should be written, not read. That is, set this value when the default value changes,
    /// but read the value of the instance using its `value` property.
    public var defaultValue: Value


    /// When non-nil, the value that the instance represents.
    /// In practice, this property should be written, not read. That is, set this value when the user’s selected value
    /// changes, but read the value of the instance using its `value` property.
    public var selectedValue: Value?


    /// Returns the value that the instance represents.
    ///
    /// This is equivalent to `(selectedValue ?? defaultValue)`.
    public var value: Value {
        return selectedValue ?? defaultValue
    }


    /// Creates a new `UserSelection` with the specified default value.
    ///
    /// - Parameter defaultValue: The default value that the instance should use. This can be changed after initialization.
    public init(defaultValue: Value) {
        self.defaultValue = defaultValue
    }
}

extension UserSelection : Equatable where Value : Equatable { }

extension UserSelection : Hashable where Value : Hashable { }

extension UserSelection : Codable where Value : Codable { }
