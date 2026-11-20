//
//  APIConfiguration.swift
//  CurrencyExchange
//
//  Created by Andrew on 16.11.2026.
//

import Foundation

struct APIConfiguration {
    let baseURLString: String

    static let production = APIConfiguration(
        baseURLString: "https://api.dolarapp.dev"
    )

    func url(for endpoint: Endpoint) throws -> URL {
        guard let baseURL = URL(string: baseURLString),
              let scheme = baseURL.scheme,
              ["http", "https"].contains(scheme),
              baseURL.host != nil
        else {
            throw EndpointError.invalidURL
        }

        return try endpoint.url(baseURL: baseURL)
    }
}
