//
//  MovieDBAuthenticator.swift
//  MovieApp
//
//  Created by Kenya Gordon on 10/4/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation
import GrubFoundation

internal final class MovieDBAuthenticator : HTTPRequestAuthenticator {
    public enum Context {
        case authenticated
    }

    struct APIKeyError : Error { }
    var movieDBAPIKey = "2ed8d3aafd13acb99d7062157a566c53"


    ///Asynchronously prepares a request with any required authentication information.
    func prepare(_ request: URLRequest,
                        with context: Context,
                        failedRequest: URLRequest?,
                        completion: @escaping (AuthenticatedRequestDisposition) -> Void) {
        
        // Correct answer
        guard failedRequest == nil else {
            completion(.abort(APIKeyError()))
            return
        }

        // 1. Make a copy of the request
        // 2. Add api_key="…"
        let authenticatedRequest = request.append(URLQueryItem(name: "api_key", value: movieDBAPIKey))

        // 3. Call proceed with that modified request
        completion(.proceed(authenticatedRequest))
    }

    ///Returns whether a given HTTP response is an authentication failure.
    func isAuthenticationFailure(response: Result<HTTPResponse<Data>, Error>, request: URLRequest, context: Context) -> Bool {
        // Correct Answer
        //
        // 1. If the result was a .failure, it's not an auth failure
        // 2. If the response status code is 401 (unauthorized) it is an auth failure
        // 3. Else, it's not
        do {
            let response = try response.get()
            return response.response.httpStatusCode == .unauthorized
        } catch {
            return false
        }
    }
}

internal extension URLRequest {
    //Will need to create a function to append the api_key info
    func append(_ queryItem: URLQueryItem) -> URLRequest {

        //Check if url is nil
        guard let url = self.url else {
            //should an error or something be returned here?
            return self
        }

        //pass url into URLComponents
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)


        var queryItems = urlComponents?.queryItems ?? []
        queryItems.append(queryItem)
        urlComponents?.queryItems = queryItems

        //Check if nil
        guard let updatedURL = urlComponents?.url else {
            return self
        }

        //modified  url
        var updatedRequest = self
        updatedRequest.url = updatedURL
        return updatedRequest
    }
}

