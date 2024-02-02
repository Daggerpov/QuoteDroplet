//
//  ContentView.swift
//  QuoteDroplet
//
//  Created by Daniel Agapov on 2023-08-30.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit


var colorPalettes = [
    [Color(hex: "504136"), Color(hex: "EEC584"), Color(hex: "CC5803")],
    [Color(hex: "85C7F2"), Color(hex: "0C1618"), Color(hex: "83781B")],
    [Color(hex: "EFF8E2"), Color(hex: "DC9E82"), Color(hex: "423E37")],
    [Color(hex: "1C7C54"), Color(hex: "E2B6CF"), Color(hex: "DEF4C6")]
]

enum QuoteCategory: String, CaseIterable {
    case wisdom = "Wisdom"
    case motivation = "Motivation"
    case discipline = "Discipline"
    case philosophy = "Philosophy"
    case inspiration = "Inspiration"
    case upliftment = "Upliftment"
    case love = "Love"
    case all = "All"
    
    var displayName: String {
        return self.rawValue
    }
}

struct ContentView: View {
    @AppStorage("colorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var colorPaletteIndex = 0
    @AppStorage("quoteFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencyIndex = 3
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all
    
    // Added for customColorsNote
    @State private var showCustomColorsPopover = false
    
    // Alert for the custom colors popover
    @State private var showAlert = false
    
    @State private var showNotificationsAlert = false
    
    @State private var showInstructions = false
    
    @State private var counts: [String: Int] = [:]
    // Add a property to track whether a custom color has been picked
    
    let frequencyOptions = ["30 sec", "10 min", "1 hr", "2 hrs", "4 hrs", "8 hrs", "1 day"]
    
    init() {
        // Check if the app is launched for the first time
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            // Set the default color palette index to 0 (first sample color palette)
            colorPaletteIndex = 0
            UserDefaults.standard.setValue(false, forKey: "isFirstLaunch")
        }
    }
    
    // Function to schedule local notifications
    private func scheduleNotifications() {
        // Fetch a random quote for the notification body
        getRandomQuoteByClassification(classification: getSelectedQuoteCategory().lowercased()) { quote, error in
            if let quote = quote {
                // Create a notification content with the fetched quote
                let content = UNMutableNotificationContent()
                content.title = "\(getSelectedQuoteCategory()) Quote"
                content.body = "\(quote.text)\n\n- \(quote.author ?? "Unknown Author")"
                content.sound = UNNotificationSound.default

                // Create a trigger to fire the notification every 5 minutes
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: true)

                // Create a request for the notification
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // Add the notification request to the notification center
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    } else {
                        print("Notification scheduled successfully.")
                    }
                }
            }
        }
    }
    
    // Function to request push notification permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // Post a notification indicating that authorization is granted
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
    
    private var quoteCategoryPicker: some View {
        HStack {
            Text("Quote Category:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)

            Picker("", selection: $quoteCategory) {
                if counts.isEmpty {
                    // Placeholder while counts are being fetched
                    Text("Loading...")
                } else {
                    ForEach(QuoteCategory.allCases, id: \.self) { category in
                        if let categoryCount = counts[category.rawValue] {
                            let displayNameWithCount = "\(category.displayName) (\(categoryCount))"

                            Text(displayNameWithCount)
                                .font(.headline)
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                        }
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
            .onAppear {
                // Fetch category counts asynchronously when the view appears
                getCategoryCounts { fetchedCounts in
                    // Update the counts and trigger a view update
                    counts = fetchedCounts
                }
            }
            .onTapGesture {
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            }
        }
    }
    
    // Function to get the selected quote category as a string
    private func getSelectedQuoteCategory() -> String {
        return quoteCategory.rawValue
    }

    
    private var timeIntervalPicker: some View {
        Group {
            Text("Time interval between quotes:")
                .font(.title2) // Increased font size
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 20)
            
            Picker("", selection: $quoteFrequencyIndex) {
                ForEach(0..<frequencyOptions.count, id: \.self) { index in
                    Text(self.frequencyOptions[index])
                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onReceive([self.quoteFrequencyIndex].publisher.first()) { _ in
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            }
            
        }
        .padding(.bottom, 20) // Increased spacing
    }
    
    private var widgetPreviewSection: some View {
        VStack {
            Text("Preview:")
                .font(.title3) // Increased font size
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorPalettes[safe: colorPaletteIndex]?[0] ?? .clear) // Use the first color as the background color
                    .overlay(
                        VStack {
                            Spacer()
                            Text("More is lost by indecision than by wrong decision.")
                                .font(.headline)
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white) // Use the second color for text color
                                .padding(.horizontal, 20) // SPLIT BY ME
                                .padding(.vertical, 10) // SPLIT BY ME
                                .multilineTextAlignment(.center) // Center-align the text
                                .lineSpacing(4) // Adjusted line spacing
                                .minimumScaleFactor(0.5)
                                .frame(maxHeight: .infinity)

                            Text("- Cicero")
                                .font(.subheadline)
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .white) // Use the third color for author text color
                                .padding(.horizontal, 20) // ! SPLIT BY ME
                                .padding(.bottom, 10) // ! CHANGED BY ME
                                .lineLimit(1) // Ensure the author text is limited to one line
                                .minimumScaleFactor(0.5) // Allow author text to scale down if needed
                        }
                    )
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 0) // Add a subtle shadow for depth
                    .padding(.trailing, 0)
            }
            .frame(width: 150, height: 150)
        }
    }
    
    private var aboutMeSection: some View {
        // About Me Section
        
        HStack {
            Text("About Me:")
                .font(.title2) // Increased font size
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                .padding(.leading, 10)
            Spacer()
            Link(destination: URL(string: "https://github.com/Daggerpov")!) {
                Image("githublogo")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            }
            
            Link(destination: URL(string: "https://www.linkedin.com/in/danielagapov/")!) {
                Image("linkedinlogo")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            }
            Spacer()
        }
        
        .padding(EdgeInsets(top: 15, leading: 0, bottom: 10, trailing: 0))
        .background(ColorPaletteView(colors: [colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private var sampleColorSection: some View {
        VStack {
            Text("Sample Colors:")
                .font(.title3) // Increased font size
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 10)
            HStack(spacing: 10) {
                ForEach(0..<colorPalettes.count - 1, id: \.self) { paletteIndex in
                    ColorPaletteView(colors: colorPalettes[safe: paletteIndex] ?? [])
                        .frame(width: 60, height: 60) // Adjusted size
                        .border(colorPaletteIndex == paletteIndex ? Color.blue : Color.clear, width: 2)
                        .cornerRadius(8)
                        .onTapGesture {
                            colorPaletteIndex = paletteIndex
                            
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
                    // Update the last element with the custom color palette
                    colorPalettes[3][index] = newColor
                    // Set colorPaletteIndex to the index of the custom color palette
                    colorPaletteIndex = 3
                }
            ),
            supportsOpacity: false
        )
        .frame(width: 60, height: 60)
        .cornerRadius(8)
        .onChange(of: colorPalettes) { _ in
            // Reload the widget timeline whenever the custom color changes
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
        }
    }

    private var customColorSection: some View {
        VStack(spacing: 10) {
            Text("Custom Colors:")
                .font(.title3) // Increased font size
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 10)
            
            customColorPickers
        }
    }
    
    private var customColorNote: some View {
        VStack(spacing: 10) {
            // Note about Custom Colors Button
            Button(action: {
                showInstructions = false // Close instructions if open
                showAlert = true
            }) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)

                    Text("Note About Custom Colors")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                        .padding(.leading, 5)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorPalettes[safe: colorPaletteIndex]?[0] ?? .clear) // Use the first color as the background color
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue, lineWidth: 2) // Add a border with the third color
                        )
                )
                .buttonStyle(CustomButtonStyle()) // Apply the custom button style
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Note About Custom Colors"),
                    message: Text("Currently, the custom colors editing doesn't work, and simply act as one more color palette. \n\nI'm actively trying to fix this issue."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .popover(isPresented: $showCustomColorsPopover) {
            CustomColorsPopoverContent()
        }
    }

    struct CustomButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding()
                .background(configuration.isPressed ? Color.gray.opacity(0.5) : Color.clear) // Change the background color when pressed
                .cornerRadius(8)
                .border(configuration.isPressed ? Color.clear : Color.blue, width: 2) // Add a border when not pressed
        }
    }
    
    // New View for the Popover content
    struct CustomColorsPopoverContent: View {
        var body: some View {
            VStack {
                Text("Custom Colors Instructions")
                    .font(.headline)
                    .padding()

                Text("To customize your own colors, tap and hold on the colored circles below. Each circle represents a different color in the palette.")
                    .font(.body)
                    .padding()

                Text("Note: Changes will apply to the 'Custom Colors' palette.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()

                Spacer()
            }
            .padding()
            .frame(minWidth: 200, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
        }
    }



    var body: some View {
        VStack {
            quoteCategoryPicker
            
            timeIntervalPicker
            
            // Color Palette Section
            Group {
                HStack(spacing: 20) {
                    VStack(spacing: 10) {
                        sampleColorSection
                        
                        customColorSection
                    }
                    widgetPreviewSection
                }
            }
            
            customColorNote
            
            Spacer() // Create spacing
            
            
            if showInstructions {
                InstructionsSection()
            } else {
                Text("Be sure to add the widget.")
                    .font(.title2)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                showNotificationsAlert.toggle()
            }) {
                Text("Allow Push Notifications")
                    .font(.headline)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colorPalettes[safe: colorPaletteIndex]?[0] ?? .clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                            )
                    )
                    .buttonStyle(CustomButtonStyle())
            }
            .alert(isPresented: $showNotificationsAlert, content: {
                Alert(
                    title: Text("Allow Push Notifications"),
                    message: Text("Do you want to allow push notifications?"),
                    primaryButton: .default(Text("Allow"), action: {
                        // Handle user's choice when "Allow" is tapped
                        scheduleNotifications() // Call the function to schedule notifications
                    }),
                    secondaryButton: .cancel(Text("Don't Allow"))
                )
            })
            
            Spacer()
            
//            Button(action: {
//                showInstructions.toggle()
//            }) {
//                if showInstructions{
//                    Text("Hide Instructions")
//                        .font(.headline)
//                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
//                } else {
//                    Text("Show Instructions")
//                        .font(.headline)
//                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
//                }
//            }
               
//            Spacer()
            
            aboutMeSection
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear]))
    }

    
    private func formattedFrequency() -> String {
        return frequencyOptions[quoteFrequencyIndex]
    }
}

// A view that displays a gradient background using the provided colors
struct ColorPaletteView: View {
    var colors: [Color]
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea() // This line will make the background take up the whole screen
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


struct InstructionsSection: View {
    let instructions = [
        "Press and hold an empty area of your home screen.",
        "Tap the '+' button (top left).",
        "Find and select 'Quote Droplet'."
    ]

    var body: some View {
        List(instructions, id: \.self) { instruction in
            Text(instruction)
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
    }
}
