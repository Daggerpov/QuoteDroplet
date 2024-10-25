//
//  QuoteJSON.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

struct QuoteJSON: Codable {
    let id: Int
    var text: String
    var author: String
    let classification: String
}

extension Quote {
    func toQuoteJSON() -> QuoteJSON {
        return QuoteJSON(id: self.id, text: self.text, author: self.author ?? "", classification: self.classification ?? "")
    }
}

extension QuoteJSON {
    func toQuote() -> Quote {
        return Quote(id: self.id, text: self.text, author: self.author, classification: self.classification, likes: 0)
    }
}
