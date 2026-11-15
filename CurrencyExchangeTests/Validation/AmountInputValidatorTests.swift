//
//  AmountInputValidatorTests.swift
//  CurrencyExchangeTests
//
//  Created by Andrew on 15.11.2026.
//

import XCTest
@testable import CurrencyExchange

final class AmountInputValidatorTests: XCTestCase {
    
    func testCommaAndDotAreAcceptedAndParsedEqually() {
        XCTAssertTrue(AmountInputValidator.isValid("12,345"))
        XCTAssertTrue(AmountInputValidator.isValid("12.345"))
        XCTAssertEqual(AmountInputValidator.parse("12,345"), Decimal(string: "12.345"))
        XCTAssertEqual(AmountInputValidator.parse("12.345"), Decimal(string: "12.345"))
    }
    
    func testMaximumIntegerDigitsAreAccepted() {
        XCTAssertTrue(AmountInputValidator.isValid(String(repeating: "9", count: 12)))
    }
    
    func testIntegerDigitLimitIsEnforced() {
        let input = String(repeating: "9", count: 13)
        XCTAssertFalse(AmountInputValidator.isValid(input))
        XCTAssertNil(AmountInputValidator.parse(input))
    }
    
    func testMaximumFractionDigitsAreAccepted() {
        XCTAssertTrue(AmountInputValidator.isValid("1.123456"))
    }
    
    func testFractionDigitLimitIsEnforced() {
        XCTAssertFalse(AmountInputValidator.isValid("1.1234567"))
        XCTAssertNil(AmountInputValidator.parse("1.1234567"))
    }
    
    func testMultipleDecimalSeparatorsAreRejected() {
        for input in ["1.2.3", "1,2,3", "1,2.3", "1.2,3"] {
            XCTAssertFalse(AmountInputValidator.isValid(input), "Expected invalid: \(input)")
            XCTAssertNil(AmountInputValidator.parse(input), "Expected nil: \(input)")
        }
    }
    
    func testSingleSeparatorIsAcceptedAsZero() {
        XCTAssertTrue(AmountInputValidator.isValid("."))
        XCTAssertEqual(AmountInputValidator.parse("."), Decimal(0))
        XCTAssertTrue(AmountInputValidator.isValid(","))
        XCTAssertEqual(AmountInputValidator.parse(","), Decimal(0))
    }
    
    func testEmptyStringIsAcceptedAsZero() {
        XCTAssertTrue(AmountInputValidator.isValid(""))
        XCTAssertEqual(AmountInputValidator.parse(""), Decimal(0))
    }
    
    func testNonASCIIDigitsAreRejected() {
        for input in ["١٢٣", "１２３", "१२३"] {
            XCTAssertFalse(AmountInputValidator.isValid(input), "Expected invalid: \(input)")
            XCTAssertNil(AmountInputValidator.parse(input), "Expected nil: \(input)")
        }
    }
}
