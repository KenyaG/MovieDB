//
//  RawRepresentable+UUID+Codable.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 12/4/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension RawRepresentable where Self : Decodable, RawValue == UUID {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(UUID.self))!
    }
}


public extension RawRepresentable where Self : Encodable, RawValue == UUID {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
