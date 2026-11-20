//
//  L10n.swift
//  CurrencyExchange
//
//  Created by Andrew on 17.11.2026.
//

import Foundation

enum L10n {
    enum Error {
        static let loadRate = String(
            localized: "exchange.error.load_rate"
        )

        static let selectCurrency = String(
            localized: "exchange.error.select_currency"
        )

        static let swapCurrencies = String(
            localized: "exchange.error.swap_currencies"
        )
    }

    enum Rate {
        static let notLoaded = String(
            localized: "exchange.rate.not_loaded"
        )

        static let loading = String(
            localized: "exchange.rate.loading"
        )

        static let live = String(
            localized: "exchange.rate.live"
        )

        static let cached = String(
            localized: "exchange.rate.cached"
        )

        static let fallback = String(
            localized: "exchange.rate.fallback"
        )

        static let identity = String(
            localized: "exchange.rate.identity"
        )
    }
}
