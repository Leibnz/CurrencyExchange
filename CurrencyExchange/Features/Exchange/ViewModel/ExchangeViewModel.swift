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
    
    private var currencyRequestID = 0
    
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
            
            guard rate.value > 0,
                  rate.fromCurrency == updatedState.selectedFromCurrency,
                  rate.toCurrency == updatedState.selectedToCurrency else { return }
            
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
    
    func selectCurrency(_ currency: Currency, for field: CurrencySelectionField) async {
        var newFrom = state.selectedFromCurrency
        var newTo = state.selectedToCurrency
        
        switch field {
        case .source:
            newFrom = currency
        
        case .target:
            newTo = currency
        }
        
        guard newFrom != state.selectedFromCurrency || newTo != state.selectedToCurrency else { return }
        
        currencyRequestID += 1
        let requestID = currencyRequestID
        
        do {
            let rate = try await repository.getRate(from: newFrom, to: newTo)
            
            guard requestID == currencyRequestID,
                  rate.value > 0,
                  rate.fromCurrency == newFrom,
                  rate.toCurrency == newTo
                    else { return }
            
            var updatedState = state
            
            updatedState.selectedFromCurrency = newFrom
            updatedState.selectedToCurrency = newTo
            updatedState.exchangeRate = rate
            
            switch updatedState.activeField {
            case .source:
                updatedState.convertedAmount = updatedState.inputAmount * rate.value
                
            case .target:
                updatedState.inputAmount = updatedState.convertedAmount / rate.value
            }
            
            state = updatedState
        } catch {
            guard requestID == currencyRequestID else { return }
            
            print("Currency selection failed: \(error)")
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
        let newFrom = state.selectedToCurrency
        let newTo = state.selectedFromCurrency

        currencyRequestID += 1
        let requestID = currencyRequestID

        do {
            let rate = try await repository.getRate(
                from: newFrom,
                to: newTo
            )

            guard requestID == currencyRequestID,
                  rate.value > 0,
                  rate.fromCurrency == newFrom,
                  rate.toCurrency == newTo else {
                return
            }

            var updatedState = state

            updatedState.selectedFromCurrency = newFrom
            updatedState.selectedToCurrency = newTo
            updatedState.exchangeRate = rate

            let previousSourceAmount = state.inputAmount
            let previousTargetAmount = state.convertedAmount

            switch updatedState.activeField {
            case .source:
                updatedState.inputAmount = previousTargetAmount
                updatedState.convertedAmount =
                    previousTargetAmount * rate.value

            case .target:
                updatedState.convertedAmount = previousSourceAmount
                updatedState.inputAmount =
                    previousSourceAmount / rate.value
            }

            state = updatedState

        } catch {
            guard requestID == currencyRequestID else {
                return
            }

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
