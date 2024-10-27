//
//  SearchViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet
import Foundation

@Suite("Search View Model Tests")
struct SearchViewModel_Tests {
    let mockAPIService: MockAPIService
    let sut: SearchViewModel

    init() {
        self.mockAPIService = MockAPIService()
        self.sut = SearchViewModel(
            localQuotesService: MockLocalQuotesService(),
            apiService: mockAPIService
        )
    }

    @Test
    func loadQuotesBySearch_successfulFetch_updatesQuotesList() async {
        let mockQuotes = [Quote.mockQuote(), Quote.mockQuote(), Quote.mockQuote()]
        mockAPIService.setQuotesBySearchResponse(quotes: mockQuotes, error: nil)
        sut.searchText = "inspiration"
        sut.activeCategory = .inspiration
        sut.loadQuotesBySearch()
        #expect(sut.quotes.count == min(SearchViewModel.quotesPerPage, mockQuotes.count))
    }

    @Test
    func loadQuotesBySearch_emptyResponse_showsNoQuotes() async {
        mockAPIService.setQuotesBySearchResponse(quotes: [], error: nil)
        sut.searchText = "unknown"
        sut.activeCategory = .all
        sut.loadQuotesBySearch()
        #expect(sut.quotes.isEmpty)
    }

    @Test
    func loadQuotesBySearch_errorResponse_displaysError() async {
        let errorMessage = "Network error occurred"
        mockAPIService.setQuotesBySearchResponse(quotes: nil, error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        sut.searchText = "error"
        sut.activeCategory = .all
        sut.loadQuotesBySearch()
        #expect(sut.quotes.isEmpty)
    }
}
