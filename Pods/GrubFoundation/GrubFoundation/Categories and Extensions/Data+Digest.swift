//
//  Data+Digest.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 1/15/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import CommonCrypto
import Foundation


public extension Data {
    /// Returns an MD5 digest of the instance.
    var md5Digest: Data {
        return CommonCryptoDigest.md5.digest(of: self)
    }

    /// Returns a SHA-1 digest of the instance.
    var sha1Digest: Data {
        return CommonCryptoDigest.sha1.digest(of: self)
    }

    /// Returns a SHA-224 digest of the instance.
    var sha224Digest: Data {
        return CommonCryptoDigest.sha224.digest(of: self)
    }

    /// Returns a SHA-256 digest of the instance.
    var sha256Digest: Data {
        return CommonCryptoDigest.sha256.digest(of: self)
    }

    /// Returns a SHA-384 digest of the instance.
    var sha384Digest: Data {
        return CommonCryptoDigest.sha384.digest(of: self)
    }

    /// Returns a SHA-512 digest of the instance.
    var sha512Digest: Data {
        return CommonCryptoDigest.sha512.digest(of: self)
    }
}


/// `CommonCryptoDigest`s compute message digests of `Data` instances.
private struct CommonCryptoDigest {
    /// The CommonCrypto digest function to use to compute the message digest.
    private let function: (UnsafeRawPointer?, CC_LONG, UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?

    /// The length of digests computed by the instance.
    private let length: Int


    /// Creates a new `CommonCryptoDigest` with the specified function and length.
    ///
    /// - Parameters:
    ///   - function: The CommonCrypto digest function to use to compute the message digest.
    ///   - length: The length of digests computed by the instance.
    private init(function: @escaping (UnsafeRawPointer?, CC_LONG, UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?, length: Int32) {
        self.function = function
        self.length = Int(length)
    }


    /// The MD5 digest.
    static let md5 = CommonCryptoDigest(function: CC_MD5, length: CC_MD5_DIGEST_LENGTH)

    /// The SHA-1 digest.
    static let sha1 = CommonCryptoDigest(function: CC_SHA1, length: CC_SHA1_DIGEST_LENGTH)

    /// The SHA-224 digest.
    static let sha224 = CommonCryptoDigest(function: CC_SHA224, length: CC_SHA224_DIGEST_LENGTH)

    /// The SHA-256 digest.
    static let sha256 = CommonCryptoDigest(function: CC_SHA256, length: CC_SHA256_DIGEST_LENGTH)

    /// The SHA-384 digest.
    static let sha384 = CommonCryptoDigest(function: CC_SHA384, length: CC_SHA384_DIGEST_LENGTH)

    /// The SHA-512 digest.
    static let sha512 = CommonCryptoDigest(function: CC_SHA512, length: CC_SHA512_DIGEST_LENGTH)


    /// Computes and returns the message digest for the specified data.
    ///
    /// - Parameter data: The data for which to return a digest.
    func digest(of data: Data) -> Data {
        let digestBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: length)

        data.withUnsafeBytes { (rawBufferPointer) -> Void in
            _ = function(rawBufferPointer.baseAddress, UInt32(rawBufferPointer.count), digestBuffer)
        }

        return Data(bytesNoCopy: digestBuffer, count: length, deallocator: .custom { (pointer, _) in
            pointer.deallocate()
        })
    }
}
