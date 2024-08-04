//
//  BookmarkHelper.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-20.
//

import Foundation
import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

func getBookmarkedQuotes() -> [Quote] {
    @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    var bookmarkedQuotesData: Data = Data()
    if let quotes = try? JSONDecoder().decode([Quote].self, from: bookmarkedQuotesData) {
        return quotes
    }
    return []
}

func saveBookmarkedQuote(quote: Quote, isBookmarked: Bool) {
    
    var bookmarkedQuotes = getBookmarkedQuotes()
    
    if isBookmarked {
        bookmarkedQuotes.append(quote)
    } else {
        bookmarkedQuotes.removeAll { $0.id == quote.id }
    }
    
    @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    var bookmarkedQuotesData: Data = Data()
    if let data = try? JSONEncoder().encode(bookmarkedQuotes) {
        bookmarkedQuotesData = data
    }
}
