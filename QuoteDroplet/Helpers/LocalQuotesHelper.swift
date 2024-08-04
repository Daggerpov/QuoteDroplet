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

func getLikedQuotes() -> [Quote] {
    @AppStorage("likedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    var likedQuotesData: Data = Data()
    if let quotes = try? JSONDecoder().decode([Quote].self, from: likedQuotesData) {
        return quotes
    }
    return []
}

func saveLikedQuote(quote: Quote, isLiked: Bool) {
    var likedQuotes = getLikedQuotes()
    
    if isLiked {
        likedQuotes.append(quote)
    } else {
        likedQuotes.removeAll { $0.id == quote.id }
    }
    
    @AppStorage("likedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    var likedQuotesData: Data = Data()
    if let data = try? JSONEncoder().encode(likedQuotes) {
        likedQuotesData = data
    }
}

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


func getRecentQuotes() -> [Quote] {
    @AppStorage("recentQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    var recentQuotesData: Data = Data()
    if let quotes = try? JSONDecoder().decode([Quote].self, from: recentQuotesData) {
        return quotes
    }
    return []
}

func saveRecentQuote(quote: Quote) {
    var recentQuotes = getRecentQuotes()
    
    recentQuotes.append(quote)
    
    @AppStorage("recentQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
   var recentQuotesData: Data = Data()
    if let data = try? JSONEncoder().encode(recentQuotes) {
        recentQuotesData = data
    }
}
