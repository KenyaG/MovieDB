//
//  HTTPBody.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 9/17/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `HTTPBody` represents an HTTP body by pairing the `Data` of the body with a media type.
public struct HTTPBody {
    /// The HTTP body’s content type.
    public let contentType: MediaType

    /// The HTTP body’s data.
    public let data: Data


    /// Creates a new `HTTPBody` instance with the specified content type and data.
    ///
    /// - Parameters:
    ///   - contentType: The content type of the HTTP body.
    ///   - data: The data of the HTTP body.
    public init(contentType: MediaType, data: Data) {
        self.contentType = contentType
        self.data = data
    }
}
