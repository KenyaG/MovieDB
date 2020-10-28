//
//  WebServiceRequest.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 2/2/2020.
//  Copyright © 2020 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `WebServiceRequest` declares a protocol by which the various components of a web service request can be declared.
/// Its primary goal is to make creating URL requests for HTTP-based APIs declarative instead of imperative, thus vastly
/// improving the readability and testability of web service client request code and centralizing logic for URL request
/// creation in the GrubFoundation framework.
///
/// Each `WebServiceRequest` declares the following properties:
///
///   - Its HTTP method.
///   - An optional array of HTTP header items, which is `nil` by default.
///   - Its authentication context.
///   - Its base URL. A default value is given if the request’s `BaseURLConfiguring` is `SingleBaseURLConfiguration`.
///   - Its path components relative to the base URL.
///   - An optional URL fragment, which is `nil` by default.
///   - An optional array of URL query items, which is `nil` by default.
///   - An optional HTTP body, which is `nil` by default.
///   - Its response handler.
///
/// Objects with a JSON HTTP body can be futher simplified by conforming to `WebServiceJSONBodyRequest`.
public protocol WebServiceRequest {
    /// The type of authenticator that can authenticate requests of this type.
    associatedtype Authenticator : HTTPRequestAuthenticator

    /// The type of base URL that can be used for requests of this type.
    associatedtype BaseURLConfiguration : BaseURLConfiguring

    /// The type of result this request’s response handler produces.
    associatedtype Success

    /// The HTTP method for the request.
    var httpMethod: HTTPMethod { get }

    /// The HTTP header items for the request. Defaults to `nil`. If this array contains a Content-Type HTTP header
    /// item and the instance also has non-`nil` `httpBody`, the `httpBody`’s Content-Type is used. There is almost
    /// never a good reason for this method to have a Content-Type header item.
    var httpHeaderItems: [HTTPHeaderItem]? { get }

    /// The authentication context for the request.
    var authenticationContext: Authenticator.Context { get }

    /// The base URL for the request.
    var baseURL: BaseURLConfiguration.BaseURL { get }

    /// The path components of the request relative to the base URL. These components should *not* be percent encoded.
    /// They will automatically be percent-encoded when the URL request is created.
    var pathComponents: [URLPathComponent] { get }

    /// The URL fragment for the request. Defaults to `nil`.
    var fragment: String? { get }

    /// The query items for the request. Defaults to `nil`.
    var queryItems: [URLQueryItem]? { get }

    /// The HTTP body for the request. Defaults to `nil`.
    var httpBody: HTTPBody? { get }

    /// The response handler for the request.
    var responseHandler: AnyHandler<HTTPResponse<Data>, Success> { get }
}


public extension WebServiceRequest {
    /// Creates and returns a URL request with the instance’s components and the specified base URL configuration.
    ///
    /// - Parameter baseURLConfiguration: The base URL configuration from which to get the `URL` for the instance’s
    ///       `baseURL`.
    /// - Returns: A URL request representing the API request or `nil` if no such request can be created. Returning
    ///   `nil` while loading an API request is considered an error and will result in a precondition failure at
    ///   runtime.
    func urlRequest(with baseURLConfiguration: BaseURLConfiguration) -> URLRequest? {
        guard let relativeURL = url(with: baseURLConfiguration) else {
            return nil
        }

        var request = URLRequest(url: relativeURL)
        request.httpRequestMethod = httpMethod

        var headerItems = httpHeaderItems ?? []
        if let httpBody = httpBody {
            request.httpBody = httpBody.data

            let contentTypeHeaderItem = httpBody.contentType.contentTypeHeaderItem

            // If there’s already a content type header, replace it. Otherwise just add it to the end of the list
            if let index = headerItems.firstIndex(where: { $0.field == .contentType }) {
                headerItems[index] = contentTypeHeaderItem
            } else {
                headerItems.append(contentTypeHeaderItem)
            }
        }

        request.httpHeaderItems = headerItems

        return request
    }


    /// Creates and returns a URL with the instance’s components and the specified base URL configuration.
    ///
    /// - Parameter baseURLConfiguration: The base URL configuration from which to get the `URL` for the instance’s
    ///   `baseURL`.
    /// - Returns: A URL for the API request or `nil` if no such URL can be created. Returning `nil` while loading an
    ///   API request is considered an error and will result in a precondition failure at runtime.
    private func url(with baseURLConfiguration: BaseURLConfiguration) -> URL? {
        let base = baseURLConfiguration.url(for: baseURL)
        let path = pathComponents.map { $0.rawValue }.joined(separator: "/")

        guard let percentEncodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let fullURL = percentEncodedPath.isEmpty ? base : URL(string: percentEncodedPath, relativeTo: base),
            var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: true) else {
                return nil
        }

        components.fragment = fragment
        components.queryItems = queryItems
        return components.url
    }


    var httpHeaderItems: [HTTPHeaderItem]? {
        return nil
    }


    var fragment: String? {
        return nil
    }


    var queryItems: [URLQueryItem]? {
        return nil
    }


    var httpBody: HTTPBody? {
        return nil
    }


    /// Loads the request using the specified client and invokes `completion` after the request’s response has been
    /// handled. This method provides a slightly different calling syntax for loading requests with an web service
    /// client. Instead of
    ///
    ///     client.loadData(for: ExampleRequest(parameter1: parameter1, parameter2: parameter2)) { (result) in
    ///         …
    ///     }
    ///
    /// you can do this:
    ///
    ///     ExampleRequest(parameter1: parameter1, parameter2: parameter2).loadData(using: client) { (result) in
    ///         …
    ///     }
    ///
    /// This form requires less nesting when you both create and use a request in a single statement. That said, neither
    /// form is preferred. You should use whichever is easier to read.
    ///
    /// The response handler’s `handle(_:completion:)` method, all `HTTPRequestAuthenticator` methods, and
    /// `completion` are invoked on arbitrary queues. You are responsible for dispatching to a different queue inside
    /// your handler, authenticator implementations, and completion as needed.
    ///
    /// - Parameters:
    ///   - client: The web service client with which to load the request.
    ///   - completion: The closure to execute once the load is complete.
    /// - Returns: A task that loads the request. The task is resumed before being returned.
    func loadData<AuthenticatingHTTPClient, BaseURLConfiguration>(
        using client: WebServiceClient<AuthenticatingHTTPClient, BaseURLConfiguration>,
        completion: @escaping (Result<Success, Error>) -> Void
    ) where AuthenticatingHTTPClient.Authenticator == Authenticator, BaseURLConfiguration == Self.BaseURLConfiguration {
        client.loadData(for: self, completion: completion)
    }
}


/// `WebServiceJSONBodyRequest` provides a convenient way to provide an HTTP body that is composed of JSON data.
/// Conforming types need only provide an `Encodable` `jsonBody` property to get a default `httpBody` implementation
/// whose data is the encoded `JSONBody` and whose content type is `.json`.
public protocol WebServiceJSONBodyRequest : WebServiceRequest {
    /// The `Encodable` type of the JSON body
    associatedtype JSONBody : Encodable

    /// The encoder to use to when encoding `jsonBody` as `Data`. If not implemented, a `JSONEncoder` with the default
    /// configuration is used.
    var jsonEncoder: JSONEncoder { get }

    /// The object that represents the JSON HTTP body. If this object cannot be successfully encoded into `Data`
    /// when creating a URL request, a precondition failure will occur.
    var jsonBody: JSONBody { get }
}


public extension WebServiceJSONBodyRequest {
    var httpBody: HTTPBody? {
        let encoder = jsonEncoder
        do {
            return HTTPBody(contentType: .json, data: try encoder.encode(jsonBody))
        } catch {
            preconditionFailure("Raised error while encoding JSON body: \(error)")
        }
    }


    var jsonEncoder: JSONEncoder {
        return JSONEncoder()
    }
}
