//
//  SerialDataWriter.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 6/11/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `SerialDataWriter`s enforce a serial write policy on another data writer. When using a serial data writer, only
/// one thread writes to the destination at a time and each write completes before the next write starts. Note, however,
/// that the writes are not serialized with external data writes. That is, if you have another object writing to the
/// destination from another thread, you will probably get undesired results. This is highly discouraged.
///
/// Serial data writers are primarily useful when you have multiple objects writing to the same destination, e.g., a
/// file or the console. In these cases, you may want to configure each object differently—with different formatting
/// options, for example—but still serialize all writes to the ultimate destination. In these cases, you can wrap your
/// file or console writer in a serial data writer and share that amongs the different objects.
public class SerialDataWriter : DataWriter {
    /// The data writer whose writes the instance serializes.
    public let dataWriter: DataWriter

    /// The dispatch queue used to serialize writes to `dataWriter`.
    private let queue = DispatchQueue(label: "com.grubhub.GrubFoundation.SerialDataWriter")

    /// A shared instance that performs serial writes to the standard error device.
    public static let standardError = SerialDataWriter(FileHandle.standardError)


    ///  Creates a new `SerialDataWriter` with the specified data writer.
    ///
    /// - Parameter dataWriter: The data writer whose writes will be serialized.
    public init(_ dataWriter: DataWriter) {
        self.dataWriter = dataWriter
    }


    public func write(_ data: Data) {
        queue.sync {
            dataWriter.write(data)
        }
    }
}
