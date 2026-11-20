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

    private func setLoading(_ isLoading: Bool) {
        var updatedState = state
        updatedState.loadingState = isLoading ? .loading : .idle
        state = updatedState
    }

    private func applyRate(_ rate: ExchangeRate, to state: inout ExchangeViewState) {
        state.exchangeRate = rate

        switch state.activeField {
        case .source:
            state.convertedAmount = rate.convert(state.inputAmount)

        case .target:
            state.inputAmount = state.convertedAmount / rate.value
        }
    }

    func loadRate() async {
        guard !Task.isCancelled else { return }

        currencyRequestID += 1
        let requestID = currencyRequestID
        setLoading(true)

        defer {
            if requestID == currencyRequestID {
                setLoading(false)
            }
        }

        let from = state.selectedFromCurrency
        let to = state.selectedToCurrency

        do {
            let result = try await repository.getRate(
                from: from,
                to: to
            )

            guard !Task.isCancelled else { return }
            let rate = result.rate

            guard requestID == currencyRequestID,
                  rate.value > 0,
                  rate.fromCurrency == from,
                  rate.toCurrency == to,
                  state.selectedFromCurrency == from,
                  state.selectedToCurrency == to
            else {
                return
            }

            var updatedState = state

            applyRate(rate, to: &updatedState)

            updatedState.rateSource = result.source
            updatedState.errorMessage = nil

            state = updatedState

        } catch {
            guard !Task.isCancelled, !(error is CancellationError), requestID == currencyRequestID else {
                return
            }

            var updatedState = state

            updatedState.errorMessage = L10n.Error.loadRate

            state = updatedState
        }
    }

    func selectCurrency(_ currency: Currency, for field: CurrencySelectionField) async {
        guard !Task.isCancelled else { return }

        currencyRequestID += 1
        let requestID = currencyRequestID
        setLoading(true)

        defer {
            if requestID == currencyRequestID {
                setLoading(false)
            }
        }

        var newFrom = state.selectedFromCurrency
        var newTo = state.selectedToCurrency

        switch field {
        case .source:
            newFrom = currency

        case .target:
            newTo = currency
        }

        guard newFrom != state.selectedFromCurrency || newTo != state.selectedToCurrency else { return }

        do {
            let result = try await repository.getRate(from: newFrom, to: newTo)

            guard !Task.isCancelled else { return }
            let rate = result.rate

            guard requestID == currencyRequestID,
                  rate.value > 0,
                  rate.fromCurrency == newFrom,
                  rate.toCurrency == newTo
            else { return }

            var updatedState = state

            updatedState.selectedFromCurrency = newFrom
            updatedState.selectedToCurrency = newTo

            applyRate(rate, to: &updatedState)

            updatedState.rateSource = result.source
            updatedState.errorMessage = nil

            state = updatedState
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), requestID == currencyRequestID else {
                return
            }

            var updatedState = state

            updatedState.errorMessage = L10n.Error.swapCurrencies

            state = updatedState
        }
    }

    // MARK: - Update Amount

    func updateAmount(_ text: String, from field: ExchangeActiveField) {
        guard let amount = AmountInputValidator.parse(text) else {
            return
        }

        var updatedState = state
        updatedState.activeField = field

        switch field {
        case .source:
            updatedState.inputAmount = amount

        case .target:
            updatedState.convertedAmount = amount
        }

        if let rate = updatedState.exchangeRate, rate.value > 0 {
            applyRate(rate, to: &updatedState)
        }

        state = updatedState
    }

    // MARK: - Swap Currencies

    func swapCurrencies() async {
        guard !Task.isCancelled else { return }

        currencyRequestID += 1
        let requestID = currencyRequestID
        setLoading(true)

        defer {
            if requestID == currencyRequestID {
                setLoading(false)
            }
        }

        let newFrom = state.selectedToCurrency
        let newTo = state.selectedFromCurrency

        do {
            let result = try await repository.getRate(
                from: newFrom,
                to: newTo
            )

            guard !Task.isCancelled else { return }
            let rate = result.rate

            guard requestID == currencyRequestID,
                  rate.value > 0,
                  rate.fromCurrency == newFrom,
                  rate.toCurrency == newTo
            else {
                return
            }

            var updatedState = state

            updatedState.selectedFromCurrency = newFrom
            updatedState.selectedToCurrency = newTo

            switch updatedState.activeField {
            case .source:
                updatedState.inputAmount = state.convertedAmount

            case .target:
                updatedState.convertedAmount = state.inputAmount
            }

            applyRate(rate, to: &updatedState)

            updatedState.rateSource = result.source
            updatedState.errorMessage = nil

            state = updatedState

        } catch {
            guard !Task.isCancelled, !(error is CancellationError), requestID == currencyRequestID else {
                return
            }

            var updatedState = state

            updatedState.errorMessage =
                "Unable to swap currencies. Please try again."

            state = updatedState
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
