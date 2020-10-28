//
//  DataWriter.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 6/11/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// The `DataWriter` protocol defines a simple interface for writing data to a conforming instance.
public protocol DataWriter {
    /// Writes the specified data to the instance.
    ///
    /// - Parameter data: The data to write.
    func write(_ data: Data)
}


extension FileHandle : DataWriter { }
