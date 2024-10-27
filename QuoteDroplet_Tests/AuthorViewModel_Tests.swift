//
//  AuthorViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet

@Suite("Author View Model Tests") struct AuthorViewModel_Tests {
    let mockQuote = Quote.mockQuote()
    let sut: AuthorViewModel = AuthorViewModel(
        quote: mockQuote,
        localQuotesService: MockLocalQuotesService(),
        apiService: MockAPIService()
    )

    @Test func initialization() {
        // Test initial values
        #expect(sut.quotes.isEmpty)
        #expect(sut.isLoadingMore == false)
        #expect(sut.totalQuotesLoaded == 0)
    }

    @Test func loadInitialQuotes() async {
        // Test initial loading of quotes
        #expect(sut.quotes.isEmpty)
        sut.loadInitialQuotes()

        // Wait for async loading to complete
        #expect(sut.quotes.count > 0)
        #expect(sut.quotes.count <= AuthorViewModel.quotesPerPage)
        #expect(sut.totalQuotesLoaded == AuthorViewModel.quotesPerPage)
    }

    @Test func loadMoreQuotes() async {
        // Initial setup
        sut.quotes = [Quote](repeating: Quote.mockQuote(), count: AuthorViewModel.quotesPerPage)
        sut.totalQuotesLoaded = AuthorViewModel.quotesPerPage

        // Trigger load more quotes
        sut.loadMoreQuotes()

        // Verify additional quotes loaded
        #expect(sut.quotes.count > AuthorViewModel.quotesPerPage)
        #expect(sut.quotes.count <= AuthorViewModel.maxQuotes)
    }

    @Test func loadMoreQuotes_limitReached() async {
        // Set quotes to max limit to simulate reaching the limit
        sut.quotes = [Quote](repeating: Quote.mockQuote(), count: AuthorViewModel.maxQuotes)
        sut.totalQuotesLoaded = AuthorViewModel.maxQuotes

        // Trigger load more quotes
        sut.loadMoreQuotes()

        // Expect no additional quotes to be loaded beyond maxQuotes
        #expect(sut.quotes.count == AuthorViewModel.maxQuotes)
        #expect(sut.isLoadingMore == false)
    }

    @Test func loadRemoteJSON_success() async {
        let urlString = "https://example.com/success.json" // replace with a mock URL or API call
        sut.loadRemoteJSON(urlString) { (result: [Quote]) in
            #expect(result.count > 0)
        }
    }

    @Test func loadRemoteJSON_failure() async {
        let urlString = "invalid_url"
        sut.loadRemoteJSON(urlString) { (_: [Quote]) in
            #expect(false, "Expected failure due to invalid URL")
        }
    }
}
