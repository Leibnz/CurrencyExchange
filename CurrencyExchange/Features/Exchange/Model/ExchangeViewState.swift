//
//  ExchangeViewState.swift
//  CurrencyExchange
//
//  Created by Andrew on 18.10.2026.
//

import Foundation

enum ExchangeActiveField: Equatable {
    case source
    case target
}

struct ExchangeViewState: Equatable {
    var activeField: ExchangeActiveField = .source
    
    var selectedFromCurrency: Currency
    var selectedToCurrency: Currency
    
    var inputAmount: Decimal
    var convertedAmount: Decimal
    
    var exchangeRate: ExchangeRate
    
    var rateDescription: String {
        let formattedRate = exchangeRate.value.formatted(
            .number
                .precision(.fractionLength(4))
        )
        
        return "1 \(selectedFromCurrency.code) = " +
        "\(formattedRate) \(selectedToCurrency.code)"
    }
    
    static let initial = ExchangeViewState(
        selectedFromCurrency: .usdc,
        selectedToCurrency: .mxn,
        inputAmount: Decimal(9999),
        convertedAmount: Decimal(9999) * Decimal(string: "18.4097")!,
        exchangeRate: ExchangeRate(
            fromCurrency: .usdc,
            toCurrency: .mxn,
            value: Decimal(string: "18.4097")!
        )
    )
}
