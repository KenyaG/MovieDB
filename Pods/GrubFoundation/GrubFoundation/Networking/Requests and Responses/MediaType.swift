//
//  MediaType.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 9/17/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation

#if os(macOS)
    import CoreServices
#else
    import MobileCoreServices
#endif


/// `MediaType`s represent media types, which are sometimes called MIME types. It is implemented as a typed
/// extensible enum with out-of-the-box constants for many common media types, including JSON, plain text, GIF, JPEG,
/// and PNG. Additional media types can be added in an extension.
public struct MediaType : TypedExtensibleEnum {
    public let rawValue: String


    /// Creates a new instance with the specified media type string. The string is automatically lowercased before being
    /// stored.
    ///
    /// - Parameter rawValue: The media type string.
    public init(_ rawValue: String) {
        self.rawValue = rawValue.lowercased()
    }


    /// Returns the uniform type identifier that corresponds to the media type. If a translated UTI cannot be found, the
    /// value returned will start with the prefix `dyn.`. This allows you to pass the UTI around and convert it back to
    /// the original tag.
    public var uniformTypeIdentifier: String {
        let unmanagedType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, rawValue as CFString, nil)
        precondition(unmanagedType != nil, "Passed invalid tag class to UTTypeCreatePreferredIdentifierForTag")
        return unmanagedType!.takeRetainedValue() as String
    }
}


public extension MediaType {
    /// The media type for GIF images, `"image/gif"`.
    static let gif = MediaType("image/gif")

    /// The media type for JPEG images, `"image/jpeg"`.
    static let jpeg = MediaType("image/jpeg")

    /// The media type for JSON data, `"application/json"`.
    static let json = MediaType("application/json")

    /// The media type for arbitrary binary data, `"application/octet-stream"`.
    static let octetStream = MediaType("application/octet-stream")

    /// The media type for plain text, `"text/plain"`.
    static let plainText = MediaType("text/plain")

    /// The media type for PNG images, `"image/png"`.
    static let png = MediaType("image/png")

    /// The media type for HTML form data, `"application/x-www-form-urlencoded"`.
    static let wwwFormURLEncoded = MediaType("application/x-www-form-urlencoded")

    /// The media type for XML, `"application/xml"`.
    static let xml = MediaType("application/xml")
}


extension MediaType {
    /// Returns an HTTP header item whose field is Accept and whose value is the instance.
    var acceptHeaderItem: HTTPHeaderItem {
        return HTTPHeaderItem(field: .accept, value: rawValue)
    }


    /// Returns an HTTP header item whose field is Content-Type and whose value is the instance.
    var contentTypeHeaderItem: HTTPHeaderItem {
        return HTTPHeaderItem(field: .contentType, value: rawValue)
    }
}
