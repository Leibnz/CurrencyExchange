//
//  DefaultExchangeRatesRepository.swift
//  CurrencyExchange
//
//  Created by Andrew on 22.10.2026.
//

import Foundation
import os

enum ExchangeRatesError: Error {
    case unsupportedCurrencyPair
    case invalidRate
    case emptyResponse
    case fallbackUnavailable
}

struct ExchangeRateResult {
    let rate: ExchangeRate
    let source: ExchangeRateSource
}

@MainActor
final class DefaultExchangeRatesRepository: ExchangeRatesRepository {
    
    private let logger = Logger(subsystem: "CurrencyExchange", category: "ExchangeRatesRepository")
    private let networkClient: NetworkClient
    private let configuration: APIConfiguration
    
    private var cachedTickers: [TickerDTO]?
    
    init(networkClient: NetworkClient, configuration: APIConfiguration = .production) {
        self.networkClient = networkClient
        self.configuration = configuration
    }
    
    func getRate(from: Currency, to: Currency) async throws -> ExchangeRateResult {
        
        if from == to {
            return ExchangeRateResult(
                rate: ExchangeRate(
                    fromCurrency: from,
                    toCurrency: to,
                    value: 1
                ),
                source: .identity
            )
        }
        
        let result = try await loadTickers()
        let tickers = result.tickers
        
        guard let ticker = tickers.first(where: {
            $0.book.lowercased() == "usdc_\(from.code == "USDc" ? to.code : from.code)".lowercased()
        }) else {
            throw ExchangeRatesError.unsupportedCurrencyPair
        }
        
        let rate: Decimal
        
        if from.code == "USDc" {
            guard let bid = ticker.bidDecimal, bid > 0 else {
                throw ExchangeRatesError.invalidRate
            }
            rate = bid
        } else if to.code == "USDc" {
            guard let ask = ticker.askDecimal, ask > 0 else {
                throw ExchangeRatesError.invalidRate
            }
            rate = 1 / ask
        } else {
            throw ExchangeRatesError.unsupportedCurrencyPair
        }
        
        return ExchangeRateResult(
            rate: ExchangeRate(
                fromCurrency: from,
                toCurrency: to,
                value: rate
            ),
            source: result.source
        )
    }
    
    private struct TickersResult {
        let tickers: [TickerDTO]
        let source: ExchangeRateSource
    }
    
    private func loadTickers() async throws -> TickersResult {
        let url = try configuration.url(for: .tickers)
        
        do {
            let tickers = try await networkClient.get(from: url, as: [TickerDTO].self)
            
            guard !tickers.isEmpty else {
                throw ExchangeRatesError.emptyResponse
            }
            
            try Task.checkCancellation()
            cachedTickers = tickers
            
            return TickersResult(
                tickers: tickers,
                source: .live
            )
            
        } catch {
            try Task.checkCancellation()
            if error is CancellationError ||
                (error as? URLError)?.code == .cancelled {
                throw CancellationError()
            }
            logger.warning("Ticker request failed: \(String(describing: error), privacy: .public)")
            if let cachedTickers {
                logger.info("Using cached exchange rates")
                return TickersResult(
                    tickers: cachedTickers,
                    source: .cached
                )
            }
            
            logger.info("Trying bundled fallback exchange rates")
            let fallbackTickers = try loadFallbackTickers()
            
            return TickersResult(
                tickers: fallbackTickers,
                source: .fallback
            )
        }
    }
    
    private func loadFallbackTickers() throws -> [TickerDTO] {
        guard let url = Bundle.main.url(forResource: "tickers_fallback", withExtension: "json") else {
            throw ExchangeRatesError.fallbackUnavailable
        }
        
        let data = try Data(contentsOf: url)
        
        return try JSONDecoder().decode(
            [TickerDTO].self,
            from: data
        )
    }
}
