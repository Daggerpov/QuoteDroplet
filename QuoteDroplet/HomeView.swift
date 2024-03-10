//
//  HomeView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

struct HomeView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0
    
    
    
    
    @AppStorage("quoteFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencyIndex = 3
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all
    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0
    @AppStorage("notificationFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var notificationFrequencyIndex = 3
    @AppStorage(notificationToggleKey, store: UserDefaults(suiteName: "group.selectedSettings"))
    var notificationToggleEnabled: Bool = false
    @AppStorage(notificationPermissionKey)
    var notificationPermissionGranted: Bool = UserDefaults.standard.bool(forKey: notificationPermissionKey)
    let frequencyOptions = ["8 hrs", "12 hrs", "1 day", "2 days", "4 days", "1 week"]
    let notificationFrequencyOptions = ["8 hrs", "12 hrs", "1 day", "2 days", "4 days", "1 week"]
    
    @State private var counts: [String: Int] = [:]

    
    
    @State private var notificationTime = Date()
    @State private var isTimePickerExpanded = false
    @State private var showNotificationPicker = false
    init() {
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            UserDefaults.standard.setValue(false, forKey: "isFirstLaunch")
            selectedFontIndex = 0
        }
        // Initialize notificationPermissionGranted based on stored value
        notificationPermissionGranted = UserDefaults.standard.bool(forKey: notificationPermissionKey)
    }
    let availableFonts = [
        "Georgia", "Times New Roman", "Verdana",
        "Palatino", "Baskerville", "Didot", "Optima"
    ]
    private var fontSelector: some View {
        HStack {
            Text("Widget Font:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            Picker("", selection: $selectedFontIndex) {
                ForEach(0..<availableFonts.count, id: \.self) { index in
                    Text(availableFonts[index])
                        .font(.custom(availableFonts[index], size: 16))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
        }
    }
    private var notificationSection: some View {
        Section {
            VStack {
                HStack {
                    Text("Notifications:")
                        .font(.headline)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
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
                                    .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                            )
                    }
                    .padding()
                    .sheet(isPresented: $isTimePickerExpanded) {
                        notificationTimePicker
                    }
                } else {
                    Button(action: {
                        isTimePickerExpanded.toggle()
                    }) {
                        Text("Schedule Daily")
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
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

    private var notificationTimePicker: some View {
        VStack {
            Spacer()
            DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                .padding()
            
            VStack {
                Text("This is when your notification will be sent out to you daily.")
                    .font(.title3)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Text("Note that I'm currently working on a bug where the notification sends out the same quote every time. If you're facing this, you can work around it by scheduling it again.")
                    .font(.title3)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                    .multilineTextAlignment(.center)
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
                            .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
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
        // Cancel existing notifications to reschedule them with the new time
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Get the selected time from notificationTime
        let selectedTime = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)

        // Create a trigger date for the selected time
        guard let triggerDate = Calendar.current.date(from: selectedTime) else {
            print("Error: Couldn't create trigger date.")
            return
        }

        // Create a date components for the trigger time
        let triggerComponents = Calendar.current.dateComponents([.hour, .minute], from: triggerDate)

        // Create a trigger for the notification to repeat daily at the selected time
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)

        // Retrieve a new quote
        getRandomQuoteByClassification(classification: getSelectedQuoteCategory().lowercased()) { quote, error in
            if let quote = quote {
                // Create notification content
                let content = UNMutableNotificationContent()
                if getSelectedQuoteCategory() == QuoteCategory.all.rawValue {
                    content.title = "Quote Droplet"
                } else {
                    content.title = "Quote Droplet: \(getSelectedQuoteCategory()) Quote"
                }
                if let author = quote.author, !author.isEmpty {
                    if author == "Unknown Author" {
                        content.body = quote.text
                    } else {
                        content.body = "\(quote.text)\n- \(author)"
                    }
                } else {
                    content.body = quote.text
                }
                content.sound = UNNotificationSound.default

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
                        print("Scheduled for this time: \(selectedTime)")
                    }
                }
            } else if let error = error {
                print("Error retrieving quote: \(error.localizedDescription)")
            } else {
                print("Unknown error retrieving quote.")
            }
        }
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
    private func getCategoryCounts(completion: @escaping ([String: Int]) -> Void) {
        let group = DispatchGroup()
        var counts: [String: Int] = [:]
        for category in QuoteCategory.allCases {
            group.enter()
            getCountForCategory(category: category) { categoryCount in
                counts[category.rawValue] = categoryCount
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(counts)
        }
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

    private var timeIntervalPicker: some View {
        HStack {
            Text("Refresh Widget:")
                .font(.headline)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
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
    private var widgetPreviewSection: some View {
        VStack {
            Text("Preview:")
                .font(.title3)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                    .overlay(
                        VStack {
                            Spacer()
                            Text("More is lost by indecision than by wrong decision.")
                                .font(Font.custom(availableFonts[selectedFontIndex], size: 16))
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .minimumScaleFactor(0.5)
                                .frame(maxHeight: .infinity)

                            Text("- Cicero")
                                .font(Font.custom(availableFonts[selectedFontIndex], size: 14))
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    )
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 0)
                    .padding(.trailing, 0)
            }
            .frame(width: 150, height: 150)
        }
    }
    
    private var aboutMeSection: some View {
        HStack {
            Text("Contact:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .padding(.leading, 10)
            
            Spacer()
            
            Link(destination: URL(string: "https://www.linkedin.com/in/danielagapov/")!) {
                Image("linkedinlogo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
            
            Link(destination: URL(string: "https://github.com/Daggerpov")!) {
                Image("githublogo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
            
            Link(destination: URL(string: "mailto:danielagapov1@gmail.com?subject=Quote%20Droplet%20Contact")!) {
                Image("gmaillogo")
                    .resizable()
                    .frame(width: 60, height: 50)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
        }
        
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    private var sampleColorSection: some View {
        VStack {
            Text("Sample Colors:")
                .font(.title3)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 10)
            HStack(spacing: 10) {
                ForEach(0..<colorPalettes.count - 1, id: \.self) { paletteIndex in
                    ColorPaletteView(colors: colorPalettes[safe: paletteIndex] ?? [])
                        .frame(width: 60, height: 60)
                        .border(sharedVars.colorPaletteIndex == paletteIndex ? Color.blue : Color.clear, width: 2)
                        .cornerRadius(8)
                        .onTapGesture {
                            sharedVars.colorPaletteIndex = paletteIndex
                            widgetColorPaletteIndex = paletteIndex
                            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                        }
                }
            }
        }
    }
    private var customColorPickers: some View {
        HStack(spacing: 10) {
            ForEach(0..<(colorPalettes.last?.count ?? 0), id: \.self) { customIndex in
                customColorPicker(index: customIndex)
            }
        }
    }
    private func getCountForCategory(category: QuoteCategory, completion: @escaping (Int) -> Void) {
        guard let url = URL(string: "http://quote-dropper-production.up.railway.app/quoteCount?category=\(category.rawValue.lowercased())") else {
            completion(0)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let count = json["count"] as? Int {
                completion(count)
            } else {
                completion(0)
            }
        }.resume()
    }
    private func customColorPicker(index: Int) -> some View {
        ColorPicker(
            "",
            selection: Binding(
                get: {
                    colorPalettes[3][index]
                },
                set: { newColor in
                    colorPalettes[3][index] = newColor
                    sharedVars.colorPaletteIndex = 3
                }
            ),
            supportsOpacity: false
        )
        .frame(width: 60, height: 60)
        .cornerRadius(8)
        .onChange(of: colorPalettes) { _ in
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
        }
    }
    private var customColorSection: some View {
        VStack(spacing: 10) {
            Text("Custom Colors:")
                .font(.title3)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 10)
            customColorPickers
        }
    }
    
    

    
    private func formattedFrequency() -> String {
        return frequencyOptions[quoteFrequencyIndex]
    }
    var body: some View {
        VStack {
            quoteCategoryPicker
            Group {
                HStack(spacing: 20) {
                    VStack(spacing: 10) {
                        sampleColorSection
                        customColorSection
                    }
                    widgetPreviewSection
                }
            }
            
            fontSelector
            Spacer()
            timeIntervalPicker
            Spacer()
            notificationSection
            Spacer()
            aboutMeSection
        }
        .onAppear {
            notificationToggleEnabled = UserDefaults.standard.bool(forKey: notificationToggleKey)
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    notificationPermissionGranted = settings.authorizationStatus == .authorized
                }
            }
            sharedVars.colorPaletteIndex = widgetColorPaletteIndex
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .frame(maxWidth: .infinity)
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
