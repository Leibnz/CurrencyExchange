//
//  ExchangeViewModel.swift
//  CurrencyExchange
//
//  Created by Andrew on 16.10.2026.
//

import Foundation

final class ExchangeViewModel {
    
    private(set) var state: ExchangeViewState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    var onStateChange: ((ExchangeViewState) -> Void)?
    
    // MARK: - Update Amount
    
    func updateAmount(_ text: String) {
        let normalizedText = text.replacingOccurrences(
            of: ",",
            with: "."
        )
        
        guard let amount = Decimal(
            string: normalizedText,
            locale: Locale(identifier: "en_US_POSIX")
        ), amount >= 0 else {
            return
        }
        
        var updatedState = state
        
        updatedState.inputAmount = amount
        updatedState.convertedAmount = updatedState.exchangeRate.convert(amount)
        
        state = updatedState
    }
    
    // MARK: - Swap Currencies
    
    func swapCurrencies() {
        
        var updatedState = state
        
        let previousConvertedAmount = updatedState.convertedAmount
        
        updatedState.exchangeRate = updatedState.exchangeRate.reversed
        
        updatedState.selectedFromCurrency = updatedState.exchangeRate.fromCurrency
        
        updatedState.selectedToCurrency = updatedState.exchangeRate.toCurrency
        
        updatedState.inputAmount = previousConvertedAmount
        
        updatedState.convertedAmount = updatedState.exchangeRate.convert(
            previousConvertedAmount
        )
        
        state = updatedState
    }
}
