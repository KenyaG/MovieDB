//
//  WebServiceClient.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 9/18/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation


/// Together with `WebServiceRequest` and `BaseURLConfiguring`, `WebServiceClient` provides a declarative
/// interface for executing structured web service requests and handling their responses.
///
/// The client itself is very simple: it provides a base URL configuration for web service requests and an
/// authenticating HTTP client with which to execute requests. The rest of the declarative interface is defined in
/// `WebServiceRequest` and `BaseURLConfiguring`. See the documentation of those protocols for information on
/// how to declare a request and how to configure a web service client’s base URLs.
///
/// For convenience, we recommend that you create a typealias for your specific web service client type. For example,
///
///     typealias MyWebServiceClient = WebServiceClient<
///         AuthenticatingHTTPClient<URLSession, MyAuthenticator>,
///         SingleBaseURLConfiguration
///     >
///
/// You can then create an extension for your specific web service client type to more easily initialize it. For
/// example,
///
///     extension MyWebServiceClient {
///         convenience init(authenticator: MyAuthenticator, baseURL: URL) {
///             self.init(
///                 authenticatingHTTPClient: AuthenticatingHTTPClient(
///                     urlSession: .shared,
///                     authenticator: authenticator
///                 ),
///                 baseURLConfiguration: SingleBaseURLConfiguration(url: url)
///             )
///         }
///     }
public final class WebServiceClient<AuthenticatingHTTPClient, BaseURLConfiguration> where
AuthenticatingHTTPClient : AuthenticatingHTTPClientProtocol, BaseURLConfiguration : BaseURLConfiguring {
    /// The authenticating HTTP client that the instance uses to load its HTTP requests.
    public let authenticatingHTTPClient: AuthenticatingHTTPClient

    /// The base URL configuration for the instance. This object defines which base URLs the instance should use
    /// for its requests.
    public let baseURLConfiguration: BaseURLConfiguration


    /// Creates a new `WebServiceClient` with the specified authenticating HTTP client and base URL configuration.
    ///
    /// - Parameters:
    ///   - authenticatingHTTPClient: The authenticating HTTP client that the instance uses to load its HTTP requests.
    ///   - baseURLConfiguration: The base URL configuration for the instance.
    public init(authenticatingHTTPClient: AuthenticatingHTTPClient, baseURLConfiguration: BaseURLConfiguration) {
        self.authenticatingHTTPClient = authenticatingHTTPClient
        self.baseURLConfiguration = baseURLConfiguration
    }


    /// Loads the specified API request and invokes `completion` after the request’s response has been handled.
    ///
    /// This method simply invokes `loadData(for:authenticationContext:responseHandler:)` on the instance’s
    /// authenticating HTTP client. The URL request used is created by invoking `urlRequest(withBaseURL:)` on `request`
    /// with the URL for `request`’s `baseURL` in `baseURLConfiguration`. The authentication context is `request`’s
    /// `authenticationContext`. Finally, the response handler is `request`’s `responseHandler` chaining a call to
    /// `completion`.
    ///
    /// The response handler’s `handle(_:completion:)` method, all `HTTPRequestAuthenticator` methods, and
    /// `completion` are invoked on arbitrary queues. You are responsible for dispatching to a different queue inside
    /// your handler, authenticator implementations, and completion as needed.
    ///
    /// - Parameters:
    ///   - request: The web service client request to load.
    ///   - completion: The closure to execute once the load is complete.
    public func loadData<Request>(for request: Request, completion: @escaping (Result<Request.Success, Error>) -> Void)
        where Request : WebServiceRequest, Request.BaseURLConfiguration == BaseURLConfiguration,
        Request.Authenticator == AuthenticatingHTTPClient.Authenticator {
            let urlRequest = request.urlRequest(with: baseURLConfiguration)
            precondition(urlRequest != nil, "Could not create URL request for \(request)")

            let completionHandler = AdHocHandler<Request.Success, Request.Success> { (result, handlerCompletion) in
                completion(result)
                handlerCompletion(result)
            }

            let responseHandler = request.responseHandler.chaining(completionHandler)
            authenticatingHTTPClient.loadData(
                for: urlRequest!,
                authenticationContext: request.authenticationContext,
                responseHandler: responseHandler
            )
    }
}
