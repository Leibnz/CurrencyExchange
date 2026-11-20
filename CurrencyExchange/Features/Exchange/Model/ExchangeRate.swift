//
//  ExchangeRate.swift
//  CurrencyExchange
//
//  Created by Andrew on 18.10.2026.
//

import Foundation

struct ExchangeRate: Equatable {
    let fromCurrency: Currency
    let toCurrency: Currency
    let value: Decimal

    func convert(_ amount: Decimal) -> Decimal {
        amount * value
    }
}
