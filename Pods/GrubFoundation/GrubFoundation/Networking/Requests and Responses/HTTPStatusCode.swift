//
//  HTTPStatusCode.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 3/26/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `HTTPStatusCode`s represent HTTP status codes symbolically. Along with descriptive names, each instance can
/// return whether it is an informational, success, redirect, client error, or server error code.
public struct HTTPStatusCode : TypedExtensibleEnum {
    /// The range of informational status codes.
    private static let informationalRange = 100 ..< 200

    /// The range of success status codes.
    private static let successRange = 200 ..< 300

    /// The range of redirect status codes.
    private static let redirectRange = 300 ..< 400

    /// The range of client error status codes.
    private static let clientErrorRange = 400 ..< 500

    /// The range of server error status codes.
    private static let serverErrorRange = 500 ..< 600

    public let rawValue: Int

    public static let `continue` = HTTPStatusCode(100)
    public static let switchingProtocols = HTTPStatusCode(101)

    public static let noError = HTTPStatusCode(200)
    public static let created = HTTPStatusCode(201)
    public static let accepted = HTTPStatusCode(202)
    public static let nonAuthoritativeInformation = HTTPStatusCode(203)
    public static let noContent = HTTPStatusCode(204)
    public static let resetContent = HTTPStatusCode(205)
    public static let partialContent = HTTPStatusCode(206)

    public static let multipleChoices = HTTPStatusCode(300)
    public static let movedPermanently = HTTPStatusCode(301)
    public static let found = HTTPStatusCode(302)
    public static let seeOther = HTTPStatusCode(303)
    public static let notModified = HTTPStatusCode(304)
    public static let needsProxy = HTTPStatusCode(305)
    public static let redirected = HTTPStatusCode(306)
    public static let temporarilyRedirected = HTTPStatusCode(307)

    public static let badRequest = HTTPStatusCode(400)
    public static let unauthorized = HTTPStatusCode(401)
    public static let paymentRequired = HTTPStatusCode(402)
    public static let forbidden = HTTPStatusCode(403)
    public static let notFound = HTTPStatusCode(404)
    public static let methodNotAllowed = HTTPStatusCode(405)
    public static let unacceptable = HTTPStatusCode(406)
    public static let proxyAuthenticationRequired = HTTPStatusCode(407)
    public static let requestTimedOut = HTTPStatusCode(408)
    public static let conflict = HTTPStatusCode(409)
    public static let noLongerExists = HTTPStatusCode(410)
    public static let lengthRequired = HTTPStatusCode(411)
    public static let preconditionFailed = HTTPStatusCode(412)
    public static let requestTooLarge = HTTPStatusCode(413)
    public static let requestedURLTooLong = HTTPStatusCode(414)
    public static let unsupportedMediaType = HTTPStatusCode(415)
    public static let requestedRangeNotSatisfiable = HTTPStatusCode(416)
    public static let expectationFailed = HTTPStatusCode(417)
    public static let unprocessableEntity = HTTPStatusCode(422)

    public static let internalServerError = HTTPStatusCode(500)
    public static let unimplemented = HTTPStatusCode(501)
    public static let badGateway = HTTPStatusCode(502)
    public static let serviceUnavailable = HTTPStatusCode(503)
    public static let gatewayTimedOut = HTTPStatusCode(504)
    public static let unsupportedVersion = HTTPStatusCode(505)


    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }


    /// A localized description of the status code.
    public var localizedDescription: String {
        switch self {
        case .unprocessableEntity:
            return localizedString("HTTPStatusCode.unprocessableEntity")
        default:
            return HTTPURLResponse.localizedString(forStatusCode: rawValue)
        }
    }


    /// Whether the instance is in the informational range, i.e., [100, 200).
    public var isInformational: Bool {
        return HTTPStatusCode.informationalRange.contains(rawValue)
    }


    /// Whether the instance is in the success range, i.e., [200, 300).
    public var isSuccess: Bool {
        return HTTPStatusCode.successRange.contains(rawValue)
    }


    /// Whether the instance is in the redirect range, i.e., [300, 400).
    public var isRedirect: Bool {
        return HTTPStatusCode.redirectRange.contains(rawValue)
    }


    /// Whether the instance is in the client error range, i.e., [400, 500).
    public var isClientError: Bool {
        return HTTPStatusCode.clientErrorRange.contains(rawValue)
    }


    /// Whether the instance is in the server error range, i.e., [500, 600).
    public var isServerError: Bool {
        return HTTPStatusCode.serverErrorRange.contains(rawValue)
    }


    /// Whether the instance is either a client or server error.
    public var isError: Bool {
        return isClientError || isServerError
    }
}


public extension HTTPURLResponse {
    /// Returns the `HTTPStatusCode` for the HTTP URL response.
    var httpStatusCode: HTTPStatusCode {
        return HTTPStatusCode(statusCode)
    }
}
