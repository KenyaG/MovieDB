//
//  HTTPURLSession.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 2/2/2020.
//  Copyright © 2020 Grubhub, Inc. All rights reserved.
//

import Foundation


/// Objects conforming to the `ResumableTask` protocol can be resumed. `HTTPURLSession` uses `ResumableTask` to represent
/// the tasks that it loads.
public protocol ResumableTask {
    /// Resumes the task.
    func resume()
}

extension URLSessionTask : ResumableTask { }


/// Objects conforming to `HTTPURLSession` are used by `HTTPClient`s to create tasks that load URL requests.
public protocol HTTPURLSession : AnyObject {
    /// The type of task the session uses to perform its work.
    associatedtype DataTask : ResumableTask

    /// Creates and returns a new task that, upon resumption, loads `request` and invokes `completionHandler` upon
    /// completion. Upon return from this method, the returned task must not be started.
    ///
    /// - Parameters:
    ///   - request: The request that the task will load.
    ///   - completionHandler: The completion handler invoked upon completion of the load. Its three optional parameters
    ///     are the data associated with the load, the URLResponse, and the error that occurred during the load.
    /// - Returns: A task that loads the request.
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> DataTask
}

extension URLSession : HTTPURLSession { }
