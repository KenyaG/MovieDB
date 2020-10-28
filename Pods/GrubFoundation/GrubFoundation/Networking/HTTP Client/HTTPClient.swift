//
//  HTTPClient.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 3/18/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation

#if os(macOS)
    import CoreServices
#else
    import MobileCoreServices
#endif


/// `HTTPClientProtocol` defines the interface for HTTP clients.
public protocol HTTPClientProtocol {
    /// The client’s delegate.
    var delegate: HTTPClientDelegate? { get set }

    /// Loads `request` and handles its response with `responseHandler`.
    ///
    /// The response handler’s `handle(_:completion:)` method is invoked on an arbitrary queue. You are responsible
    /// for dispatching to a different queue inside your handler implementation as needed.
    ///
    /// - Parameters:
    ///   - request: The request to load. The request must be an HTTP or HTTPS request.
    ///   - responseHandler: The object that handles the load request’s response.
    func loadData<ResponseHandler>(for request: URLRequest, responseHandler: ResponseHandler)
        where ResponseHandler : Handler, ResponseHandler.Input == HTTPResponse<Data>
}


/// `HTTPClient`s provide a simple interface for loading HTTP requests and handling their responses. HTTP clients
/// perform requests via a URL session and handle their responses with `Handler` objects. HTTP clients are meant
/// to be created and destroyed freely.
///
/// `HTTPClient` is built to be very simple: it has a single primitive method to create a task that loads a URL
/// request. Despite this simplicity, its interface is flexible enough to enable most URL request loading behaviors.
/// Generally speaking, many tasks can be achieved by using a specialized `Handler` to handle the results of a load
/// request. For example, JSON deserialization can be easily modeled as a response handler, as can richer error
/// handling. In other cases, additional functionality can be added to HTTP clients by composing them within other
/// objects that have more specific domain knowledge.
public class HTTPClient<Session> : HTTPClientProtocol where Session : HTTPURLSession {
    /// The client’s URL session.
    public let urlSession: Session

    /// The client’s delegate
    public weak var delegate: HTTPClientDelegate?


    /// Initializes a new HTTP client with the specified session.
    ///
    /// - Parameter urlSession: The client’s URL session.
    public init(urlSession: Session) {
        self.urlSession = urlSession
    }


    public func loadData<ResponseHandler>(for request: URLRequest, responseHandler: ResponseHandler)
        where ResponseHandler : Handler, ResponseHandler.Input == HTTPResponse<Data> {
            loadData(for: request) { (result) in
                responseHandler.handle(result, completion: { _ in })
            }
    }


    /// Loads the data for specified request and invokes the completion handler. In addition to its use in this class,
    /// this method is used by `AuthenticatingHTTPClient` to execute its prepared requests.
    ///
    /// - Parameters:
    ///   - request: The request for which to load data.
    ///   - completion: A closure to invoke once the load has completed.
    func loadData(for request: URLRequest, completion: @escaping (Result<HTTPResponse<Data>, Error>) -> Void) {
        // Create a non-weak reference to the delegate
        let delegate = self.delegate
        let requestToLoad = delegate?.httpClient(self, willLoadDataFor: request) ?? request

        urlSession.dataTask(with: requestToLoad) { (data, response, error) in
            DataTaskOutputTransformer().handle(.success((data, response, error))) { (result) in
                // Log the result no matter what
                networkingLogger.logResult(result, ofLoading: requestToLoad)

                // If we don’t have a delegate, we’re done
                guard let delegate = delegate else {
                    completion(result)
                    return
                }

                // Otherwise, defer to the delegate whether we should retry the request or proceed
                delegate.httpClient(self, didReceive: result, for: requestToLoad) { (disposition) in
                    switch disposition {
                    case .proceed:
                        completion(result)
                    case .retry:
                        self.loadData(for: request, completion: completion)
                    }
                }
            }
        }.resume()
    }


    /// A private transformer that converts the output of a `URLSessionDataTask` into a `HTTPResponse<Data>`.
    private struct DataTaskOutputTransformer : Transformer {
        typealias Input = (Data?, URLResponse?, Error?)
        typealias Output = HTTPResponse<Data>

        /// Transforms the output of a `URLSessionDataTask` into a `HTTPResponse<Data>`.
        ///
        /// - Parameter input: The output of a `URLSessionDataTask`
        /// - Returns: The data of the response wrapped in a `HTTPResponse`.
        /// - Throws: the input error if it is non-`nil`. Throws `HTTPResponseError.noResponse` if the `URLResponse`
        ///   is `nil`. Throws `HTTPResponseError.nonHTTPURLResponse` if the `URLResponse` cannot be cast as an
        ///   `HTTPURLResponse`.
        func transform(_ input: (Data?, URLResponse?, Error?)) throws -> HTTPResponse<Data> {
            let (data, response, error) = input
            if let error = error {
                throw error
            }

            guard let urlResponse = response else {
                throw HTTPResponseError.noResponse
            }

            guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                throw HTTPResponseError.nonHTTPURLResponse(urlResponse)
            }

            return HTTPResponse(response: httpURLResponse, body: data ?? Data())
        }
    }
}


/// `HTTPClientResponseDisposition` indicates how an HTTP client should should proceed after receiving a response.
public enum HTTPClientResponseDisposition {
    /// Indicates that the client should proceed to process the response and pass it to the relevant handler.
    case proceed

    /// Indicates that the client should retry the original request.
    case retry
}


/// `HTTPClientDelegate` provides a mechanism for a `HTTPClient`’s delegate to modify the requests the client
/// loads and control its response handling (somewhat). Most HTTP clients do not need a delegate.
public protocol HTTPClientDelegate : AnyObject {
    /// Notifies the delegate that `client` is about to start loading data for `request`. The returned `URLRequest` will
    /// be loaded instead. Thus, if you wish to modify the request that is about to be loaded, you can do so and return
    /// that instead. Otherwise, just return the original request.
    ///
    /// - Parameters:
    ///   - client: The client that is about to load `request`.
    ///   - request: The request being loaded.
    func httpClient(_ client: HTTPClientProtocol, willLoadDataFor request: URLRequest) -> URLRequest

    /// Notifies the delegate that `client` has received `response`. The delegate must then decide whether to keep the
    /// response (by invoking `completion` with `.proceed`) or retry the original request (invoking `completion` with
    /// `.retry`).
    ///
    /// - Parameters:
    ///   - client: The client that received the repsonse.
    ///   - response: The response that was received.
    ///   - request: The request for which the response was received.
    ///   - completion: A completion
    func httpClient(
        _ client: HTTPClientProtocol,
        didReceive response: Result<HTTPResponse<Data>, Error>,
        for request: URLRequest,
        completion: @escaping (HTTPClientResponseDisposition) -> Void
    )
}


// MARK: - Logging Helpers

private extension Logger {
    /// Logs the result of loading the specified request. Does nothing if the logger doesn’t log `.verbose` messages.
    ///
    /// - Parameters:
    ///   - result: The result of loading `request`.
    ///   - request: The request that was loaded.
    func logResult(_ result: Result<HTTPResponse<Data>, Error>, ofLoading request: URLRequest) {
        if logs(at: .verbose) {
            var messageText = "Completed request: \(request.loggingDescription)\n"
            do {
                messageText += "Response: \(try result.get().loggingDescription)"
            } catch {
                messageText += "Received error: \(error)"
            }

            logVerbose(messageText)
        }
    }
}


private extension Data {
    /// Returns a description of the data suitable for logging.
    ///
    /// - Parameter contentType: The content type associated with the data.
    /// - Returns: A description of the data suitable for logging.
    func loggingDescription(contentType: String?) -> String {
        guard let contentType = contentType else {
            return debugDescription
        }

        if !UTTypeConformsTo(MediaType(contentType).uniformTypeIdentifier as CFString, kUTTypeText) {
            guard let semicolonIndex = contentType.firstIndex(of: ";") else {
                return debugDescription
            }

            let betterContentType = String(contentType[contentType.startIndex ..< semicolonIndex])
            guard UTTypeConformsTo(MediaType(betterContentType).uniformTypeIdentifier as CFString, kUTTypeText) else {
                return debugDescription
            }

        }

        guard let contentString = String(data: self, encoding: .utf8) else {
            return debugDescription
        }

        return contentString
    }
}


private extension URLRequest {
    /// A description of the URL request suitable for logging.
    var loggingDescription: String {
        var lines: [String] = ["\(httpMethod ?? "") \(url?.absoluteString ?? "")"]

        if let allHTTPHeaderFields = allHTTPHeaderFields, !allHTTPHeaderFields.isEmpty {
            lines.append("Headers:")
            for (headerField, value) in allHTTPHeaderFields {
                lines.append("\(headerField): \(value)")
            }
        }

        if let bodyData = httpBody {
            let contentType = value(for: .contentType)
            lines.append("Body:")
            lines.append("\(bodyData.loggingDescription(contentType: contentType))")
        }

        return lines.joined(separator: "\n")
    }
}


private extension HTTPResponse where Body == Data {
    /// A description of the HTTP response suitable for logging.
    var loggingDescription: String {
        var lines: [String] = []

        lines.append("\(response.statusCode): \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")

        var contentType: String?
        let headerItems = response.httpHeaderItems
        if !headerItems.isEmpty {
            lines.append("Headers:")
            for headerItem in headerItems {
                lines.append("\(headerItem.field.rawValue): \(headerItem.value)")

                if headerItem.field == .contentType {
                    contentType = headerItem.value
                }
            }
        }

        if !body.isEmpty {
            lines.append("Body:")
            lines.append("\(body.loggingDescription(contentType: contentType))")
        }

        return lines.joined(separator: "\n")
    }
}
