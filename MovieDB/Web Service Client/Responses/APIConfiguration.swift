//
//  APIConfiguration.swift
//  MovieDB
//
//  Created by Kenya Gordon on 10/18/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation
import GrubFoundation

public struct APIConfiguration : Decodable {
    public enum CodingKeys : String, CodingKey {
        case changeKeys = "change_keys"
        case imageConfiguration = "images"
    }
    public let changeKeys: [String]
    public let imageConfiguration: APIImageConfiguration
}

public struct APIImageConfiguration : Decodable {
    public enum CodingKeys : String, CodingKey {
        case secureBaseURL = "secure_base_url"
        case backdropSizes = "backdrop_sizes"
        case logoSizes = "logo_sizes"
        case posterSizes = "poster_sizes"
        case profileSizes = "profile_sizes"
        case stillSizes = "still_sizes"
    }
    public let secureBaseURL: URL
    public let backdropSizes: [String]
    public let logoSizes: [String]
    public let posterSizes: [String]
    public let profileSizes: [String]
    public let stillSizes: [String]
}
