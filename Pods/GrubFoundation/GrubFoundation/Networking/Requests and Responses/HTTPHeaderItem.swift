//
//  HTTPHeaderItem.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 9/17/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// A `HTTPHeaderItem` represents a single HTTP header’s field and value.
public struct HTTPHeaderItem : Hashable {
    /// The HTTP header’s field.
    public let field: HTTPHeaderField

    /// The HTTP header’s value
    public let value: String


    /// Creates a new HTTP header item with the specified field and value.
    ///
    /// - Parameters:
    ///   - field: The HTTP header’s field.
    ///   - value: The HTTP Header’s value.
    public init(field: HTTPHeaderField, value: String) {
        self.field = field
        self.value = value
    }
}


/// `HTTPHeaderField`s represent HTTP header fields. It is implemented as a typed extensible enum with out-of-the-box
/// constants for many common header fields, including Accept, Authorization, Content Type, and User Agent. Additional
/// media types can be added in an extension.
public struct HTTPHeaderField : TypedExtensibleEnum {
    public let rawValue: String


    /// Creates a new HTTP header field with the specified header field string. The string is capitalized before being
    /// stored. For example, `"accept-encoding"` would be stored as `"Accept-Encoding"`.
    ///
    /// - Parameter rawValue: The header field string.
    public init(_ rawValue: String) {
        self.rawValue = (rawValue as NSString).capitalized
    }
}


public extension HTTPHeaderField {
    /// The Accept header field, `"Accept"`.
    static let accept = HTTPHeaderField("Accept")

    /// The Accept Character Set header field, `"Accept-Charset"`.
    static let acceptCharset = HTTPHeaderField("Accept-Charset")

    /// The Accept Encoding header field, `"Accept-Encoding"`.
    static let acceptEncoding = HTTPHeaderField("Accept-Encoding")

    /// The Accept Language header field, `"Accept-Language"`.
    static let acceptLanguage = HTTPHeaderField("Accept-Language")

    /// The Authorization header field, `"Authorization"`.
    static let authorization = HTTPHeaderField("Authorization")

    /// The Cookie header field, `"Cookie"`.
    static let cookie = HTTPHeaderField("Cookie")

    /// The Content Type header field, `"Content-Type"`.
    static let contentType = HTTPHeaderField("Content-Type")

    /// The User Agent header field, `"User-Agent"`.
    static let userAgent = HTTPHeaderField("User-Agent")
}


public extension URLRequest {
    /// Incrementally adds the specified HTTP header field/value pair to the instance’s HTTP header dictionary.
    ///
    /// This method provides the ability to add values to header fields incrementally. If a value was previously set for
    /// the specified field, a comma is appended to the existing value followed by the new value.
    ///
    /// - Parameters:
    ///   - value: The header value.
    ///   - field: The head field.
    mutating func addValue(_ value: String, for field: HTTPHeaderField) {
        addValue(value, forHTTPHeaderField: field.rawValue)
    }


    /// Incrementally adds the specified HTTP header item to the instance’s HTTP header dictionary.
    ///
    /// This method provides the ability to add values to header fields incrementally. If a value was previously set for
    /// the specified field, a comma is appended to the existing value followed by the new value.
    ///
    /// - Parameter headerItem: The header item to incrementally add.
    mutating func add(_ headerItem: HTTPHeaderItem) {
        addValue(headerItem.value, for: headerItem.field)
    }


    /// The instance’s HTTP header dictionary as an array of HTTP header items. When setting this property, if a header
    /// field appears multiple times in the array, the values for those fields are added incrementally.
    var httpHeaderItems: [HTTPHeaderItem]? {
        get {
            guard let headers = allHTTPHeaderFields else {
                return nil
            }

            return headers.map { HTTPHeaderItem(field: HTTPHeaderField($0), value: $1) }
        }


        set {
            // Clear the existing fields
            if let fields = allHTTPHeaderFields?.keys {
                for field in fields {
                    setValue(nil, forHTTPHeaderField: field)
                }
            }

            guard let items = newValue else {
                allHTTPHeaderFields = nil
                return
            }

            for item in items {
                add(item)
            }
        }
    }


    /// Sets the specified HTTP header item’s field and value.
    ///
    /// - Parameter headerItem: The header item from which to get the field and value.
    mutating func set(_ headerItem: HTTPHeaderItem) {
        setValue(headerItem.value, for: headerItem.field)
    }


    /// Sets the value for the specified HTTP header field.
    ///
    /// - Parameters:
    ///   - value: The value to set. If `nil`, the header field is removed from the instance’s HTTP header dictionary.
    ///   - field: The HTTP header field for which to set the value.
    mutating func setValue(_ value: String?, for field: HTTPHeaderField) {
        setValue(value, forHTTPHeaderField: field.rawValue)
    }


    /// Returns the value for the specified HTTP header field.
    ///
    /// - Parameter field: The HTTP header field.
    /// - Returns: The value for the HTTP header field or `nil` if no such header exists.
    func value(for field: HTTPHeaderField) -> String? {
        return value(forHTTPHeaderField: field.rawValue)
    }
}


public extension HTTPURLResponse {
    /// The instance’s HTTP header dictionary as an array of HTTP header items.
    var httpHeaderItems: [HTTPHeaderItem] {
        return allHeaderFields.compactMap { (field, value) in
            guard let field = field as? String, let value = value as? String else {
                return nil
            }

            return HTTPHeaderItem(field: HTTPHeaderField(field), value: value)
        }
    }
}
