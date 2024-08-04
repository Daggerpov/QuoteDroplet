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
