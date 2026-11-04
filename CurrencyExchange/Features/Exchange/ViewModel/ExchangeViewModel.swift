//
//  ExchangeViewModel.swift
//  CurrencyExchange
//
//  Created by Andrew on 16.10.2026.
//

import Foundation

@MainActor
final class ExchangeViewModel {
    
    private let repository: ExchangeRatesRepository
    
    private(set) var state: ExchangeViewState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    var onStateChange: ((ExchangeViewState) -> Void)?
    
    init(repository: ExchangeRatesRepository) {
        self.repository = repository
    }
    
    func loadRate() async {
        do {
            let rate = try await repository.getRate(
                from: state.selectedFromCurrency,
                to: state.selectedToCurrency
            )
            
            var updatedState = state
            
            guard rate.fromCurrency == updatedState.selectedFromCurrency,
                  rate.toCurrency == updatedState.selectedToCurrency else {
                return
            }
            
            updatedState.exchangeRate = rate
            
            switch updatedState.activeField {
            case .source:
                updatedState.convertedAmount = rate.convert(updatedState.inputAmount)
            
            case .target:
                updatedState.inputAmount = updatedState.convertedAmount / rate.value
            }
            
            state = updatedState
            
        } catch {
            print("Failed to load exchange rate: \(error)")
        }
    }
    
    // MARK: - Update Amount
    
    func updateAmount(_ text: String, from field: ExchangeActiveField) {
        let normalizedText = text.replacingOccurrences(
            of: ",",
            with: "."
        )
        
        var updatedState = state
        updatedState.activeField = field
        
        let amount: Decimal
        
        if normalizedText.isEmpty {
            amount = 0
        } else {
            guard let parsedAmount = Decimal(
                string: normalizedText,
                locale: Locale(identifier: "en_US_POSIX")
            ), parsedAmount >= 0 else {
                return
            }
            
            amount = parsedAmount
        }
        
        let rate = updatedState.exchangeRate.value
        
        guard rate > 0 else {
            return
        }
        
        switch field {
        case .source:
            updatedState.inputAmount = amount
            updatedState.convertedAmount = amount * rate
            
        case .target:
            updatedState.convertedAmount = amount
            updatedState.inputAmount = amount / rate
        }
        
        state = updatedState
    }
    
    // MARK: - Swap Currencies
    
    func swapCurrencies() async {
        var updatedState = state
        
        let previousFrom = updatedState.selectedFromCurrency
        updatedState.selectedFromCurrency = updatedState.selectedToCurrency
        updatedState.selectedToCurrency = previousFrom
        
        updatedState.inputAmount = state.convertedAmount
        
        do {
            let rate = try await repository.getRate(
                from: updatedState.selectedFromCurrency,
                to: updatedState.selectedToCurrency
            )
            
            updatedState.exchangeRate = rate
            updatedState.convertedAmount = rate.convert(
                updatedState.inputAmount
            )
            
            state = updatedState
        } catch {
            print("Swap failed: \(error)")
        }
    }
    
    // MARK: - ActiveField
    func setActiveField(_ field: ExchangeActiveField) {
        guard state.activeField != field else {
            return
        }
        
        var updatedState = state
        updatedState.activeField = field
        state = updatedState
    }
}
