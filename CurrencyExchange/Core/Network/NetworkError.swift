//
//  NetworkError.swift
//  CurrencyExchange
//
//  Created by Andrew on 21.10.2026.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
    case transport(Error)
}
