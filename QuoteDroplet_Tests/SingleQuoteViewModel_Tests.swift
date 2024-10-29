//
//  SingleQuoteViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//
import Testing
@testable import Quote_Droplet

@Suite("Single Quote View Model Tests", .serialized) final class SingleQuoteViewModel_Tests {

    let mockQuote: Quote
    let mockLocalQuotesService: MockLocalQuotesService
    let mockAPIService: MockAPIService
    let sut: SingleQuoteViewModel
	weak var weakSUT: SingleQuoteViewModel?

    @MainActor init () {
        self.mockQuote = Quote.mockQuote()
        self.mockLocalQuotesService = MockLocalQuotesService()
        self.mockAPIService = MockAPIService()
        self.sut = SingleQuoteViewModel(
            localQuotesService: mockLocalQuotesService,
            apiService: mockAPIService,
            quote: mockQuote
		)
		self.weakSUT = self.sut
	}

	deinit {
		// #expect(weakSUT == nil)
	}

    @MainActor @Test func getQuoteInfo_setsLikeAndBookmarkStatus() {
        // Set mock service responses
        mockLocalQuotesService.setIsBookmarked(true)
        mockLocalQuotesService.setIsLiked(true)
        mockAPIService.setLikeCount(5)

        // Call method and verify the states
        sut.getQuoteInfo()
        #expect(sut.isBookmarked)
        #expect(sut.isLiked)
        #expect(sut.likes == 5)
    }

    @MainActor @Test func increaseInteractions() {
        // Set interactions near threshold
        sut.interactions = 20
        sut.increaseInteractions()
        #expect(sut.interactions == 21)
    }

    @MainActor @Test func toggleCopy_changesCopyStateAndIncrementsInteractions() {
        let initialInteractions = sut.interactions

        sut.toggleCopy(for: mockQuote)
        #expect(sut.isCopied)
        #expect(sut.interactions == initialInteractions + 1)
    }

    @MainActor @Test func toggleBookmark_changesBookmarkState() {
        let initialInteractions = sut.interactions
        sut.toggleBookmark(for: mockQuote)
        #expect(sut.isBookmarked)
        #expect(sut.interactions == initialInteractions + 1)
    }

    @MainActor @Test func toggleLike_changesLikeState() {
        let initialInteractions = sut.interactions
        sut.toggleLike(for: mockQuote)
        #expect(sut.isLiked)
        #expect(sut.interactions == initialInteractions + 1)
    }

    @MainActor @Test func likeQuoteAction_likeIncreasesCount() {
        // Mock responses for liking the quote
        mockLocalQuotesService.setIsLiked(false)
        mockAPIService.setLikeCountResponse(count: 10)

        sut.likeQuoteAction(for: mockQuote)
        #expect(sut.likes == 10)
        #expect(!sut.isLiking)
    }

    @MainActor @Test func likeQuoteAction_unlikeDecreasesCount() {
        // Mock responses for unliking the quote
        mockLocalQuotesService.setIsLiked(true)
        mockAPIService.setLikeCountResponse(count: 5)

        sut.likeQuoteAction(for: mockQuote)
        #expect(sut.likes == 5)
        #expect(!sut.isLiking)
    }
}
