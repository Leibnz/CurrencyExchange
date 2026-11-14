//
//  ExchangeRatesRepository.swift
//  CurrencyExchange
//
//  Created by Andrew on 22.10.2026.
//

import Foundation

protocol ExchangeRatesRepository {
    func getRate(from: Currency, to: Currency) async throws -> ExchangeRateResult
}
