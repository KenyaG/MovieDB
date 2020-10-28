//
//  HTTPRequestAuthenticator.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 3/25/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `HTTPRequestAuthenticator`s perform authentication on behalf of `AuthenticatingHTTPClient`s.
public protocol HTTPRequestAuthenticator {
    /// An associated type that provides context for the authenticator to decide how to authenticate a given request.
    /// When authenticating HTTP requests are made, users of `AuthenticatingHTTPClient` pass an object of this type
    /// to the HTTP client, which then passes it to the authenticator. Since the type is simply passed through to the
    /// authenticator, it can be any type that makes sense to the authenticator. No other part of the system interacts
    /// with it.
    associatedtype Context

    /// Prepares `request` with appropriate authentication information so that it can be loaded.
    ///
    /// Typical implementations will obtain credentials, e.g., from memory, the Keychain, or the user; update the
    /// request with credential information; and invoke the completion handler with the prepared request. If the request
    /// can be prepared, `completion` should be invoked with a disposition of `.proceed`, passing the prepared request.
    /// If a failure occurs during preparation, the request should be aborted by invoking `completion` with the `.abort`
    /// disposition. Finally, if the user chooses to cancel the request, the completion handler should be invoked with
    /// `.cancel`.
    ///
    /// This method is executed on an arbitrary queue before a request is loaded by an authenticating HTTP client. If
    /// aspects of request preparation, e.g., asking the user for credentials, must be done on a particular queue, it is
    /// the authenticator’s responsibility to switch to that queue.
    ///
    /// - Parameters:
    ///   - request: The request that should be prepared with authentication information.
    ///   - context: The authentication context for the request. Authenticators should use this context to decide what
    ///     sort of preparation, if any, is needed to proceed with the request.
    ///   - failedRequest: If this request has been attempted before, this is the request that failed, i.e., the
    ///     prepared request from the previous invocation of `prepare(_:with:failedRequest:completion:)`. Authenticators
    ///     can examine this request when deciding how to prepare the request.
    ///   - completion: A closure to invoke when request preparation is complete. The parameter should be `.proceed` if
    ///     request loading should continue, `.abort` if preparation failed due to an error, and `.cancel` if the client
    ///     should cancel loading the request despite no error occurring.
    func prepare(_ request: URLRequest,
                 with context: Context,
                 failedRequest: URLRequest?,
                 completion: @escaping (AuthenticatedRequestDisposition) -> Void)

    /// Returns whether `response` indicates an authentication failure for the specified `request`.
    ///
    /// This method is executed on an arbitrary queue after a response is received from a request but before the
    /// response is passed to the request’s response handler.
    ///
    /// - Parameters:
    ///   - request: The request that needs to be prepared.
    ///   - context: The authentication context for the request. Authenticators should use this context to decide what
    ///     sort of preparations, if any, are needed to load with the request.
    /// - Returns: The prepared request.
    func isAuthenticationFailure(response: Result<HTTPResponse<Data>, Error>, request: URLRequest, context: Context) -> Bool
}


/// `AuthenticatedRequestDisposition` indicates how an authenticated request should proceed after preparation.
public enum AuthenticatedRequestDisposition {
    /// Indicates that the specified prepared request should proceed loading.
    case proceed(URLRequest)

    /// Indicates that loading should be aborted because the specified error occurred during prepration.
    case abort(Error)

    /// Indicates that the request should be canceled. This differs from the `abort` disposition in that cancellation
    /// is not due to an error. For example, a user may intentionally cancel a request because they don’t remember their
    /// user credentials.
    case cancel
}
