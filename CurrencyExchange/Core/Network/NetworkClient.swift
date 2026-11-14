//
//  NetworkClient.swift
//  CurrencyExchange
//
//  Created by Andrew on 21.10.2026.
//

import Foundation

protocol NetworkClient {
    func get<T: Decodable>(from url: URL, as type: T.Type) async throws -> T
}
