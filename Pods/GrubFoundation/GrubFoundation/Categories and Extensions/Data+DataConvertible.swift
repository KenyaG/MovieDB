//
//  Data+DataConvertible.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 11/8/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


extension Data : DataConvertible {
    /// Creates a new `Data` instance whose contents is identical to `data`. You should never use this initializer
    /// except when doing so via the `DataConvertible` protocol.
    ///
    /// - Parameter data: The data object.
    public init?(data: Data) {
        self = data
    }


    /// Returns the data instance itself. You should never use this property except when doing so via the
    /// `DataConvertible` protocol.
    public var data: Data {
        return self
    }
}
