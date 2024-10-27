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

extension QuoteJSON {
    static func mockQuote() -> QuoteJSON {
        let ids = [0, 10, 85]

        let mockData = [
            (text: "Courage isn't having the strength to go on—it is going on when you don't have strength.",
             author: "Napoleon",
             classification: "motivation"),

            (text: "He who has a why to live can bear almost any how.",
             author: "Friedrich Nietzsche",
             classification: "philosophy"),

            (text: "If you are filled with pride, then you will have no room for wisdom.",
             author: "African Proverb",
             classification: "wisdom")
        ]

        let randomID = ids.randomElement()!
        let randomQuote = mockData.randomElement()!

        return QuoteJSON(
            id: randomID,
            text: randomQuote.text,
            author: randomQuote.author,
            classification: randomQuote.classification
        )
    }
}
