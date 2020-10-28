//
//  HashableByIdentifier.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 1/7/2020.
//  Copyright © 2020 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `HashableByIdentifier` provides a default implementation of `Hashable` for reference types and types that conform to
/// `Identifiable`. Two objects are considered equal only if their identifiers are equal. Their hashes depend only on
/// their identifiers.
public protocol HashableByIdentifier : Hashable {
    associatedtype Identifier : Hashable

    var identifier: Identifier { get }
}


public extension HashableByIdentifier where Self : AnyObject {
    var identifier: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}


@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension HashableByIdentifier where Self : Identifiable {
    var identifier: ID {
        return id
    }
}


public extension HashableByIdentifier {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }


    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
