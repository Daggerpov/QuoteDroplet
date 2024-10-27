//
//  DropletsViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//
import Testing

@Suite("Droplets View Model Tests") struct DropletsViewModel_Tests {

    let sut: DropletsViewModel = DropletsViewModel(localQuotesService: MockLocalQuoteService)

    @Test func getRecentQuotes_success() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
    }

    @Test("asdf") func getRecentQuotes_failure() async throws {

    }

}
