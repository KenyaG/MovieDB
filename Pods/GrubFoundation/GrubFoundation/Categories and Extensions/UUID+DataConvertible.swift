//
//  UUID+DataConvertible.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 11/5/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


extension UUID : DataConvertible {
    /// Creates a new UUID using `data`. Returns `nil` if `data` is not exactly 16 bytes in length.
    ///
    /// - Parameter data: The data to convert into a UUID.
    public init?(data: Data) {
        guard data.count == 16 else {
            return nil
        }

        let uuidBuffer: uuid_t = (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7],
                                  data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15])

        self = UUID(uuid: uuidBuffer)
    }


    public var data: Data {
        let tuple = uuid
        let bytes = [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7,
                     tuple.8, tuple.9, tuple.10, tuple.11, tuple.12, tuple.13, tuple.14, tuple.15]

        return Data(bytes)
    }
}
