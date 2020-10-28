//
//  ConfigurationDataSource.swift
//  MovieDB
//
//  Created by Kenya Gordon on 10/19/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation

protocol ConfigDataSource {
    func fetchConfiguration(completion: @escaping (Result<APIConfiguration, Error>) -> Void)
}

final class ConfigurationDataSource {
    let serviceClient: MovieDBClient
    init(serviceClient: MovieDBClient) {
        self.serviceClient = serviceClient
    }

    func fetchConfiguration(completion: @escaping (Result<APIConfiguration, Error>) -> Void) {
        serviceClient.fetchConfiguration { (result) in
            completion(result.map { $0.body })
        }
    }
}
