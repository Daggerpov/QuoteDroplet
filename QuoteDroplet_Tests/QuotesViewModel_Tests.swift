//
//  QuotesViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet

@Suite("Quotes View Model Tests") struct QuotesViewModel_Tests {

    let sut = QuotesViewModel(localQuotesService: MockLocalQuotesService(), apiService: MockAPIService())

    @Test func initializeCounts_success() async {
        // Configure the mock API to return expected category counts
        sut.apiService.setCategoryCounts(["motivation": 10, "wisdom": 15, "bookmarkedQuotes": 5])

        // Call initializeCounts and check counts are correctly set
        sut.initializeCounts()
        #expect(sut.counts["motivation"] == 10)
        #expect(sut.counts["wisdom"] == 15)
        #expect(sut.counts["bookmarkedQuotes"] == 5)
    }

    @Test func fetchNotificationScheduledTimeInfo_defaultConfig() {
        // Mock the default configuration settings
        NotificationSchedulerService.isDefaultConfigOverwritten = false

        sut.fetchNotificationScheduledTimeInfo()
        #expect(sut.notificationScheduledTimeMessage.contains("automatically scheduled"))
    }

    @Test func fetchNotificationScheduledTimeInfo_overwrittenConfig() {
        // Mock that the default configuration is overwritten
        NotificationSchedulerService.isDefaultConfigOverwritten = true

        sut.fetchNotificationScheduledTimeInfo()
        #expect(sut.notificationScheduledTimeMessage.contains("scheduled for:"))
        #expect(!sut.notificationScheduledTimeMessage.contains("automatically"))
    }

    @Test func getNotificationTime_default() {
        // Mock NotificationSchedulerService's default scheduled time
        NotificationSchedulerService.defaultScheduledNotificationTime = Date(timeIntervalSince1970: 0)

        let time = sut.getNotificationTime()
        #expect(time == Date(timeIntervalSince1970: 0))
    }

    @Test func getNotificationTime_previouslySelected() {
        // Mock NotificationSchedulerService's previously selected notification time
        NotificationSchedulerService.isDefaultConfigOverwritten = true
        NotificationSchedulerService.previouslySelectedNotificationTime = Date(timeIntervalSince1970: 1000)

        let time = sut.getNotificationTime()
        #expect(time == Date(timeIntervalSince1970: 1000))
    }

    @Test func scheduleNotificationsAction_togglePicker() {
        // Verify initial picker state
        #expect(!sut.isTimePickerExpanded)

        // Call the method to toggle
        sut.scheduleNotificationsAction()

        // Verify picker expanded state
        #expect(sut.isTimePickerExpanded)
    }
}
