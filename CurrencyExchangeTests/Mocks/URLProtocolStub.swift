//
//  URLProtocolStub.swift
//  CurrencyExchangeTests
//
//  Created by Andrew on 15.11.2026.
//

import Foundation

final class URLProtocolStub: URLProtocol {
    enum Stub {
        case response(statusCode: Int, data: Data)
        case failure(URLError)
    }

    private static let lock = NSLock()
    private static var stubs: [String: Stub] = [:]

    static func register(_ stub: Stub, for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        stubs[url.absoluteString] = stub
    }

    static func removeStub(for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        stubs.removeValue(forKey: url.absoluteString)
    }

    private static func stub(for url: URL) -> Stub? {
        lock.lock()
        defer { lock.unlock() }
        return stubs[url.absoluteString]
    }

    override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == "example.test"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url, let stub = Self.stub(for: url) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        switch stub {
        case let .response(statusCode, data):
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            ) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)

        case let .failure(error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
