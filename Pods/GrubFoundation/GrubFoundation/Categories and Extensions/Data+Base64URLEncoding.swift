//
//  Data+Base64URLEncoding.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 1/14/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension Data {
    /// Creates and returns a new `Data` instance with the given Base64URL encoded data.
    ///
    /// See [RFC 4648, section 5](https://tools.ietf.org/html/rfc4648#section-5) for details.
    ///
    /// - Parameter base64URLEncoded: A Base64URL encoded string representation of the data.
    init?(base64URLEncoded: String) {
        var base64Encoded = String(base64URLEncoded.map { (character) in
            switch character {
            case "_":
                return "/"
            case "-":
                return "+"
            default:
                return character
            }
        })

        // One Base64 character is 6-bits of data. This means that in order to hit a byte boundary, we need some
        // multiple of 4 characters (1 character = 6 bits, 2 characters = 12 bits, 3 characters = 18 bits, and 4
        // characters = 24 bits or 3 bytes). If we’re not on a byte boundary, we add "=" characters until we are
        let charactersUntilByteBoundary = base64Encoded.count % 4
        if charactersUntilByteBoundary > 0 {
            let paddingLength = 4 - charactersUntilByteBoundary
            base64Encoded.append(String(repeating: "=", count: paddingLength))
        }

        self.init(base64Encoded: base64Encoded)
    }


    /// Returns a Base64URL encoded string representation of the instance.
    ///
    /// Base64URL is just Base64, but uses "_" instead of "/" and "-" instead of "+", as those characters aren’t
    /// URL-safe. It also does not include any padding characters ("=").
    ///
    /// See [RFC 4648, section 5](https://tools.ietf.org/html/rfc4648#section-5) for details.
    ///
    /// - Returns: The Base64URL encoded representation.
    var base64URLEncodedString: String {
        return String(base64EncodedString().compactMap { (character) in
            switch character {
            case "/":
                return "_"
            case "+":
                return "-"
            case "=":
                return nil
            default:
                return character
            }
        })
    }
}
