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
        return amount * value
    }
    
    var reversed: ExchangeRate {
        ExchangeRate(
            fromCurrency: toCurrency,
            toCurrency: fromCurrency,
            value: Decimal(1) / value
        )
    }
}
