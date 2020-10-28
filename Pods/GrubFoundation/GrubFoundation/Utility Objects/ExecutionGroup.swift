//
//  ExecutionGroup.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 1/7/2020.
//  Copyright © 2020 Grubhub, Inc. All rights reserved.
//

import Foundation


/// The `ExecutionGroupDelegate` protocol defines an interface via which a `ExecutionGroup` can communicate about
/// execution state with its delegate.
public protocol ExecutionGroupDelegate : AnyObject {
    /// Indicates that the execution group is about to begin execution. This method is invoked whenever
    /// `addWorkItem(_:)` is invoked on the group and it has no currently executing work items.
    ///
    /// - Parameters:
    ///   - executionGroup: The execution group.
    ///   - completion: A completion handler that should be invoked when the delegate is ready for the execution group
    ///     to begin execution.
    func executionGroupWillBeginExecuting(_ executionGroup: ExecutionGroup, completion: @escaping () -> Void)

    /// Indicates that the execution group has ended execution. This method is invoked immediately after an execution
    /// group’s last work item stops executing.
    ///
    /// - Parameters:
    ///   - executionGroup: The execution group.
    ///   - completion: A completion handler that should be invoked when the delegate is ready for the execution group
    ///     to begin executing its `didEndExecutionHandlers`.
    func executionGroupDidEndExecuting(_ executionGroup: ExecutionGroup, completion: @escaping () -> Void)
}


/// `ExecutionGroup`s execute work items on a queue and notify their delegates when execution begins and ends. They are
/// analagous to `DispatchGroup`s, but use a different mechanism to control execution using delegation.
///
/// `ExecutionGroup`s make it easy to monitor a group of related tasks for a particular purpose. For example, a view
/// controller can use an exection group to track work that is being done that should show a loading indicator. When
/// work should start, it can just be added to the execution group. The view controller can implement delegate protocols
/// to show the loading indicator when execution begins and hide it when execution ends.
public final class ExecutionGroup {
    /// `ExecutionGroup.Handle` provides a mechanism for a work item to signal its completion to its execution group.
    public final class Handle : HashableByIdentifier {
        /// The instance’s execution group.
        private(set) weak var executionGroup: ExecutionGroup?


        /// Creates a new `Handle` for the specified exection group.
        ///
        /// - Parameter executionGroup: The execution group to which the handle will communicate completion.
        fileprivate init(executionGroup: ExecutionGroup) {
            self.executionGroup = executionGroup
        }


        /// Indicates that the work item is complete. Invoke this in your work item’s closure when you have completed
        /// your work.
        public func complete() {
            executionGroup?.complete(self)
        }
    }


    /// The queue on which the instance’s work items execute.
    public let queue: DispatchQueue

    /// The instance’s delegate. While not strictly necessary, execution groups provide little benefit over
    /// `DispatchQueue`s or `DispatchGroup`s when they have no delegate.
    public weak var delegate: ExecutionGroupDelegate?

    /// A concurrent accessor to the current set of `Handle`s that represent executing work items.
    private var handleAccessor: ConcurrentAccessor<Set<Handle>> = ConcurrentAccessor([])

    /// A concurrent accessor to an array of handlers that should be invoked the next time the group ends execution.
    private var didEndExecutionHandlerAccessor: ConcurrentAccessor<[() -> Void]> = ConcurrentAccessor([])


    /// Creates a new `ExecutionGroup` with the specified queue and delegate.
    ///
    /// - Parameters:
    ///   - queue: The queue that the execution group’s work items should be executed on. This queue should almost
    ///     always be concurrent. If unspecified, the `.global()` concurrent queue is used.
    ///   - delegate: The instance’s delegate. `nil` by default, though you should generally set a delegate before
    ///     executing any work items.
    public init(queue: DispatchQueue = .global(), delegate: ExecutionGroupDelegate? = nil) {
        self.queue = queue
        self.delegate = delegate
    }


    /// Whether any works items are being executed by the instance.
    public var isExecuting: Bool {
        return handleAccessor.read { !$0.isEmpty }
    }


    /// Adds a work item to the instance for execution.
    ///
    /// If the delegate is non-`nil` or the instance has at least one work item currently executing, `body` will be
    /// executed immediately. Otherwise, `executionGroupExecutionDidEnd(_:completion:)` will be invoked on the
    /// delegate, and execution will only begin once the delegate invokes the supplied completion handler.
    ///
    /// - Parameter body: The body of the work item to execute. When the work item is complete, you must invoke
    ///   `complete()` on the closure’s `Handle`.
    public func addWorkItem(_ body: @escaping (Handle) -> Void) {
        let handle = Handle(executionGroup: self)
        func executeBody() {
            queue.async {
                body(handle)
            }
        }

        var shouldStartExecution = false
        handleAccessor.syncWrite { (handles) in
            shouldStartExecution = handles.isEmpty
            handles.insert(handle)
        }

        if shouldStartExecution, let delegate = delegate {
            delegate.executionGroupWillBeginExecuting(self, completion: executeBody)
        } else {
            executeBody()
        }
    }


    /// Adds a closure that should be executed the next time execution ends.
    ///
    /// - Parameter handler: The closure that should be executed.
    public func addDidEndExecutingHandler(_ handler: @escaping () -> Void) {
        didEndExecutionHandlerAccessor.asyncWrite { (didEndExecutionHandlers) in
            didEndExecutionHandlers.append(handler)
        }
    }


    /// Removes the specified handle from the instance’s list of currently executing handles.
    ///
    /// If after removing the handle there are no currently executing handlers, this method will invoke
    /// `executionGroupDidEndExecution(_:completion:)` on the delegate and invoke its `didEndExecutionHandlers` once the
    /// supplied completion handler is invoked. If the instance has a `nil` delegate, the handlers are invoked
    /// immediately.
    ///
    /// - Parameter handle: The handle.
    private func complete(_ handle: Handle) {
        var shouldEndExecution = false
        handleAccessor.syncWrite { (handles) in
            handles.remove(handle)
            shouldEndExecution = handles.isEmpty
        }

        guard shouldEndExecution else {
            return
        }

        var handlers: [() -> Void] = []
        didEndExecutionHandlerAccessor.syncWrite { (didEndExecutionHandlers) in
            handlers = didEndExecutionHandlers
            didEndExecutionHandlers.removeAll()
        }


        if let delegate = delegate {
            delegate.executionGroupDidEndExecuting(self) {
                for handler in handlers {
                    handler()
                }
            }
        } else {
            for handler in handlers {
                handler()
            }
        }
    }
}
