//
//  HTTPResponseError.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 3/26/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `HTTPResponseError`s describe errors that occur when attempting to interpret an HTTP response.
public enum HTTPResponseError : LocalizedError {
    /// Indicates that no response was received.
    case noResponse

    /// Indicates that the response was not an instance of `HTTPURLResponse`. Its associated object is the `URLResponse`
    /// that was received.
    case nonHTTPURLResponse(URLResponse)

    /// Indicates that the status code was invalid. Its associated object is the `HTTPResponse<Data>` whose status
    /// code was invalid.
    case invalidStatusCode(HTTPResponse<Data>)


    public var errorDescription: String? {
        switch self {
        case .noResponse:
            return localizedString("HTTPResponseError.noResponse")
        case .nonHTTPURLResponse:
            return localizedString("HTTPResponseError.nonHTTPURLResponse")
        case let .invalidStatusCode(httpResponse):
            let format = localizedString("HTTPResponseError.invalidStatusCodeFormat")
            let statusCode = httpResponse.response.httpStatusCode
            return String(format: format, statusCode.rawValue, statusCode.localizedDescription)
        }
    }
}
