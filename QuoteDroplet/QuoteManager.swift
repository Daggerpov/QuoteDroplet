//
//  QuoteManager.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-22.
//

import Foundation
import UserNotifications

class QuoteManager {
    static let shared = QuoteManager()
    
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
    
    func scheduleNotifications(notificationTime: Date) {
        // Cancel existing notifications to reschedule them with the new time
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Iterate over 60 random quotes
        for _ in 0..<60 {
            // Get a random quote
            guard let randomQuote = quotes.randomElement() else {
                print("Error: Unable to retrieve a random quote.")
                continue
            }
            
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = "Random Quote"
            content.body = "\(randomQuote.text)\n- \(randomQuote.author)"
            content.sound = UNNotificationSound.default
            
            // Calculate the trigger date for the selected time
            let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
            
            // Create a trigger for the notification to repeat daily at the selected time
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            
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
                    print("Scheduled for this time: \(notificationTime)")
                }
            }
        }
    }
}

struct QuoteJSON: Codable {
    let id: Int
    let text: String
    let author: String
    let classification: String
}
