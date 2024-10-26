//
//  QuotesViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-24.
//

import Foundation

@available(iOS 15, *)
class QuotesViewModel: ObservableObject{
    @Published var notificationTime: Date = Date()
    @Published var notificationScheduledTimeMessage: String = ""
    @Published var counts: [String: Int] = [:]
    @Published var isTimePickerExpanded: Bool = false

    private var showNotificationPicker = false
    private var notificationTimeCase: NotificationTime = .defaultScheduled
    
    let localQuotesService: LocalQuotesService
    let apiService: APIService

    init(localQuotesService: LocalQuotesService, apiService: APIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            UserDefaults.standard.setValue(false, forKey: "isFirstLaunch")
        }
    }

    public func initializeCounts() {
        getCategoryCounts { [weak self] fetchedCounts in
            self?.counts = fetchedCounts
        }
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
    
    public func scheduleNotificationsAction() {
        if NotificationSchedulerService.isDefaultConfigOverwritten {
            notificationTime = NotificationSchedulerService.previouslySelectedNotificationTime
        } else {
            notificationTime = NotificationSchedulerService.defaultScheduledNotificationTime
        }
        isTimePickerExpanded.toggle()
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
