//
//  TypedExtensibleEnum.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 9/17/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `TypedExtensibleEnum` — modeled after Apple’s typed extensible enums — provides a mechanism for creating
/// a type with enumerated “cases” that can be extended outside of the module in which the type is declared.
/// They are ideal for representing string and numeric values in a strongly typed way.
///
/// `TypedExtensibleEnum`s are almost always structs, and their “cases” are declared as static constants on
/// that struct. Additional cases may be added via an extension. For example,
///
///     struct AnimatedCharacter : TypedExtensibleEnum {
///         let rawValue: String
///
///         init(_ rawValue: String) {
///             self.rawValue = rawValue
///         }
///
///         static let archer = AnimatedCharacter("Archer")
///         static let bender = AnimatedCharacter("Bender")
///         static let bullwinkle = AnimatedCharacter("Bullwinkle")
///         static let calvin = AnimatedCharacter("Calvin")
///         static let catbug = AnimatedCharacter("Catbug")
///         static let darkwingDuck = AnimatedCharacter("Darkwing Duck")
///     }
///
/// If we wanted to add a new “case” to the `AnimatedCharacter` type, we simply add it via an extension:
///
///     extension AnimatedCharacter {
///         static var duckula = AnimatedCharacter("Duckula")
///     }
///
/// Typed extensible enums are used throughout GrubFoundation when we want to use a strong type instead of an
/// arbitrary string, but we don’t know all of the possible values that should be allowed. For example,
/// `MediaType` is a typed extensible enum; the framework includes some common media types, but does not
/// attempt at providing a comprehensive list. Instead, if you need an additional media type, you can add it
/// in an extension.
public protocol TypedExtensibleEnum : RawRepresentable, Hashable where RawValue : Hashable {
    /// Creates a new instance of the type with the specified raw value.
    ///
    /// - Parameter rawValue: The raw representation of the instance.
    init(_ rawValue: RawValue)
}


public extension TypedExtensibleEnum {
    init(rawValue: RawValue) {
        self.init(rawValue)
    }
}
