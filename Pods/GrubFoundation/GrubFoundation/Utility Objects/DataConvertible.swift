//
//  DataConvertible.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 11/5/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `DataConvertible` declares an interface via which conforming types can be converted to and from `Data` objects.
public protocol DataConvertible {
    /// Creates a new instance using the specified data. Returns `nil` if the data is malformed or cannot be used to
    /// create an instance.
    ///
    /// - Parameter data: The data with which to initialize the instance.
    init?(data: Data)

    /// Returns a `Data` representation of the object. When passed to `init(data:)`, an equivalent object should be
    /// initialized.
    var data: Data { get }
}
