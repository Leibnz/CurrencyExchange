//
//  SuspendedExchangeRatesRepository.swift
//  CurrencyExchangeTests
//
//  Created by Andrew on 06.11.2026.
//

import Foundation
@testable import CurrencyExchange

@MainActor
final class SuspendedExchangeRatesRepository: ExchangeRatesRepository {

    private var continuation:
        CheckedContinuation<ExchangeRateResult, Error>?

    private(set) var requestCount = 0

    func getRate(
        from: Currency,
        to: Currency
    ) async throws -> ExchangeRateResult {
        requestCount += 1

        return try await withCheckedThrowingContinuation {
            continuation = $0
        }
    }

    func complete(
        from: Currency,
        to: Currency,
        rate: Decimal
    ) {
        let result = ExchangeRateResult(
            rate: ExchangeRate(
                fromCurrency: from,
                toCurrency: to,
                value: rate
            ),
            source: .live
        )

        continuation?.resume(returning: result)
        continuation = nil
    }
}
