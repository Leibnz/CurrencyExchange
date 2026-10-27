//
//  MockNetworkClient.swift
//  CurrencyExchangeTests
//
//  Created by Andrew on 27.10.2026.
//

import Foundation
@testable import CurrencyExchange

final class MockNetworkClient: NetworkClient {
    
    var result: Result<Data, Error>
    private(set) var requestCount = 0
    
    init(result: Result<Data, Error>) {
        self.result = result
    }
    
    func get<T: Decodable>(from url: URL, as type: T.Type) async throws -> T {
        
        requestCount += 1
        
        let data = try result.get()
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
