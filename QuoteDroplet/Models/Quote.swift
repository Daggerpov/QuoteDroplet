//
//  Quote.swift
//  Quote-Droplet
//
//  Created by Daniel Agapov on 2023-04-05.
//

import Foundation

struct Quote: Codable, Identifiable {
    let id: Int
    let text: String
    let author: String?
    let classification: String?
    let likes: Int?
}


extension Quote {
    static func mockQuote() -> Quote {
        let ids = [0, 10, 85]
        let likes = [0, 10, 30]

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
        let randomLikes = likes.randomElement()!
        let randomQuote = mockData.randomElement()!

        return Quote(
            id: randomID,
            text: randomQuote.text,
            author: randomQuote.author,
            classification: randomQuote.classification,
            likes: randomLikes
        )
    }
}

