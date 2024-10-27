//
//  DropletsViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//
import Testing
@testable import Quote_Droplet

@Suite("Droplets View Model Tests") struct DropletsViewModel_Tests {

    let sut: DropletsViewModel = DropletsViewModel(localQuotesService: MockLocalQuotesService(), apiService: MockAPIService())

    @Test func setSelected() {
        #expect(sut.selected == SelectedPage.feed)
        sut.setSelected(newValue: SelectedPage.recent)
        #expect(sut.selected == SelectedPage.recent)
        sut.setSelected(newValue: SelectedPage.saved)
        #expect(sut.selected == SelectedPage.saved)
    }

    @Test func getTitleText() {
        sut.setSelected(newValue: SelectedPage.feed)
        #expect(sut.getTitleText() == "Quotes Feed")
        sut.setSelected(newValue: SelectedPage.saved)
        #expect(sut.getTitleText() == "Saved Quotes")
        sut.setSelected(newValue: SelectedPage.recent)
        #expect(sut.getTitleText() == "Recent Quotes")
    }

    // will work once I mock APIService
    @Test func loadInitialQuotes() async {
        // Initially, `quotes`, `savedQuotes`, and `recentQuotes` should be empty
        #expect(sut.quotes.isEmpty)
        #expect(sut.savedQuotes.isEmpty)
        #expect(sut.recentQuotes.isEmpty)

        // Trigger initial load
        sut.loadInitialQuotes()

        // Verify that quotes are loaded
        #expect(sut.quotes.count > 0)
        #expect(sut.quotes.count <= sut.quotesPerPage)
    }

    @Test func checkMoreQuotesNeeded() async {
        // Ensure quotes are under the max limit initially
        sut.quotes = [Quote](repeating: Quote.mockQuote(), count: sut.maxQuotes - 1)
        #expect(!sut.checkLimitReached())

        // Trigger check
        sut.checkMoreQuotesNeeded()

        // Verify that quotes were incremented
        #expect(sut.quotes.count > 0)
        #expect(sut.quotes.count <= sut.maxQuotes)
    }

    @Test func getPageSpecificQuotes_feed() {
        sut.setSelected(newValue: .feed)
        sut.quotes = [Quote.mockQuote(), Quote.mockQuote()]

        #expect(sut.getPageSpecificQuotes().count == sut.quotes.count)
    }

    @Test func getPageSpecificQuotes_saved() {
        sut.setSelected(newValue: .saved)
        sut.savedQuotes = [Quote.mockQuote(), Quote.mockQuote()]

        #expect(sut.getPageSpecificQuotes().count == sut.savedQuotes.count)
    }

    @Test func checkLimitReached() {
        sut.setSelected(newValue: .feed)
        sut.quotes = [Quote](repeating: Quote.mockQuote(), count: sut.maxQuotes)

        #expect(sut.checkLimitReached())
    }

    @Test func getPageSpecificEmptyText() {
        sut.setSelected(newValue: .saved)
        let emptyText = sut.getPageSpecificEmptyText()

        #expect(emptyText == "You have no saved quotes. \n\nPlease save some from the Quotes Feed by pressing this:")
    }
}
