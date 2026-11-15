//
//  URLSessionNetworkClientTests.swift
//  CurrencyExchangeTests
//
//  Created by Andrew on 15.11.2026.
//

import XCTest
@testable import CurrencyExchange

final class URLSessionNetworkClientTests: XCTestCase {
    private struct TestPayload: Decodable {
        let value: Int
    }

    private func makeClient() -> (URLSessionNetworkClient, URLSession) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return (URLSessionNetworkClient(session: session), session)
    }

    private func makeURL() -> URL {
        URL(string: "https://example.test/\(UUID().uuidString)")!
    }

    func testHTTP500ThrowsHTTPError() async {
        let url = makeURL()
        URLProtocolStub.register(.response(statusCode: 500, data: Data()), for: url)
        defer { URLProtocolStub.removeStub(for: url) }
        let (client, session) = makeClient()
        defer { session.invalidateAndCancel() }

        do {
            let _: TestPayload = try await client.get(from: url, as: TestPayload.self)
            XCTFail("Expected HTTP 500 error")
        } catch NetworkError.httpError(statusCode: let statusCode) {
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("Expected httpError(500), got \(error)")
        }
    }

    func testInvalidJSONThrowsDecodingFailed() async {
        let url = makeURL()
        URLProtocolStub.register(
            .response(statusCode: 200, data: Data("{not-json".utf8)),
            for: url
        )
        defer { URLProtocolStub.removeStub(for: url) }
        let (client, session) = makeClient()
        defer { session.invalidateAndCancel() }

        do {
            let _: TestPayload = try await client.get(from: url, as: TestPayload.self)
            XCTFail("Expected decoding error")
        } catch NetworkError.decodingFailed {
        } catch {
            XCTFail("Expected decodingFailed, got \(error)")
        }
    }

    func testTransportFailureIsWrapped() async {
        let url = makeURL()
        URLProtocolStub.register(.failure(URLError(.notConnectedToInternet)), for: url)
        defer { URLProtocolStub.removeStub(for: url) }
        let (client, session) = makeClient()
        defer { session.invalidateAndCancel() }

        do {
            let _: TestPayload = try await client.get(from: url, as: TestPayload.self)
            XCTFail("Expected transport error")
        } catch NetworkError.transport(let underlyingError) {
            let urlError = underlyingError as? URLError
            XCTAssertEqual(urlError?.code, .notConnectedToInternet)
        } catch {
            XCTFail("Expected transport error, got \(error)")
        }
    }
}
