//
//  MockAPIService.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-26.
//

class MockAPIService: IAPIService {
    // TODO: maybe use completion handlers to mock quotes/errors being returned?

    func getRandomQuoteByClassification(
        classification: String,
        completion: @escaping (Quote?, (any Error)?) -> Void,
        isShortQuoteDesired: Bool
    ) {
        return
    }

    func getQuotesByAuthor(
        author: String,
        completion: @escaping ([Quote]?, (any Error)?) -> Void
    ) {
        return
    }

    func getQuotesBySearchKeyword(
        searchKeyword: String,
        searchCategory: String,
        completion: @escaping ([Quote]?, (any Error)?) -> Void
    ) {
        return
    }

    func getRecentQuotes(
        limit: Int,
        completion: @escaping ([Quote]?, (any Error)?) -> Void
    ) {
        return
    }

    func addQuote(
        text: String,
        author: String?,
        classification: String,
        completion: @escaping (Bool, (any Error)?) -> Void
    ) {
        return
    }

    func likeQuote(
        quoteID: Int,
        completion: @escaping (Quote?, (any Error)?) -> Void
    ) {
        return
    }

    func unlikeQuote(
        quoteID: Int,
        completion: @escaping (Quote?, (any Error)?) -> Void
    ) {
        return
    }

    func getQuoteByID(
        id: Int,
        completion: @escaping (Quote?, (any Error)?) -> Void
    ) {
        return
    }

    func getLikeCountForQuote(
        quoteGiven: Quote,
        completion: @escaping (Int) -> Void
    ) {
        return
    }

    func getCountForCategory(
        category: QuoteCategory,
        completion: @escaping (Int) -> Void
    ) {
        return
    }

    
}
