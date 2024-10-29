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
    
    let localQuotesService: ILocalQuotesService
    let apiService: IAPIService

    init(localQuotesService: ILocalQuotesService, apiService: IAPIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            UserDefaults.standard.setValue(false, forKey: "isFirstLaunch")
        }
    }
    
    public func initializeCounts() {
        getCategoryCounts { [weak self] fetchedCounts in
            guard let self = self else { return }
            self.counts = fetchedCounts
        }
    }

    public func fetchNotificationScheduledTimeInfo () {
        self.notificationTimeCase = getIsDefaultConfigOverwritten() ? .previouslySelected : .defaultScheduled
        
        self.notificationScheduledTimeMessage = "You currently have daily notifications \((notificationTimeCase == .defaultScheduled) ? "automatically " : "")scheduled for: \n"
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
            self.notificationTime = NotificationSchedulerService.previouslySelectedNotificationTime
        } else {
            self.notificationTime = NotificationSchedulerService.defaultScheduledNotificationTime
        }
        isTimePickerExpanded.toggle()
    }
    
    private func getCategoryCounts(completion: @escaping ([String: Int]) -> Void) {
        let group = DispatchGroup()
        for category in QuoteCategory.allCases {
            group.enter()
            if category == .bookmarkedQuotes {
                getBookmarkedQuotesCount { [weak self] bookmarkedCount in
                    guard let self = self else {return}
                    self.counts[category.rawValue] = bookmarkedCount
                    group.leave()
                }
            } else {
                apiService.getCountForCategory(category: category) { [weak self] categoryCount in
                    guard let self = self else {return}
                    self.counts[category.rawValue] = categoryCount
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else {return}
            completion(counts)
        }
    }
    
    private func getBookmarkedQuotesCount(completion: @escaping (Int) -> Void) {
        let bookmarkedQuotes = localQuotesService.getBookmarkedQuotes()
        completion(bookmarkedQuotes.count)
    }
}
