//
//  CommunityViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet
import Foundation

@Suite("Community View Model Tests", .serialized) final class CommunityViewModel_Tests {

    let mockAPIService: MockAPIService
    let sut: CommunityViewModel
	weak var weakSUT: CommunityViewModel?

    init() {
        self.mockAPIService = MockAPIService()
		self.sut = CommunityViewModel(localQuotesService: MockLocalQuotesService(), apiService: mockAPIService)
		self.weakSUT = self.sut
	}

	deinit {
		// #expect(weakSUT == nil)
	}

    @Test func getRecentQuotes_success() async throws {
        let firstMockQuote: Quote = Quote.mockQuote()
        let mockQuotes = [
            firstMockQuote,
            Quote.mockQuote(),
            Quote.mockQuote()
        ]

        mockAPIService.setRecentQuotesResponse(quotes: mockQuotes, error: nil)

        sut.getRecentQuotes()

        #expect(sut.recentQuotes.count == 3)
        #expect(sut.recentQuotes.contains(firstMockQuote))
    }

    @Test func getRecentQuotes_failure() async throws {
        let mockError = NSError(domain: "TestError", code: 404, userInfo: nil)
        mockAPIService.setRecentQuotesResponse(quotes: nil, error: mockError)

        sut.getRecentQuotes()

        #expect(sut.recentQuotes.isEmpty)
    }
}
