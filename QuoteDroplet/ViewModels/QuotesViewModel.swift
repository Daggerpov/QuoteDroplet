//
//  QuotesViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-24.
//

import Foundation

@available(iOSApplicationExtension 15, *)
class QuotesViewModel: ObservableObject{
    
   
    private var notificationTime = Date()
    private var isTimePickerExpanded = false
    private var showNotificationPicker = false
    private var counts: [String: Int] = [:]
    
    private var notificationScheduledTimeMessage: String = ""
    
    let notificationFrequencyOptions = ["8 hrs", "12 hrs", "1 day", "2 days", "4 days", "1 week"]
    // Notifications------------------------
    
    let frequencyOptions = ["8 hrs", "12 hrs", "1 day", "2 days", "4 days", "1 week"]
    
    let localQuotesService: LocalQuotesService
    let apiService: APIService
    let quoteFrequencyIndex: Int
    let quoteCategory: QuoteCategory
    
    let notificationTimeCase: NotificationTime
    
    init(localQuotesService: LocalQuotesService, apiService: APIService, quoteFrequencyIndex: Int, quoteCategory: QuoteCategory) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
        self.quoteFrequencyIndex = quoteFrequencyIndex
        self.quoteCategory = quoteCategory
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            UserDefaults.standard.setValue(false, forKey: "isFirstLaunch")
        }
    }
    
    public func fetchNotificationScheduledTimeInfo () {
        notificationTimeCase = getIsDefaultConfigOverwritten() ? .previouslySelected : .defaultScheduled
        
        notificationScheduledTimeMessage = "You currently have daily notifications \((notificationTimeCase == .defaultScheduled) ? "automatically " : "")scheduled for: \n"
    }
    
    public func getNotificationTime() -> Date {
        switch notificationTimeCase {
        case .previouslySelected:
            return NotificationScheduler.previouslySelectedNotificationTime
        case .defaultScheduled:
            return NotificationScheduler.defaultScheduledNotificationTime
        }
    }
 
    public func getIsDefaultConfigOverwritten () -> Bool {
        return NotificationScheduler.isDefaultConfigOverwritten
    }
    
    private func formattedFrequency() -> String {
        return frequencyOptions[quoteFrequencyIndex]
    }

    public func scheduleNotificationsAction() {
        if NotificationScheduler.isDefaultConfigOverwritten {
            notificationTime = NotificationScheduler.previouslySelectedNotificationTime
        } else {
            notificationTime = NotificationScheduler.defaultScheduledNotificationTime
        }
        isTimePickerExpanded.toggle()
    }
    
    private func getSelectedQuoteCategory() -> String {
        return quoteCategory.rawValue
    }
    
    private func getCategoryCounts(completion: @escaping ([String: Int]) -> Void) {
        let group = DispatchGroup()
        var counts: [String: Int] = [:]
        for category in QuoteCategory.allCases {
            group.enter()
            if category == .bookmarkedQuotes {
                getBookmarkedQuotesCount { bookmarkedCount in
                    counts[category.rawValue] = bookmarkedCount
                    group.leave()
                }
            } else {
                apiService.getCountForCategory(category: category) { categoryCount in
                    counts[category.rawValue] = categoryCount
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion(counts)
        }
    }
    
    private func getBookmarkedQuotesCount(completion: @escaping (Int) -> Void) {
        let bookmarkedQuotes = localQuotesService.getBookmarkedQuotes()
        completion(bookmarkedQuotes.count)
        
        
        
    }
}
