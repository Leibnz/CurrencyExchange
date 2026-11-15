//
//  DefaultExchangeRatesRepositoryTests.swift
//  CurrencyExchangeTests
//
//  Created by Andrew on 27.10.2026.
//

import XCTest
@testable import CurrencyExchange

@MainActor
final class DefaultExchangeRatesRepositoryTests: XCTestCase {
    private func ticker(
        book: String = "usdc_ars",
        bid: String = "1000",
        ask: String = "1250"
    ) -> TickerDTO {
        TickerDTO(
            ask: ask,
            bid: bid,
            book: book,
            date: "2026-11-15T00:00:00Z"
        )
    }

    func testUSDcToARSUsesBid() async throws {
        let client = MockNetworkClient()
        client.responses = [.success([ticker()])]
        let sut = DefaultExchangeRatesRepository(networkClient: client)

        let result = try await sut.getRate(from: .usdc, to: .ars)

        XCTAssertEqual(result.rate.fromCurrency, .usdc)
        XCTAssertEqual(result.rate.toCurrency, .ars)
        XCTAssertEqual(result.rate.value, Decimal(1000))
        XCTAssertEqual(result.source, .live)
        XCTAssertEqual(client.requestCount, 1)
    }

    func testARSToUSDcUsesInverseAsk() async throws {
        let client = MockNetworkClient()
        client.responses = [.success([ticker()])]
        let sut = DefaultExchangeRatesRepository(networkClient: client)

        let result = try await sut.getRate(from: .ars, to: .usdc)

        XCTAssertEqual(result.rate.fromCurrency, .ars)
        XCTAssertEqual(result.rate.toCurrency, .usdc)
        XCTAssertEqual(result.rate.value, Decimal(string: "0.0008")!)
        XCTAssertEqual(result.source, .live)
        XCTAssertEqual(client.requestCount, 1)
    }

    func testSameCurrencyReturnsIdentityWithoutNetwork() async throws {
        let client = MockNetworkClient()
        let sut = DefaultExchangeRatesRepository(networkClient: client)

        let result = try await sut.getRate(from: .ars, to: .ars)

        XCTAssertEqual(result.rate.value, 1)
        XCTAssertEqual(result.rate.fromCurrency, .ars)
        XCTAssertEqual(result.rate.toCurrency, .ars)
        XCTAssertEqual(result.source, .identity)
        XCTAssertEqual(client.requestCount, 0)
    }

    func testEmptyResponseUsesBundledFallback() async throws {
        let client = MockNetworkClient()
        client.responses = [.success([])]
        let sut = DefaultExchangeRatesRepository(networkClient: client)

        let result = try await sut.getRate(from: .usdc, to: .ars)

        XCTAssertEqual(result.source, .fallback)
        XCTAssertGreaterThan(result.rate.value, 0)
        XCTAssertEqual(client.requestCount, 1)
    }

    func testCachedRateIsReturnedAfterNetworkFailure() async throws {
        let client = MockNetworkClient()
        client.responses = [
            .success([ticker(bid: "1000", ask: "1250")]),
            .failure(URLError(.notConnectedToInternet))
        ]
        let sut = DefaultExchangeRatesRepository(networkClient: client)

        let live = try await sut.getRate(from: .usdc, to: .ars)
        let cached = try await sut.getRate(from: .usdc, to: .ars)

        XCTAssertEqual(live.source, .live)
        XCTAssertEqual(cached.source, .cached)
        XCTAssertEqual(cached.rate.value, live.rate.value)
        XCTAssertEqual(client.requestCount, 2)
    }
}
