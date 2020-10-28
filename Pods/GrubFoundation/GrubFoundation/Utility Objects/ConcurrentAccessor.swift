//
//  ConcurrentAccessor.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 2/19/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `ConcurrentAccessor` instances provide a convenient mechanism for safely accessing an object from multiple
/// threads with maxmimal throughput. They are appropriate to use whenever an object can be safely read from multiple
/// threads simultaneously, but should only be written to from one thread at a time, and even then only when no reads
/// are occurring. This multiple-reader, single-writer policy is implemented internally using Dispatch Barriers.
///
/// To manage a dictionary that needs to be updated from multiple threads, you can create a concurrent accessor as
/// follows:
///
///     let accessor = ConcurrentAccessor<[String : Any]>([:]);
///
/// After this, you need not store the underlying dictionary. The concurrent accessor stores it and provides a mechanism
/// to read from it and write to it. To perform reads, you can use the `read(_:)` method.
///
///     let (count, name) = accessor.read { dictionary in
///         return (dictionary.count, dictionary["name"] as? String)
///     }
///
/// Reads are inherently synchronous, and you can safely read from several threads at once. Writes, on the other hand,
/// are inherently asynchronous, and the implementation of `ConcurrentAccessor` prevents a write from occurring at
/// the same time as another read or write.
///
///     if let updatedName = name?.appending(" updated") {
///         accessor.asyncWrite { $0["name"] = updatedName }
///     }
///
/// If you want to wait for a write to complete before moving on to subsequent lines, you can do so using
/// `syncWrite(_:)`.
public class ConcurrentAccessor<BaseType> : CustomStringConvertible {
    /// The object being accessed concurrently.
    private var base: BaseType

    /// The dispatch queue used to concurrently access `base`.
    private let queue: DispatchQueue


    /// Initializes an instance that controls concurrent access to `base`.
    ///
    /// - Parameter base: The object that the instance will control access to.
    public init(_ base: BaseType) {
        self.base = base
        self.queue = DispatchQueue(label: "\(type(of: self))", attributes: .concurrent)
    }


    public var description: String {
        let baseDescription = read { "\($0)" }
        return "<\(type(of: self)): queue=\(queue) base=\(baseDescription)>"
    }


    /// Safely and synchronously executes `body` while preventing write operations from executing concurrently.
    ///
    /// This method can be used to safely and efficiently read data from the instance’s `base`. To maintain object
    /// consistency, `base` should not be mutated inside `body`. For example, if the instance’s object is a mutable
    /// reference type, its properties can be retrieved inside the closure, but they should not be set.
    ///
    /// - Parameter body: The closure to execute to perform one or more read operations on `base`, which is passed to
    ///   the closure as a parameter.
    /// - Returns: The return value of `body`, which is presumably the value or values that were read. To return
    ///   multiple values, use a tuple.
    public func read<ReturnType>(_ body: (BaseType) -> ReturnType) -> ReturnType {
        var returnValue: ReturnType?
        queue.sync {
            returnValue = body(base)
        }

        // returnValue is guaranteed to be non-nil here, as the queue.sync call must be complete. If body returns Void,
        // the return value will be an empty tuple.
        return returnValue!
    }


    /// Safely and asynchronously executes `body` while preventing any other read or write operations from executing
    /// concurrently. For synchronous writes, use `syncWrite(_:)`.
    ///
    /// - Note: Because write operations block access to `base`, care should be taken to do as little in `body` as
    ///   possible. For example, if an object needs to be stored in a shared array, the object should already be
    ///   constructed outside the closure and simply added to the array in `body`.
    ///
    /// - Parameter body: The closure to execute to perform one or more write operations on `base`, which is passed to
    ///   the closure as an `inout` parameter.
    public func asyncWrite(_ body: @escaping (inout BaseType) -> Void) {
        queue.async(flags: .barrier) {
            body(&self.base)
        }
    }


    /// Safely and synchronously executes `body` while preventing any other read or write operations from executing
    /// concurrently. For asynchronous writes, use `asyncWrite(_:)`.
    ///
    /// - Note: Because write operations block access to `base`, care should be taken to do as little in `body` as
    ///   possible. For example, if an object needs to be stored in a shared array, the object should already be
    ///   constructed outside the closure and simply added to the array in `body`.
    ///
    /// - Parameter body: The closure to execute to perform one or more write operations on `base`, which is passed to
    ///   the closure as an `inout` parameter.
    public func syncWrite(_ body: (inout BaseType) -> Void) {
        queue.sync(flags: .barrier) {
            body(&self.base)
        }
    }
}
