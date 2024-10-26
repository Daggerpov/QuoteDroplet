//
//  QuoteCategory.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

enum QuoteCategory: String, CaseIterable {
    case all = "All"
    case wisdom = "Wisdom"
    case motivation = "Motivation"
    case discipline = "Discipline"
    case philosophy = "Philosophy"
    case inspiration = "Inspiration"
    case upliftment = "Upliftment"
    case love = "Love"
    case bookmarkedQuotes = "Saved"
    var displayName: String {
        return self.rawValue
    }
    var lowercasedName: String {
        return self.rawValue.lowercased()
    }
}
