//
//  MockLocalQuoteService.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-26.
//

class MockLocalQuotesService: ILocalQuotesService {


    func getLikedQuotes() -> [Quote] {
        return [Quote.mockQuote(), Quote.mockQuote()]
    }

    func saveLikedQuote(quote: Quote, isLiked: Bool) -> Void {
        return
    }

    func getBookmarkedQuotes() -> [Quote] {
        return [Quote.mockQuote(), Quote.mockQuote()]
    }

    func saveBookmarkedQuote(quote: Quote, isBookmarked: Bool) -> Void {
        return
    }

    func getRecentLocalQuotes() -> [Quote] {
        return [Quote.mockQuote(), Quote.mockQuote()]
    }

    func saveRecentQuote(quote: Quote) -> Void {
        return
    }

    func loadQuotesFromJSON() -> [QuoteJSON] {
        return [QuoteJSON.mockQuote()]
    }

    func isQuoteLiked(_ quote: Quote) -> Bool {
        return true
    }

    func isQuoteBookmarked(_ quote: Quote) -> Bool {
        return true
    }
}