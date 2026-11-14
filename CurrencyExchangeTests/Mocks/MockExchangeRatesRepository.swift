//
//  MockExchangeRatesRepository.swift
//  CurrencyExchangeTests
//
//  Created by Andrew on 06.11.2026.
//

import Foundation
@testable import CurrencyExchange

@MainActor
final class MockExchangeRatesRepository: ExchangeRatesRepository {

    var rateValue: Decimal = 20
    var source: ExchangeRateSource = .live
    var error: Error?

    private(set) var requestCount = 0

    func getRate(
        from: Currency,
        to: Currency
    ) async throws -> ExchangeRateResult {
        requestCount += 1

        if let error {
            throw error
        }

        return ExchangeRateResult(
            rate: ExchangeRate(
                fromCurrency: from,
                toCurrency: to,
                value: rateValue
            ),
            source: source
        )
    }
}
