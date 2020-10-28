//
//  URL+Random.swift
//  GrubTest
//
//  Created by Prachi Gauriar on 6/4/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension URL {
    /// Returns a randomly generated URL. This works by simply invoking `URLComponents.random(using:)` and returning the
    /// URL from that instance.
    ///
    /// - Parameter generator: The random number generator to use when creating the new random value.
    /// - Returns: A randomly generated URL.
    static func random<RNG>(using generator: inout RNG) -> URL where RNG : RandomNumberGenerator {
        return URLComponents.random(using: &generator).url!
    }
}


public extension URLComponents {
    /// Returns a randomly generated URL components instance with the following properties:
    ///
    ///   - Its scheme is either `http` or `https`
    ///   - Its host is of the form *subdomain«Random1».domain«Random2».com*, where *«Random1»* and *«Random2»* are
    ///     random alphanumeric strings with lengths between 1 and 10.
    ///   - It has an optional fragment that is a random alphanumeric string 1–10 characters in length.
    ///   - It has between 1 and 5 path components, each of which are random strings 1–10 characters in length that
    ///     may contain a space character, but are otherwise alphanumeric.
    ///   - It has between 1 and 5 query items, each of which has keys and values which are random alphanumeric strings
    ///     1–10 characters in length
    ///
    /// - Parameter generator: The random number generator to use when creating the new random value.
    /// - Returns: A randomly generated URL
    static func random<RNG>(using generator: inout RNG) -> URLComponents where RNG : RandomNumberGenerator {
        func randomString() -> String {
            let count = Int.random(in: 1 ... 10, using: &generator)
            return String.randomAlphanumeric(count: count, using: &generator)
        }

        func randomBool() -> Bool {
            return Bool.random(using: &generator)
        }


        var components = URLComponents()
        components.scheme = randomBool() ?  "http" : "https"
        components.host = "subdomain\(randomString()).domain\(randomString()).com"
        components.fragment = randomBool() ? randomString() : nil

        let pathComponentCount = Int.random(in: 1 ... 5, using: &generator)
        let pathComponents = (0 ..< pathComponentCount).map { (_) -> String in
            var pathComponent = randomString()
            if randomBool() {
                let randomCharacterIndex = Int.random(in: 0 ..< pathComponent.count, using: &generator)
                if let spaceIndex = pathComponent.index(pathComponent.startIndex, offsetBy: randomCharacterIndex, limitedBy: pathComponent.endIndex) {
                    pathComponent.replaceSubrange(spaceIndex ..< pathComponent.index(after: spaceIndex), with: " ")
                }
            }

            return pathComponent
        }

        components.path = "/\(pathComponents.joined(separator: "/"))"

        let queryItemCount = Int.random(in: 1 ... 5, using: &generator)
        components.queryItems = (0 ..< queryItemCount).map { (_) -> URLQueryItem in
            return URLQueryItem(name: randomString(), value: randomString())
        }

        return components
    }
}


public extension URLRequest {
    /// Returns a randomly generated URL request with the following properties:
    ///
    ///   - It has a random URL (see `URL.random(using:)`).
    ///   - It has an HTTP method of either "DELETE", "GET", "PATCH", "POST", or "PUT".
    ///   - Its HTTP body is random data (see `Data.random(count:using:)`).
    ///   - It may have a value for the Content-Type header field.
    ///
    /// - Parameter generator: The random number generator to use when creating the new random value.
    /// - Returns: A randomly generated URL request.
    static func random<RNG>(using generator: inout RNG) -> URLRequest where RNG : RandomNumberGenerator {
        func randomContentType() -> String? {
            switch Int.random(in: 0 ... 4, using: &generator) {
            case 0:
                return nil
            case 1:
                return String.randomAlphanumeric(count: 8, using: &generator)
            case 2:
                return "text/plain"
            case 3:
                return "application/json; charset=utf8"
            default:
                let prefix = String.randomAlphanumeric(count: 4, using: &generator)
                let suffix = String.randomAlphanumeric(count: 4, using: &generator)
                return "\(prefix); \(suffix)"
            }
        }


        var request = URLRequest(url: URL.random(using: &generator))

        request.httpMethod = ["DELETE", "GET", "PATCH", "POST", "PUT"].randomElement(using: &generator)!
        let httpBodyByteCount = Int.random(in: 1 ... 128, using: &generator)
        request.httpBody = Data.random(count: httpBodyByteCount, using: &generator)

        if let contentType = randomContentType() {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
