//
//  QuotesViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-24.
//

import Foundation

@available(iOS 15, *)
class QuotesViewModel: ObservableObject{
    @Published var notificationTime = Date()
    @Published var notificationScheduledTimeMessage: String = ""
    @Published var counts: [String: Int] = [:]
    @Published var isTimePickerExpanded = false
    public let frequencyOptions = ["8 hrs", "12 hrs", "1 day", "2 days", "4 days", "1 week"]

    private var showNotificationPicker = false
    private var notificationTimeCase: NotificationTime = .defaultScheduled
    
    let notificationFrequencyOptions = ["8 hrs", "12 hrs", "1 day", "2 days", "4 days", "1 week"]
    
    let localQuotesService: LocalQuotesService
    let apiService: APIService
    let quoteFrequencyIndex: Int
    let quoteCategory: QuoteCategory

    init(localQuotesService: LocalQuotesService, apiService: APIService, quoteFrequencyIndex: Int, quoteCategory: QuoteCategory) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
        self.quoteFrequencyIndex = quoteFrequencyIndex
        self.quoteCategory = quoteCategory
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            UserDefaults.standard.setValue(false, forKey: "isFirstLaunch")
        }
    }
    
    public func handleNotificationScheduleAction() {
        isTimePickerExpanded.toggle()
        NotificationSchedulerService.shared.scheduleNotifications(notificationTime: notificationTime,
                                                           quoteCategory: quoteCategory, defaults: false)
    }
    
    public func fetchNotificationScheduledTimeInfo () {
        notificationTimeCase = getIsDefaultConfigOverwritten() ? .previouslySelected : .defaultScheduled
        
        notificationScheduledTimeMessage = "You currently have daily notifications \((notificationTimeCase == .defaultScheduled) ? "automatically " : "")scheduled for: \n"
    }
    
    public func getNotificationTime() -> Date {
        switch notificationTimeCase {
        case .previouslySelected:
            return NotificationSchedulerService.previouslySelectedNotificationTime
        case .defaultScheduled:
            return NotificationSchedulerService.defaultScheduledNotificationTime
        }
    }
 
    public func getIsDefaultConfigOverwritten () -> Bool {
        return NotificationSchedulerService.isDefaultConfigOverwritten
    }
    
    private func formattedFrequency() -> String {
        return frequencyOptions[quoteFrequencyIndex]
    }

    public func scheduleNotificationsAction() {
        if NotificationSchedulerService.isDefaultConfigOverwritten {
            notificationTime = NotificationSchedulerService.previouslySelectedNotificationTime
        } else {
            notificationTime = NotificationSchedulerService.defaultScheduledNotificationTime
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
