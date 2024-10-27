//
//  CommunityViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet

@Suite("Community View Model Tests") struct CommunityViewModel_Tests {

    let sut = CommunityViewModel(
        localQuotesService: MockLocalQuotesService(),
        apiService: MockAPIService()
    )

    @Test func getRecentQuotes_success() async throws {
        // Set up the mock API service to return a successful response
        sut.apiService.setRecentQuotesResponse(
            quotes: [Quote.mockQuote(), Quote.mockQuote(), Quote.mockQuote()],
            error: nil
        )

        // Call the method to test
        sut.getRecentQuotes()

        // Verify quotes are correctly loaded
        #expect(sut.recentQuotes.count == 3)
        #expect(sut.recentQuotes[0].text == "Courage isn't having the strength to go on—it is going on when you don't have strength.")
    }

    @Test func getRecentQuotes_failure() async throws {
        // Set up the mock API service to return an error
        let mockError = NSError(domain: "TestError", code: 404, userInfo: nil)
        sut.apiService.setRecentQuotesResponse(quotes: nil, error: mockError)

        // Call the method to test
        sut.getRecentQuotes()

        // Since quotes are not loaded, recentQuotes should remain empty
        #expect(sut.recentQuotes.isEmpty)
        // You may also check for specific log output or error handling as required
    }
}
