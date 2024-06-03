//
//  QuoteManager.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-22.
//

import Foundation
import UserNotifications
import SwiftUI
import WidgetKit
import UIKit
import Foundation

class QuoteManager {
    static let shared = QuoteManager()
    
    @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var bookmarkedQuotesData: Data = Data()
    
    private var quotes = [QuoteJSON]()
    
    private init() {
        loadQuotesFromJSON()
    }
    
    private func loadQuotesFromJSON() {
        // Load quotes from JSON file
        guard let path = Bundle.main.path(forResource: "QuotesBackup", ofType: "json") else {
            print("Error: Unable to locate quotes.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            self.quotes = try decoder.decode([QuoteJSON].self, from: data)
        } catch {
            print("Error decoding quotes JSON: \(error.localizedDescription)")
        }
    }
    
    func scheduleNotifications(notificationTime: Date, quoteCategory: QuoteCategory) {
        // Cancel existing notifications to reschedule them with the new time
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let classification = quoteCategory.displayName
        
        // Create a calendar instance
        let calendar = Calendar.current
        
        // Get the current date
        let currentDate = calendar.startOfDay(for: Date())
        
        // Iterate over 60 days
        for i in 0..<60 {
            // Calculate the trigger date for the current notification
            var triggerDate = calendar.dateComponents([.hour, .minute], from: notificationTime)
            triggerDate.day = calendar.component(.day, from: currentDate) + i
            
            // Create notification content
            let content = UNMutableNotificationContent()
            
            let shortQuotes = quotes.filter{ $0.text.count <= 100 }
            
            // Fetch a random quote for the specified classification
            var randomQuote: QuoteJSON
            if classification.lowercased() == "all" {
                guard let randomElement = shortQuotes.randomElement() else {
                    print("Error: Unable to retrieve a random quote.")
                    continue
                }
                randomQuote = randomElement
                content.title = "Quote Droplet"
            } else if classification.lowercased() == "favorites" {
                let bookmarkedQuotes = getBookmarkedQuotes().map { $0.toQuoteJSON() }
                    
                if !bookmarkedQuotes.isEmpty {
                    let randomIndex = Int.random(in: 0..<bookmarkedQuotes.count)
                    
                    let randomElement = bookmarkedQuotes[randomIndex]
                    randomQuote = randomElement
                    
                    content.title = "Quote Droplet: Favorites"
                    
                    // Now randomQuote is of type Quote
                    // Proceed with using randomQuote as needed
                } else {
                    // Handle case where bookmarkedQuotes is empty
                    randomQuote = QuoteJSON(id: 9999999, text: "Please add a quote to favorites by clicking the favorites button under a quote in the app's \"Droplets\" tab", author: "", classification: "Favorites")
                    content.title = "Quote Droplet: No Favorites Added"

                }

            } else {
                // Fetch a random quote with the specified classification
                let filteredQuotes = shortQuotes.filter { $0.classification.lowercased() == classification.lowercased() }
                guard let randomElement = filteredQuotes.randomElement() else {
                    print("Error: Unable to retrieve a random quote.")
                    continue
                }
                randomQuote = randomElement
                content.title = "Quote Droplet: \(classification)"
            }
            
            //adjusted
            if (randomQuote.author != "Unknown Author" && randomQuote.author != "" && randomQuote.author != "NULL" && ((randomQuote.author.isEmpty))) {
                content.body = "\"\(randomQuote.text)\"\n— \(randomQuote.author)"
            } else {
                content.body = "\"\(randomQuote.text)\""
            }
            
            
            
            content.sound = UNNotificationSound.default
            
            // Calculate the trigger date for the current notification
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            // Generate a unique identifier for this notification
            let notificationID = UUID().uuidString
            
            // Create notification request
            let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
            
            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully.")
                    print("Body of notification scheduled: \(content.body)")
                    print("Scheduled for this time: \(triggerDate)")
                }
            }
        }
    }
    
    private func getBookmarkedQuotes() -> [Quote] {
        if let quotes = try? JSONDecoder().decode([Quote].self, from: bookmarkedQuotesData) {
            return quotes
        }
        return []
    }


}

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
