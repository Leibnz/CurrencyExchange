//
//  Endpoint.swift
//  CurrencyExchange
//
//  Created by Andrew on 16.11.2026.
//

import Foundation

enum EndpointError: Error {
    case invalidURL
}

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]

    init(path: String, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }

    func url(baseURL: URL) throws -> URL {
        let endpointURL = baseURL.appendingPathComponent(path)

        guard var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false) else {
            throw EndpointError.invalidURL
        }

        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            throw EndpointError.invalidURL
        }

        return url
    }
}

extension Endpoint {
    static let tickers = Endpoint(path: "v1/tickers", queryItems: [URLQueryItem(name: "currencies", value: "MXN,ARS")])
}
