//
//  ConfigurationServiceClient.swift
//  MovieDB
//
//  Created by Kenya Gordon on 10/19/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation
import GrubFoundation

protocol ConfigurationServiceClient {
    func fetchConfiguration(completion: @escaping (Result<HTTPResponse<APIConfiguration>, Error>) -> Void)
}
extension MovieDBClient: ConfigurationServiceClient {
    public func fetchConfiguration(completion: @escaping (Result<HTTPResponse<APIConfiguration>, Error>) -> Void) {
        loadData(for: FetchConfigurationRequest(), completion: completion)
    }
}
