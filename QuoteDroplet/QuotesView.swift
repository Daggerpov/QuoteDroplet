//
//  QuotesView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

struct QuotesView: View {
    @AppStorage("quoteFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencyIndex = 3
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all
    
    @AppStorage("notificationFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var notificationFrequencyIndex = 3
    @AppStorage(notificationToggleKey, store: UserDefaults(suiteName: "group.selectedSettings"))
    var notificationToggleEnabled: Bool = false
    @AppStorage(notificationPermissionKey)
    var notificationPermissionGranted: Bool = UserDefaults.standard.bool(forKey: notificationPermissionKey)
    let frequencyOptions = ["8 hrs", "12 hrs", "1 day", "2 days", "4 days", "1 week"]
    let notificationFrequencyOptions = ["8 hrs", "12 hrs", "1 day", "2 days", "4 days", "1 week"]
    
    var body: some View {
        Text("Quote Adjustments")
    }
}
struct QuotesView_Previews: PreviewProvider {
    static var previews: some View {
        QuotesView()
    }
}
