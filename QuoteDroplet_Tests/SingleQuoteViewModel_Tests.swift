//
//  SingleQuoteViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet

@Suite("Single Quote View Model Tests") struct SingleQuoteViewModel_Tests {

    // Mock services for testing
    let mockLocalQuotesService = MockLocalQuotesService()
    let mockAPIService = MockAPIService()
    let sampleQuote = Quote(id: "1", text: "Sample Quote", author: "Author")

    // Create a new instance of the ViewModel
    let sut = SingleQuoteViewModel(localQuotesService: mockLocalQuotesService, apiService: mockAPIService, quote: sampleQuote)

    @Test func shouldShowArrow_nonAuthorView() {
        sut.from = .standardView
        #expect(sut.shouldShowArrow())
    }

    @Test func shouldShowArrow_authorView() {
        sut.from = .authorView
        #expect(!sut.shouldShowArrow())
    }

    @Test func getQuoteInfo_setsLikeAndBookmarkStatus() {
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

    @Test func increaseInteractions_requestsReviewOnThreshold() {
        // Set interactions near threshold
        sut.interactions = 20
        var didRequestReview = false
        sut.requestReview = { didRequestReview = true }

        sut.increaseInteractions()
        #expect(didRequestReview)
        #expect(sut.interactions == 21)
    }

    @Test func toggleCopy_changesCopyStateAndIncrementsInteractions() {
        let initialInteractions = sut.interactions

        sut.toggleCopy(for: sampleQuote)
        #expect(sut.isCopied)
        #expect(sut.interactions == initialInteractions + 1)
    }

    @Test func toggleBookmark_changesBookmarkState() {
        let initialInteractions = sut.interactions
        sut.toggleBookmark(for: sampleQuote)
        #expect(sut.isBookmarked)
        #expect(sut.interactions == initialInteractions + 1)
    }

    @Test func toggleLike_changesLikeState() {
        let initialInteractions = sut.interactions
        sut.toggleLike(for: sampleQuote)
        #expect(sut.isLiked)
        #expect(sut.interactions == initialInteractions + 1)
    }

    @Test func likeQuoteAction_likeIncreasesCount() {
        // Mock responses for liking the quote
        mockLocalQuotesService.setIsLiked(false)
        mockAPIService.setLikeResponse(likes: 10)

        sut.likeQuoteAction(for: sampleQuote)
        #expect(sut.likes == 10)
        #expect(!sut.isLiking)
    }

    @Test func likeQuoteAction_unlikeDecreasesCount() {
        // Mock responses for unliking the quote
        mockLocalQuotesService.setIsLiked(true)
        mockAPIService.setUnlikeResponse(likes: 5)

        sut.likeQuoteAction(for: sampleQuote)
        #expect(sut.likes == 5)
        #expect(!sut.isLiking)
    }
}
