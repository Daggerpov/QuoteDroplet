//
//  DataService.swift
//  QuoteDropletWidgetExtension
//
//  Created by Daniel Agapov on 2023-08-31.
//

import Foundation
import SwiftUI

struct DataService {
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"

    func getColorPalette() -> [Color] {
        return [
            widgetCustomColorPaletteFirstIndex,
            widgetCustomColorPaletteSecondIndex,
            widgetCustomColorPaletteThirdIndex
        ].map { Color(hex: $0) }
    }
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetColorPaletteIndex = 0
    
    func getIndex() -> Int {
        return widgetColorPaletteIndex
    }
    
    @AppStorage("quoteFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var quoteFrequencyIndex = 3
    
    func getQuoteFrequencyIndex() -> Int {
        return quoteFrequencyIndex
    }
    
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var quoteCategory = "all"
    
    func getQuoteCategory() -> String {
        return quoteCategory
    }
    
    // Add @AppStorage property for selectedFontIndex
    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0
    
    // bookmark:
    
    @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var bookmarkedQuotesData: Data = Data()
    
    var bookmarkedQuotes: [Quote] {
        get {
            if let quotes = try? JSONDecoder().decode([Quote].self, from: bookmarkedQuotesData) {
                return quotes
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                bookmarkedQuotesData = data
            }
        }
    }
    
    func addBookmark(_ quote: Quote) {
        var quotes = bookmarkedQuotes
        if !quotes.contains(where: { $0.id == quote.id }) {
            quotes.append(quote)
            bookmarkedQuotes = quotes
        }
    }
    
    func removeBookmark(_ quote: Quote) {
        var quotes = bookmarkedQuotes
        quotes.removeAll { $0.id == quote.id }
        bookmarkedQuotes = quotes
    }
    
    func isBookmarked(_ quote: Quote) -> Bool {
        return bookmarkedQuotes.contains(where: { $0.id == quote.id })
    }
}
