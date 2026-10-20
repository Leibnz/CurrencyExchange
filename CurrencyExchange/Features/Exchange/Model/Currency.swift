//
//  Currency.swift
//  CurrencyExchange
//
//  Created by Andrew on 18.10.2026.
//

import Foundation

struct Currency: Identifiable, Equatable {
    let code: String
    let name: String
    let flag: String
    
    var id: String { code }
}

extension Currency {
    static let usdc = Currency(
        code: "USDc",
        name: "US Dollar",
        flag: "🇺🇸"
    )
    
    static let mxn = Currency(
        code: "MXN",
        name: "Mexican Peso",
        flag: "🇲🇽"
    )
}
