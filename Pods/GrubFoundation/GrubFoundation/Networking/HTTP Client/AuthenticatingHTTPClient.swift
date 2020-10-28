//
//  AuthenticatingHTTPClient.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 2/2/2020.
//  Copyright © 2020 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `AuthenticatingHTTPClientProtocol` defines the interface for authenticating HTTP clients.
public protocol AuthenticatingHTTPClientProtocol : HTTPClientProtocol {
    /// The type of `HTTPRequestAuthenticator` that the instance uses to authenticate requests.
    associatedtype Authenticator : HTTPRequestAuthenticator

    /// The authenticator that the client uses to authenticate its requests.
    var authenticator: Authenticator { get }


    /// Loads `request` and handles its response with `responseHandler`.
    ///
    /// Before loading the request, the instance asks the authenticator to prepare the request with authentication
    /// information and waits for the authenticator to tell it how to proceed. If the client is told to abort with an
    /// error, it sends the error to the response handler. If it’s told to cancel, it sends a cancel error to the
    /// response handler. Cancel errors are have a domain of `NSURLErrorDomain` and a code of `NSURLErrorCancelled`.
    ///
    /// If the authenticator indicates that request loading should proceed, the authenticating HTTP client loads the
    /// prepared request. Upon receiving a response, the HTTP client asks the authenticator if the response indicates an
    /// authentication failure. If not, the response is passed to the handler. Otherwise, the entire process repeats
    /// until authentication succeeds and the response is handled or the authenticator tells the client to cancel the
    /// request.
    ///
    /// The response handler’s `handle(_:completion:)` method and all `HTTPRequestAuthenticator` methods are invoked
    /// on arbitrary queues. You are responsible for dispatching to a different queue inside your handler and
    /// authenticator implementations as needed.
    ///
    /// - Parameters:
    ///   - request: The request to load. The request must be an HTTP or HTTPS request.
    ///   - authenticationContext: Contextual information that the authenticator can use to determine how to
    ///     authenticate the request.
    ///   - responseHandler: The object that handles the load request’s response.
    func loadData<ResponseHandler>(for request: URLRequest, authenticationContext: Authenticator.Context, responseHandler: ResponseHandler)
        where ResponseHandler : Handler, ResponseHandler.Input == HTTPResponse<Data>
}


/// `AuthenticatingHTTPClient` is a `HTTPClient` subclass that adds support for executing requests that require
/// authentication. Each authenticating HTTP client has an associated authenticator that cooperates with the client to
/// add authentication information to requests and evaluate whether an HTTP response indicates an authentication
/// failure.
///
/// Otherwise, authenticating HTTP clients provide identical functionality as its superclass. In fact,
/// `AuthenticatingHTTPClient` only adds one method to the HTTPClient interface. Like their non-authenticating
/// counterparts, authenticating HTTP clients can be freely created and destroyed and are intended to be used as
/// non-singletons.
public class AuthenticatingHTTPClient<Session, Authenticator> : HTTPClient<Session>, AuthenticatingHTTPClientProtocol
where Session : HTTPURLSession, Authenticator : HTTPRequestAuthenticator {
    /// The HTTP client’s authenticator
    public let authenticator: Authenticator

    /// The queue on which the instance executes its tasks
    public let queue: OperationQueue


    /// Initializes a new HTTP client with the specified URL session, authenticator, and operation queue. If `queue` is
    /// `nil`, an operation queue is created for use by this client.
    ///
    /// - Parameters:
    ///   - urlSession: The client’s URL session.
    ///   - authenticator: The authenticator that the instance uses to authenticate requests.
    ///   - queue: The operation queue on which this instance runs its tasks.
    public init(urlSession: Session, authenticator: Authenticator, queue: OperationQueue? = nil) {
        self.authenticator = authenticator

        if let queue = queue {
            self.queue = queue
        } else {
            let queue = OperationQueue()
            queue.name = "com.grubhub.GrubFoundation.AuthenticatingHTTPClient"
            self.queue = queue
        }

        super.init(urlSession: urlSession)
    }


    public func loadData<ResponseHandler>(for request: URLRequest, authenticationContext: Authenticator.Context, responseHandler: ResponseHandler)
        where ResponseHandler : Handler, ResponseHandler.Input == HTTPResponse<Data> {
            let task = AuthenticatingRequestTask(
                httpClient: self,
                request: request,
                context: authenticationContext,
                responseHandler: responseHandler
            )

            task.load()
    }


    // MARK: -

    /// `AuthenticatingRequestTask` is a private class that handles the flow of loading an authenticated request.
    private final class AuthenticatingRequestTask<ResponseHandler>
    where ResponseHandler : Handler, ResponseHandler.Input == HTTPResponse<Data> {
        /// The HTTP client that the task is associated with. This client is used to actually load the request.
        /// It can safely be unowned because the task handle that wraps it holds a strong reference for the
        /// duration of its execution, and it
        private let httpClient: AuthenticatingHTTPClient<Session, Authenticator>

        /// The request to load.
        private let request: URLRequest

        /// The authenticator context for the request.
        private let context: Authenticator.Context

        /// The request’s response handler.
        private let responseHandler: ResponseHandler

        private var strongSelf: AuthenticatingRequestTask?


        /// Initializes a new authenticating request task with the specified parameters.
        ///
        /// - Parameters:
        ///   - httpClient: The HTTP client that the instance is associated with.
        ///   - request: The request to load.
        ///   - context: The authenticator context for the request.
        ///   - responseHandler: The request’s response handler.
        init(httpClient: AuthenticatingHTTPClient<Session, Authenticator>,
             request: URLRequest,
             context: Authenticator.Context,
             responseHandler: ResponseHandler) {
            self.httpClient = httpClient
            self.request = request
            self.context = context
            self.responseHandler = responseHandler
        }


        /// Loads the authenticating request.
        func load() {
            strongSelf = self

            httpClient.queue.addOperation {
                self.prepareRequest()
            }
        }


        /// Asks the authenticator to prepare the request. If the authenticator tells the instance to abort, finishes
        /// with an error. If the authenticator tells the instance cancel or the instance is canceled while the request
        /// is being prepared, finishes with a cancellation error.
        ///
        /// - Parameter failedRequest: The previously prepared request that failed. `nil` if this is the first time
        ///   the request is being loaded.
        private func prepareRequest(failedRequest: URLRequest? = nil) {
            httpClient.authenticator.prepare(request, with: context, failedRequest: failedRequest) { (disposition) in
                switch disposition {
                case let .proceed(preparedRequest):
                    self.loadRequest(preparedRequest, failedRequest: failedRequest)
                case let .abort(error):
                    self.finish(with: .failure(error))
                case .cancel:
                    self.finish(with: .failure(NSError.cancellationError))
                }
            }
        }


        /// Loads the data task. If the data task’s response is an authentication failure, attempts to prepare the
        /// request again. Otherwise, sends the response to the handler.
        ///
        /// - Parameters:
        ///   - preparedRequest: The request to load. It was prepared by the authenticator.
        ///   - failedRequest: The previously prepared request that failed. `nil` if this is the first time the request
        ///     is being loaded.
        private func loadRequest(_ preparedRequest: URLRequest, failedRequest: URLRequest?) {
            httpClient.loadData(for: preparedRequest) { (response) in
                let isAuthenticationFailure = self.httpClient.authenticator.isAuthenticationFailure(
                    response: response,
                    request: self.request,
                    context: self.context
                )

                if isAuthenticationFailure {
                    self.prepareRequest(failedRequest: preparedRequest)
                } else {
                    self.finish(with: response)
                }
            }
        }


        /// Invokes the response handler with the specified result and then invokes `finish()` on the task handle
        /// when response handling is complete.
        ///
        /// - Parameter result: The result to pass to the response handler.
        private func finish(with result: Result<HTTPResponse<Data>, Error>) {
            responseHandler.handle(result) { (_) in }
            strongSelf = nil
        }
    }
}


private extension NSError {
    /// The standard cancellation error when you cancel a URL request.
    static var cancellationError: NSError {
        return NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
    }
}
