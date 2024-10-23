//
//  JSONHelper.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-20.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

func loadQuotesFromJSON() -> [QuoteJSON] {
    // Load quotes from JSON file
    guard let path = Bundle.main.path(forResource: "QuotesBackup", ofType: "json") else {
        print("Error: Unable to locate quotes.json")
        return []
    }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        return try decoder.decode([QuoteJSON].self, from: data) // quotes
    } catch {
        print("Error decoding quotes JSON: \(error.localizedDescription)")
    }
    return []
}

func isQuoteLiked(_ quote: Quote) -> Bool {
    return getLikedQuotes().contains(where: { $0.id == quote.id })
}

func isQuoteBookmarked(_ quote: Quote) -> Bool {
    return getBookmarkedQuotes().contains(where: { $0.id == quote.id })
}
