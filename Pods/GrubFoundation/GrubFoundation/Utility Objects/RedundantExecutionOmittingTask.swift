//
//  RedundantExecutionOmittingTask.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 10/19/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `RedundantExecutionOmittingTask`s only run once at any given time, no matter how many runs are simultaneously
/// requested. They make it very easy to accumulate a set of waiting completion handlers while some work executes and
/// invoke them once the work is complete.
///
/// A task’s work is expressed by its `body` closure, which takes an `ExecutionHandle` as a parameter. This handle is
/// used to signal that the work has completed with a specific result.
///
/// You can trigger that the task’s body be run using `runIfNeeded(completion:)`. If the task isn’t already running,
/// invoking this method will start it. Regardless of whether a new run was started or it was already running, the
/// completion handler will be invoked when the run finishes. After that, another run can be started by invoking
/// `runIfNeeded(completion:)` again.
///
/// In the example below, `StatusFetcher` only fetches status once at any given time. While status is being fetched,
/// completion handlers are accumulated and only invoked once the fetch is complete.
///
///     public final class StatusFetcher {
///         …
///
///         // Our task
///         private lazy var fetchStatusTask: RedundantExecutionOmittingTask<Result<Status, Error>> = {
///             return RedundantExecutionOmittingTask { [weak self] (handle) in
///                 self?.fetchStatus(completion: handle.complete(with:))
///             };
///         }()
///
///
///         private func fetchStatus(completion: @escaping (Result<Status, Error>) -> Void) {
///             // Unconditionally fetch status
///         }
///
///
///         public func fetchStatusIfNeeded(completion: @escaping (Result<Status, Error>) -> Void) {
///             guard isFetchStatusNeeded else {
///                 …
///             }
///             
///             fetchStatusTask.runIfNeeded(completion: completion)
///         }
///     }
public final class RedundantExecutionOmittingTask<TaskResult> {
    /// `ExecutionHandle`s provide a way for a task’s body to mark that its execution is complete.
    public final class ExecutionHandle {
        /// The task being executed.
        private let task: RedundantExecutionOmittingTask

        /// Whether the handle has already been marked as complete. This prevents the same handle from being completed
        /// multiple times.
        private var didComplete = false


        /// Creates a new `ExecutionHandle` for the specified task.
        ///
        /// - Parameter task: The task being executed.
        init(task: RedundantExecutionOmittingTask) {
            self.task = task
        }


        /// Marks a task’s execution as complete.
        ///
        /// - Parameter result: The result with which the execution finished.
        public func complete(with result: TaskResult) {
            guard !didComplete else {
                return
            }

            didComplete = true
            task.complete(with: result)
        }
    }


    /// The closure to execute whenever the task is run. When execution is complete, it must invoke `complete(with:)`
    /// on its `ExecutionHandle` parameter.
    private let body: (ExecutionHandle) -> Void

    /// A concurrent accessor for the array of currently waiting completion handlers.
    private var waitingCompletionHandlersAccessor = ConcurrentAccessor<[(TaskResult) -> Void]>([])


    /// Creates a new `RedundantExecutionOmittingTask` with the specified body.
    ///
    /// - Parameters:
    ///   - body: The closure to execute whenever the task is run. When execution is complete, it must invoke
    ///     `complete(with:)` on its `ExecutionHandle` parameter.
    public init(body: @escaping (ExecutionHandle) -> Void) {
        self.body = body
    }


    /// Starts the task if it isn’t already running and invokes `completion` once the task finishes. If the task was
    /// already running when this method is invoked, `completion` is recorded and invoked once the task finishes.
    /// Completion handlers are invoked in the order they are received.
    ///
    /// - Parameter completion: The closure to invoke when the task completes. This closure is invoked on an arbitrary
    ///   queue.
    public func runIfNeeded(completion: @escaping (TaskResult) -> Void) {
        // A run is needed only if no other completion handlers are waiting, which makes us the first
        var isRunNeeded = false

        waitingCompletionHandlersAccessor.syncWrite { (waitingCompletionHandlers) in
            isRunNeeded = waitingCompletionHandlers.isEmpty
            waitingCompletionHandlers.append(completion)
        }

        if isRunNeeded {
            body(ExecutionHandle(task: self))
        }
    }


    /// Invokes and clears the list of completion handlers that were waiting on the current run to complete.
    ///
    /// - Parameter result: The result with which the run completed.
    private func complete(with result: TaskResult) {
        // Get the set of waiting completion handlers and then clear them out
        var completionHandlers: [(TaskResult) -> Void] = []
        waitingCompletionHandlersAccessor.syncWrite { (waitingCompletionHandlers) in
            completionHandlers = waitingCompletionHandlers
            waitingCompletionHandlers.removeAll()
        }

        // Invoke all the completion handlers that were waiting
        for completionHandler in completionHandlers {
            completionHandler(result)
        }
    }
}
