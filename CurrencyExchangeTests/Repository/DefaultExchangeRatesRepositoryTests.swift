//
//  DefaultExchangeRatesRepositoryTests.swift
//  CurrencyExchangeTests
//
//  Created by Andrew on 27.10.2026.
//

import XCTest
@testable import CurrencyExchange

@MainActor
final class DefaultExchangeRatesRepositoryTests: XCTestCase {
    
    func testGetRateSuccess() async throws {
        // Arrange
        let json = """
            [
                {
                    "ask": "18.4105000000",
                    "bid": "18.4069700000",
                    "book": "usdc_mxn",
                    "date": "2025-10-20T20:14:57.361483956"
                }
            ]
            """
        
        let data = try XCTUnwrap(json.data(using: .utf8))
        
        let mockClient = MockNetworkClient(result: .success(data))
        
        let repository = DefaultExchangeRatesRepository(networkClient: mockClient)
        
        // Act
        let rate = try await repository.getRate(from: .usdc, to: .mxn)
        
        // Assert
        XCTAssertEqual(rate.value, Decimal(string: "18.4069700000"))
        XCTAssertEqual(rate.fromCurrency, .usdc)
        XCTAssertEqual(rate.toCurrency, .mxn)
        XCTAssertEqual(mockClient.requestCount, 1)
    }
}
