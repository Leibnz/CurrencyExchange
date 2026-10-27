//
//  DefaultExchangeRatesRepository.swift
//  CurrencyExchange
//
//  Created by Andrew on 22.10.2026.
//

import Foundation

enum ExchangeRatesError: Error {
    case unsupportedCurrencyPair
    case invalidRate
    case emptyResponse
    case fallbackUnavailable
}

@MainActor
final class DefaultExchangeRatesRepository: ExchangeRatesRepository {
    
    private let networkClient: NetworkClient
    private var cachedTickers: [TickerDTO]?
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func getRate(from: Currency, to: Currency) async throws -> ExchangeRate {
        
        if from == to {
            return ExchangeRate(
                fromCurrency: from,
                toCurrency: to,
                value: 1
            )
        }
        
        let tickers = try await loadTickers()
        
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
        
        return ExchangeRate(
            fromCurrency: from,
            toCurrency: to,
            value: rate
        )
    }
    
    private func loadTickers() async throws -> [TickerDTO] {
        do {
            let url = URL(string: "https://api.dolarapp.dev/v1/tickers?currencies=MXN,ARS")!
            
            let tickers = try await networkClient.get(from: url, as: [TickerDTO].self)
            
            guard !tickers.isEmpty else {
                throw ExchangeRatesError.emptyResponse
            }
            
            cachedTickers = tickers
            return tickers
            
        } catch {
            if let cachedTickers {
                return cachedTickers
            }
            
            return try loadFallbackTickers()
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
