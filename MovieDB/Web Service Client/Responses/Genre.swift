//
//  Genre.swift
//  MovieDB
//
//  Created by Kenya Gordon on 10/5/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation
import GrubFoundation


public struct Genre : Decodable {
    public let id: GenreID
    public let name: String
}

public struct GenreID : RawRepresentable, Decodable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
