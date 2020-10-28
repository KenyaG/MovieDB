//
//  BaseURLConfiguring.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 2/2/2020.
//  Copyright © 2020 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `BaseURLConfiguring` provides an interface by which an web service client and its requests can symbolically
/// refer to the client’s base URLs, and provides a method to resolve those symbolic references to actual URLs.
///
/// Base URL configurations are useful when an API supports multiple base URLs across its API, e.g., to separate
/// services by hostname or to version APIs. They are also useful when an API has different base URLs for staging and
/// production environments.
///
/// Each base URL configuration has an associated type called `BaseURL` which encapsulates information about a
/// particular base URL. This is most typically an enum that provides a symbolic name for the base URL. Web service
/// client requests return instances of this type to indicate which base URL the web service client should use when
/// forming a URL request.
///
/// For example, suppose we have an API with different services on different hosts. We might create a base URL
/// configuration like this:
///
///     struct ExampleBaseURLConfiguration : BaseURLConfiguring {
///         enum BaseURL {
///             case service1, service2, service3
///         }
///
///         let service1URL: URL
///         let service2URL: URL
///         let service3URL: URL
///
///         func url(for baseURL: BaseURL) -> URL {
///             switch baseURL {
///             case .service1:
///                 return service1URL
///             case .service2:
///                 return service2URL
///             case .service3:
///                 return service3URL
///             }
///         }
///     }
///
/// We can now create multiple instances of this configuration for staging and production environments.
///
///     extension ExampleBaseURLConfiguration {
///         static let staging = ExampleBaseURLConfiguration(
///             service1URL: URL(string: "https://pp-service1.api.com")!,
///             service2URL: URL(string: "https://pp-service2.api.com")!,
///             service3URL: URL(string: "https://pp-service3.api.com")!
///         )
///
///         static let production = ExampleBaseURLConfiguration(
///             service1URL: URL(string: "https://service1.api.com")!,
///             service2URL: URL(string: "https://service2.api.com")!,
///             service3URL: URL(string: "https://service3.api.com")!
///         )
///     }
///
/// API requests for a client that uses this configuration return `.service1`, `.service2`, or `.service3` for their
/// base URL to indicate which one they use.
public protocol BaseURLConfiguring {
    /// A type that encapsulates information about a base URL that its associated client can handle. This is typically
    /// an enum with symbolic names for the base URLs.
    associatedtype BaseURL

    /// Returns a `URL` for the specified base URL. The URLs returned here are typically provided during initialization
    /// of the instance.
    ///
    /// - Parameter baseURL: The base URL instance for which a URL is being returned.
    /// - Returns: The URL corresponding to `baseURL`.
    func url(for baseURL: BaseURL) -> URL
}


/// `SingleBaseURLConfiguration` is a reusable base URL configuration for web service clients that only have one base URL.
/// The primary benefit of using it is that API requests whose clients use `SingleBaseURLConfiguration` get an
/// implementation of `baseURL` for free. This reduces boilerplate code for the simple case where there is only one base
/// URL.
public struct SingleBaseURLConfiguration : BaseURLConfiguring, Equatable {
    /// The base URLs for the single base URL configuration. There is almost never any reason to refer to this.
    public enum BaseURL : Equatable {
        /// The only case in the single base URL configuration. There is almost never any reason to refer to this.
        case baseURL
    }

    /// The URL that this object returns in `url(for:)`.
    public let url: URL


    /// Creates a new single base URL configuration with the specified URL.
    ///
    /// - Parameter url: The base URL that this configuration encapsulates.
    public init(url: URL) {
        self.url = url
    }


    public func url(for baseURL: BaseURL) -> URL {
        return url
    }
}


public extension WebServiceRequest where BaseURLConfiguration == SingleBaseURLConfiguration {
    var baseURL: SingleBaseURLConfiguration.BaseURL {
        return .baseURL
    }
}
