//
//  ExchangeViewModelTests.swift
//  CurrencyExchangeTests
//
//  Created by Andrew on 06.11.2026.
//

import XCTest
@testable import CurrencyExchange

@MainActor
final class ExchangeViewModelTests: XCTestCase {

    func testUpdateSourceAmount() {
        // Arrange
        let repository = MockExchangeRatesRepository()

        let viewModel = ExchangeViewModel(repository: repository)

        // Act
        viewModel.updateAmount("100", from: .source)

        // Assert
        XCTAssertEqual(
            viewModel.state.inputAmount,
            Decimal(100)
        )

        XCTAssertEqual(
            viewModel.state.convertedAmount,
            Decimal(100) *
                viewModel.state.exchangeRate.value
        )

        XCTAssertEqual(
            viewModel.state.activeField,
            .source
        )
    }

    func testSelectCurrencySuccess() async {
        // Arrange
        let repository = MockExchangeRatesRepository()
        repository.rateValue = 25

        let viewModel = ExchangeViewModel(
            repository: repository
        )

        // Act
        await viewModel.selectCurrency(
            .ars,
            for: .target
        )

        // Assert
        XCTAssertEqual(
            viewModel.state.selectedFromCurrency,
            .usdc
        )

        XCTAssertEqual(
            viewModel.state.selectedToCurrency,
            .ars
        )

        XCTAssertEqual(
            viewModel.state.exchangeRate.value,
            Decimal(25)
        )

        XCTAssertEqual(
            viewModel.state.convertedAmount,
            viewModel.state.inputAmount * Decimal(25)
        )

        XCTAssertEqual(
            viewModel.state.rateSource,
            .live
        )

        XCTAssertEqual(repository.requestCount, 1)
    }

    func testSelectCurrencyFailureKeepsPreviousState() async {
        // Arrange
        let repository = MockExchangeRatesRepository()
        repository.error = URLError(.notConnectedToInternet)

        let viewModel = ExchangeViewModel(
            repository: repository
        )

        let previousState = viewModel.state

        // Act
        await viewModel.selectCurrency(
            .ars,
            for: .target
        )

        // Assert
        XCTAssertEqual(
            viewModel.state.selectedFromCurrency,
            previousState.selectedFromCurrency
        )

        XCTAssertEqual(
            viewModel.state.selectedToCurrency,
            previousState.selectedToCurrency
        )

        XCTAssertEqual(
            viewModel.state.inputAmount,
            previousState.inputAmount
        )

        XCTAssertEqual(
            viewModel.state.exchangeRate,
            previousState.exchangeRate
        )

        XCTAssertEqual(
            viewModel.state.loadingState,
            .idle
        )

        XCTAssertNotNil(viewModel.state.errorMessage)
    }

    func testLoadingStateDuringCurrencySelection() async {
        // Arrange
        let repository = SuspendedExchangeRatesRepository()

        let viewModel = ExchangeViewModel(
            repository: repository
        )

        // Act
        let task = Task {
            await viewModel.selectCurrency(
                .ars,
                for: .target
            )
        }

        // Wait until the request has started
        await Task.yield()

        // Assert loading
        XCTAssertEqual(
            viewModel.state.loadingState,
            .loading
        )

        // Complete request
        repository.complete(
            from: .usdc,
            to: .ars,
            rate: 25
        )

        await task.value

        // Assert idle
        XCTAssertEqual(
            viewModel.state.loadingState,
            .idle
        )
    }

    func testAmountChangedDuringLoadingIsPreserved() async {
        // Arrange
        let repository = SuspendedExchangeRatesRepository()

        let viewModel = ExchangeViewModel(
            repository: repository
        )

        let task = Task {
            await viewModel.selectCurrency(
                .ars,
                for: .target
            )
        }

        await Task.yield()

        // User edits amount while loading
        viewModel.updateAmount("200", from: .source)

        // API returns new rate
        repository.complete(
            from: .usdc,
            to: .ars,
            rate: 25
        )

        await task.value

        // Assert
        XCTAssertEqual(
            viewModel.state.inputAmount,
            Decimal(200)
        )

        XCTAssertEqual(
            viewModel.state.convertedAmount,
            Decimal(5000)
        )
    }

    func testFallbackRateSource() async {
        // Arrange
        let repository = MockExchangeRatesRepository()

        repository.rateValue = 18
        repository.source = .fallback

        let viewModel = ExchangeViewModel(
            repository: repository
        )

        // Act
        await viewModel.loadRate()

        // Assert
        XCTAssertEqual(
            viewModel.state.exchangeRate.value,
            Decimal(18)
        )

        XCTAssertEqual(
            viewModel.state.rateSource,
            .fallback
        )
    }

    func testSwapCurrenciesWithSourceActivePreservesPreviousTargetAmount() async {
        // Arrange
        let repository = MockExchangeRatesRepository()
        repository.rateValue = 0.05
        let viewModel = ExchangeViewModel(repository: repository)
        viewModel.updateAmount("100", from: .source)
        let previousTargetAmount = viewModel.state.convertedAmount

        // Act
        await viewModel.swapCurrencies()

        // Assert
        XCTAssertEqual(viewModel.state.selectedFromCurrency, .mxn)
        XCTAssertEqual(viewModel.state.selectedToCurrency, .usdc)
        XCTAssertEqual(viewModel.state.activeField, .source)
        XCTAssertEqual(viewModel.state.inputAmount, previousTargetAmount)
        XCTAssertEqual(viewModel.state.convertedAmount, previousTargetAmount * Decimal(string: "0.05")!)
        XCTAssertEqual(viewModel.state.exchangeRate.value, Decimal(string: "0.05")!)
        XCTAssertEqual(viewModel.state.loadingState, .idle)
        XCTAssertNil(viewModel.state.errorMessage)
        XCTAssertEqual(repository.requestCount, 1)
    }

    func testSwapCurrenciesWithTargetActivePreservesPreviousSourceAmount() async {
        // Arrange
        let repository = MockExchangeRatesRepository()
        repository.rateValue = 0.05
        let viewModel = ExchangeViewModel(repository: repository)
        viewModel.updateAmount("184", from: .target)
        let previousSourceAmount = viewModel.state.inputAmount

        // Act
        await viewModel.swapCurrencies()

        // Assert
        XCTAssertEqual(viewModel.state.selectedFromCurrency, .mxn)
        XCTAssertEqual(viewModel.state.selectedToCurrency, .usdc)
        XCTAssertEqual(viewModel.state.activeField, .target)
        XCTAssertEqual(viewModel.state.convertedAmount, previousSourceAmount)
        XCTAssertEqual(viewModel.state.inputAmount, previousSourceAmount / Decimal(string: "0.05")!)
        XCTAssertEqual(viewModel.state.exchangeRate.value, Decimal(string: "0.05")!)
        XCTAssertEqual(viewModel.state.loadingState, .idle)
        XCTAssertNil(viewModel.state.errorMessage)
        XCTAssertEqual(repository.requestCount, 1)
    }
}
