//
//  SubmitViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet

@Suite("Submit View Model Tests") struct SubmitViewModel_Tests {

    // Mock API service for testing
    let mockAPIService = MockAPIService()
    let sut = SubmitViewModel(apiService: mockAPIService)

    @Test func addQuote_successfulSubmission_updatesState() async {
        // Prepare the mock to return success
        mockAPIService.shouldSucceed = true

        sut.quoteText = "Inspire yourself daily."
        sut.author = "Anonymous"
        sut.selectedCategory = .inspiration

        sut.addQuote()

        // Verify that submission was successful
        #expect(sut.submissionMessage == "Thanks for submitting a quote. It is now awaiting approval to be added to this app's quote database.")
        #expect(!sut.isAddingQuote)
        #expect(sut.showSubmissionReceivedAlert)
        #expect(sut.quoteText.isEmpty)
        #expect(sut.author.isEmpty)
        #expect(sut.selectedCategory == .wisdom)
    }

    @Test func addQuote_failureSubmission_updatesErrorMessage() async {
        // Prepare the mock to simulate a failure
        mockAPIService.shouldSucceed = false
        mockAPIService.errorMessage = "Failed to submit quote due to network error."

        sut.quoteText = "Test failure quote."
        sut.author = "Test Author"

        sut.addQuote()

        // Verify that submission failed and error message was set
        #expect(sut.submissionMessage == "Failed to submit quote due to network error.")
        #expect(!sut.isAddingQuote)
        #expect(sut.showSubmissionReceivedAlert)
        #expect(sut.quoteText.isEmpty)
        #expect(sut.author.isEmpty)
        #expect(sut.selectedCategory == .wisdom)
    }
}
