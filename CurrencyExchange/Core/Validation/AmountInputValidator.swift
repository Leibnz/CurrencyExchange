//
//  AmountInputValidator.swift
//  CurrencyExchange
//
//  Created by Andrew on 06.11.2026.
//

import Foundation

enum AmountInputValidator {
    static let maxIntegerDigits = 12
    static let maxFractionDigits = 6

    static func isValid(_ text: String) -> Bool {
        let normalized = text.replacingOccurrences(
            of: ",",
            with: "."
        )

        guard normalized.allSatisfy({
            $0.isASCII && ($0.isNumber || $0 == ".")
        }) else {
            return false
        }

        let components = normalized.split(
            separator: ".",
            omittingEmptySubsequences: false
        )

        guard components.count <= 2 else {
            return false
        }

        let integerPart = components[0]

        guard integerPart.count <= maxIntegerDigits else {
            return false
        }

        if components.count == 2 {
            guard components[1].count <= maxFractionDigits else {
                return false
            }
        }

        return true
    }

    static func parse(_ text: String) -> Decimal? {
        guard isValid(text) else {
            return nil
        }

        let normalized = text.replacingOccurrences(
            of: ",",
            with: "."
        )

        if normalized.isEmpty || normalized == "." {
            return 0
        }

        return Decimal(
            string: normalized,
            locale: Locale(identifier: "en_US_POSIX")
        )
    }
}
