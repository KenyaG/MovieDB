//
//  PermissiveDecodableArray.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 2/4/2018.
//  Copyright © 2018 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `ArrayDecodingPolicy` enumerates the policies that can be used when decoding an array. Specifically, it expresses
/// two policies: strict and permissive. Strict array decoding is the standard form of decoding implemented by the Swift
/// standard library: if a single element of an array cannot be decoded, decoding the entire array will fail. Permissive
/// decoding is implemented by `PermissiveDecodableArray` and allows decoding to proceed despite decoding failures on
/// individual elements.
///
/// - Note: GrubFoundation makes no use of `ArrayDecodingPolicy`. It is provided so that all frameworks that use
///   GrubFoundation can express their array decoding policies uniformly.
public enum ArrayDecodingPolicy {
    /// Indicates a strict array decoding policy, i.e., if decoding a single element fails, decoding the array fails.
    case strict

    /// Indicates a permissive array decoding policy, i.e., if decoding a single element fails, decoding the array can
    /// can still continue.
    case permissive
}


/// `PermissiveDecodableArray` provides a mechanism to permissively decode arrays of elements. The Swift standard
/// library implements a strict array decoding policy in which array decoding fails if any element of the array cannot
/// be decoded. Permissive decodable arrays allow decoding to continue when individual element decoding fails. It
/// provides access to both the elements that were successfully decoded and the errors that occurred during decoding.
public struct PermissiveDecodableArray<Element> : Decodable where Element : Decodable {
    /// The elements that could be decoded successfully.
    public let elements: [Element]

    /// The errors that occurred while decoding elements.
    public let decodingErrors: [Error]


    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodedElements = try container.decode([DecodedElement<Element>].self)

        self.elements = decodedElements.compactMap { $0.result.value }
        self.decodingErrors = decodedElements.compactMap { $0.result.error }
    }


    /// `DecodedElement` is a private type that decodes into a `Result<Element, Error>`. It is used by
    /// `PermissiveDecodableArray` to decode individual elements while containing individual element failures.
    private struct DecodedElement<Element> :  Decodable where Element : Decodable {
        /// The result of decoding.
        let result: Result<Element, Error>


        init(from decoder: Decoder) throws {
            do {
                let container = try decoder.singleValueContainer()
                self.result = .success(try container.decode(Element.self))
            } catch {
                self.result = .failure(error)
            }
        }
    }
}
