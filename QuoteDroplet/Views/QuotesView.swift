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
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .
    
    
    @State private var notificationTime = Date()
    @State private var isTimePickerExpanded = false
    @State private var showNotificationPicker = false
    @State private var counts: [String: Int] = [:]
    
    @AppStorage("quoteFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencyIndex = 3
    
    
    // Notifications------------------------
    @AppStorage("notificationFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var notificationFrequencyIndex = 3
    @AppStorage(notificationToggleKey, store: UserDefaults(suiteName: "group.selectedSettings"))
    var notificationToggleEnabled: Bool = false
    @AppStorage(notificationPermissionKey)
    var notificationPermissionGranted: Bool = UserDefaults.standard.bool(forKey: notificationPermissionKey)
    
    let notificationFrequencyOptions = ["8 hrs", "12 hrs", "1 day", "2 days", "4 days", "1 week"]
    // Notifications------------------------
    
    init() {
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            UserDefaults.standard.setValue(false, forKey: "isFirstLaunch")
        }
        // Initialize notificationPermissionGranted based on stored value
        notificationPermissionGranted = UserDefaults.standard.bool(forKey: notificationPermissionKey)
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
                getCountForCategory(category: category) { categoryCount in
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
        let bookmarkedQuotes = getBookmarkedQuotes()
        completion(bookmarkedQuotes.count)
    }
    
    private func getSelectedQuoteCategory() -> String {
        return quoteCategory.rawValue
    }
    private var quoteCategoryPicker: some View {
        HStack {
            Text("Quote Category:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            Picker("", selection: $quoteCategory) {
                if counts.isEmpty {
                    Text("Loading...")
                } else {
                    ForEach(QuoteCategory.allCases, id: \.self) { category in
                        if let categoryCount = counts[category.rawValue] {
                            let displayNameWithCount = "\(category.displayName) (\(categoryCount))"
                            Text(displayNameWithCount)
                                .font(.headline)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                        }
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            .onAppear {
                getCategoryCounts { fetchedCounts in
                    counts = fetchedCounts
                }
            }
            .onTapGesture {
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            }
        }
    }
    
    let frequencyOptions = ["8 hrs", "12 hrs", "1 day", "2 days", "4 days", "1 week"]
    
    private func formattedFrequency() -> String {
        return frequencyOptions[quoteFrequencyIndex]
    }
    
    private var notificationSection: some View {
        Section {
            VStack {
                HStack {
                    Text("Notifications:")
                        .font(.headline)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                        .padding(.horizontal, 5)
                    Toggle("", isOn: $notificationToggleEnabled)
                        .labelsHidden()
                        .onChange(of: notificationToggleEnabled) { newValue in
                            UserDefaults.standard.set(newValue, forKey: notificationToggleKey)
                            if !newValue {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            }
                        }
                }
                if isTimePickerExpanded {
                    Button(action: {
                        isTimePickerExpanded.toggle()
                    }) {
                        Text("Close")
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                            )
                    }
                    .padding()
                    .sheet(isPresented: $isTimePickerExpanded) {
                        notificationTimePicker
                    }
                } else {
                    Button(action: {
                        notificationTime = Date() // Update the notificationTime to the current date and time
                        isTimePickerExpanded.toggle()
                    }) {
                        HStack {
                            Text("Schedule Daily")
                                .font(.headline)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                            Image(systemName: "calendar.badge.clock")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                        )
                    }
                    .padding()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                    )
            )
        }
    }
    
    private var notiTimePickerColor: some View {
        Group{
            if (colorScheme == .light) {
                Group {
                    DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                        .padding()
                        .scaleEffect(1.25)
                }
                .colorInvert()
                .colorMultiply(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            } else {
                Group {
                    DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                        .padding()
                        .scaleEffect(1.25)
                }
                // here we didn't do .colorInvert(), since we're on dark mode already
                .colorMultiply(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            }
        }
    }

    private var notificationTimePicker: some View {
        VStack {
            Spacer()
            
            VStack {
                Text("Daily Notification Scheduling")
                    .font(.title)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                    .multilineTextAlignment(.center)
                Spacer()
                
                notiTimePickerColor
                
                Spacer()
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                isTimePickerExpanded.toggle()
                scheduleNotifications()
            }) {
                Text("Done")
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                    )
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(minWidth: 200, maxWidth: .infinity)
        .background(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear)
        .cornerRadius(8)
        .shadow(radius: 5)
    }
    
    private func scheduleNotifications() {
        NotificationScheduler.shared.scheduleNotifications(notificationTime: notificationTime,
                                                  quoteCategory: quoteCategory)
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                NotificationCenter.default.post(name: NSNotification.Name("NotificationPermissionGranted"), object: nil)
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }

    private var timeIntervalPicker: some View {
        HStack {
            Text("Reload Widget:")
                .font(.headline)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .padding(.horizontal, 5)

            HStack {
                Picker("", selection: $quoteFrequencyIndex) {
                    ForEach(0..<frequencyOptions.count, id: \.self) { index in
                        if self.frequencyOptions[index] == "1 day" {
                            Text("Every day")
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                        } else if self.frequencyOptions[index] == "1 week" {
                            Text("Every week")
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                        } else {
                            Text("Every \(self.frequencyOptions[index])")
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                .onReceive([self.quoteFrequencyIndex].publisher.first()) { _ in
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                )
        )
    }

    var body: some View {
        VStack {
            AdBannerViewController(adUnitID:
                                   "ca-app-pub-5189478572039689/3114130725"
            )
                            .frame(height: 50)
            Spacer()
            quoteCategoryPicker
            Spacer()    
            timeIntervalPicker
            Spacer()
            notificationSection
            Spacer()
            
        }
        .frame(maxWidth: .infinity)
        
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        
        .onAppear {
            notificationToggleEnabled = UserDefaults.standard.bool(forKey: notificationToggleKey)
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    notificationPermissionGranted = settings.authorizationStatus == .authorized
                }
            }
        }
    }
    
}
struct QuotesView_Previews: PreviewProvider {
    static var previews: some View {
        QuotesView()
    }
}
