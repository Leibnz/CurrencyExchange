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

enum ExchangeLoadingState: Equatable {
    case idle
    case loading
}

enum ExchangeRateSource: Equatable {
    case live
    case cached
    case fallback
    case identity
}

struct ExchangeViewState: Equatable {
    var activeField: ExchangeActiveField = .source
    var loadingState: ExchangeLoadingState = .idle
    var rateSource: ExchangeRateSource? = nil
    var errorMessage: String?
    
    var selectedFromCurrency: Currency
    var selectedToCurrency: Currency
    
    var inputAmount: Decimal
    var convertedAmount: Decimal
    
    var exchangeRate: ExchangeRate?
    
    var rateDescription: String {
        guard let exchangeRate else { return "Rate not loaded" }
        let formattedRate = exchangeRate.value.formatted(
            .number
                .precision(.fractionLength(4))
        )
        
        return "1 \(selectedFromCurrency.code) = " +
        "\(formattedRate) \(selectedToCurrency.code)"
    }
    
    var rateSourceDescription: String {
        if loadingState == .loading { return "Loading…" }
        switch rateSource {
        case .live: return "Live"
        case .cached: return "Cached"
        case .fallback: return "Offline fallback"
        case .identity: return "Same currency"
        case nil: return "Not loaded"
        }
    }
    
    static let initial = ExchangeViewState(
        selectedFromCurrency: .usdc,
        selectedToCurrency: .mxn,
        inputAmount: Decimal(1),
        convertedAmount: Decimal(0),
        exchangeRate: nil
    )
}
