//
//  TickerDTO.swift
//  CurrencyExchange
//
//  Created by Andrew on 22.10.2026.
//

import Foundation

struct TickerDTO: Decodable {
    let ask: String
    let bid: String
    let book: String
    let date: String
    
    var askDecimal: Decimal? {
        Decimal(
            string: ask,
            locale: Locale(identifier: "en_US_POSIX")
        )
    }
    
    var bidDecimal: Decimal? {
        Decimal(
            string: bid,
            locale: Locale(identifier: "en_US_POSIX")
        )
    }
}
