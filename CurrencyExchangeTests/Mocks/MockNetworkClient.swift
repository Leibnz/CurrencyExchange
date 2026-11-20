//
//  MockNetworkClient.swift
//  CurrencyExchangeTests
//
//  Created by Andrew on 27.10.2026.
//

import Foundation
@testable import CurrencyExchange

final class MockNetworkClient: NetworkClient {
    enum Response {
        case success([TickerDTO])
        case failure(Error)
    }

    var responses: [Response] = []
    private(set) var requestCount = 0

    func get<T: Decodable>(from url: URL, as type: T.Type) async throws -> T {
        requestCount += 1
        guard !responses.isEmpty else {
            throw URLError(.badServerResponse)
        }
        let response = responses.removeFirst()
        switch response {
        case .success(let tickers):
            guard let value = tickers as? T else {
                throw URLError(.cannotDecodeContentData)
            }
            return value
        case .failure(let error):
            throw error
        }
    }
}
