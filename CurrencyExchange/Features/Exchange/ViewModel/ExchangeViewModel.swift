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
            updatedState.convertedAmount = rate.convert(updatedState.inputAmount)
            
            state = updatedState
            
        } catch {
            print("Failed to load exchange rate: \(error)")
        }
    }
    
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
}
