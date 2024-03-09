import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
struct ContentView: View {
    @AppStorage("colorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var colorPaletteIndex = 0
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
    @State private var showCustomColorsPopover = false
    @State private var showAlert = false
    @State private var showSubmissionInfoAlert = false
    @State private var showNotificationsAlert = false
    @State private var showInstructions = false
    @State private var counts: [String: Int] = [:]
    @State private var isPopupPresented = false
    @State private var isAddingQuote = false
    @State private var quoteText = ""
    @State private var author = ""
    @State private var selectedCategory: QuoteCategory = .wisdom
    @State private var showSubmissionAlert = false
    @State private var submissionMessage = ""
    @State private var showSubmissionReceivedAlert = false
    
    @State private var notificationTime = Date()
    @State private var isTimePickerExpanded = false
    @State private var showNotificationPicker = false
    init() {
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            colorPaletteIndex = 0
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
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            Picker("", selection: $selectedFontIndex) {
                ForEach(0..<availableFonts.count, id: \.self) { index in
                    Text(availableFonts[index])
                        .font(.custom(availableFonts[index], size: 16))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
        }
    }
    private var notificationSection: some View {
        Section {
            VStack {
                HStack {
                    Text("Notifications:")
                        .font(.headline)
                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
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
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
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
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                            )
                    }
                    .padding()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorPalettes[safe: colorPaletteIndex]?[0] ?? .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                    )
            )
        }
    }

    private var notificationTimePicker: some View {
        VStack {
            Spacer()
            DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .accentColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .black)
                .padding()
            
            VStack {
                Text("This is when your notification will be sent out to you daily.")
                    .font(.title3)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .black)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Text("Note that I'm currently working on a bug where the notification sends out the same quote every time. If you're facing this, you can work around it by scheduling it again.")
                    .font(.title3)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .black)
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                isTimePickerExpanded.toggle()
                scheduleNotifications()
            }) {
                Text("Done")
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                    )
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(minWidth: 200, maxWidth: .infinity)
        .background(colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear)
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
    private var quoteCategoryPicker: some View {
        HStack {
            Text("Quote Category:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            Picker("", selection: $quoteCategory) {
                if counts.isEmpty {
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
                getCategoryCounts { fetchedCounts in
                    counts = fetchedCounts
                }
            }
            .onTapGesture {
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            }
        }
    }
    private var submissionQuoteCategoryPicker: some View {
        HStack {
            Text("Quote Category:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            Picker("", selection: $selectedCategory) {
                ForEach(QuoteCategory.allCases, id: \.self) { category in
                    Text(category.displayName)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(colorPalettes[safe: colorPaletteIndex]?[0])
            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1])
            .accentColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
        }
    }
    private func getSelectedQuoteCategory() -> String {
        return quoteCategory.rawValue
    }

    private var timeIntervalPicker: some View {
        HStack {
            Text("Refresh Widget:")
                .font(.headline)
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                .padding(.horizontal, 5)

            HStack {
                Picker("", selection: $quoteFrequencyIndex) {
                    ForEach(0..<frequencyOptions.count, id: \.self) { index in
                        if self.frequencyOptions[index] == "1 day" {
                            Text("Every day")
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                        } else if self.frequencyOptions[index] == "1 week" {
                            Text("Every week")
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                        } else {
                            Text("Every \(self.frequencyOptions[index])")
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                .onReceive([self.quoteFrequencyIndex].publisher.first()) { _ in
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorPalettes[safe: colorPaletteIndex]?[0] ?? .clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                )
        )
    }
    private var widgetPreviewSection: some View {
        VStack {
            Text("Preview:")
                .font(.title3)
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorPalettes[safe: colorPaletteIndex]?[0] ?? .clear)
                    .overlay(
                        VStack {
                            Spacer()
                            Text("More is lost by indecision than by wrong decision.")
                                .font(Font.custom(availableFonts[selectedFontIndex], size: 16))
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .minimumScaleFactor(0.5)
                                .frame(maxHeight: .infinity)

                            Text("- Cicero")
                                .font(Font.custom(availableFonts[selectedFontIndex], size: 14))
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .white)
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
    private var composeButton: some View {
        Button(action: {
            isAddingQuote = true
        }) {
            HStack {
                Text("Submit a quote")
                    .font(.headline)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .blue)
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(colorPalettes[safe: colorPaletteIndex]?[1] ?? .blue, lineWidth: 2)
            )
        }
    }
    private var addQuoteButton: some View {
        Button(action: {
            isAddingQuote = true
        }) {
            Image("compose")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
        }
        .padding()
    }
    private var aboutMeSection: some View {
        HStack {
            Text("Contact:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                .padding(.leading, 10)
            
            Spacer()
            
            Link(destination: URL(string: "https://www.linkedin.com/in/danielagapov/")!) {
                Image("linkedinlogo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
            
            Link(destination: URL(string: "https://github.com/Daggerpov")!) {
                Image("githublogo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
            
            Link(destination: URL(string: "mailto:danielagapov1@gmail.com?subject=Quote%20Droplet%20Contact")!) {
                Image("gmaillogo")
                    .resizable()
                    .frame(width: 60, height: 50)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
        }
        
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .background(ColorPaletteView(colors: [colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    private var sampleColorSection: some View {
        VStack {
            Text("Sample Colors:")
                .font(.title3)
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 10)
            HStack(spacing: 10) {
                ForEach(0..<colorPalettes.count - 1, id: \.self) { paletteIndex in
                    ColorPaletteView(colors: colorPalettes[safe: paletteIndex] ?? [])
                        .frame(width: 60, height: 60)
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
                    colorPalettes[3][index] = newColor
                    colorPaletteIndex = 3
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
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 10)
            customColorPickers
        }
    }
    private var customColorNote: some View {
        VStack(spacing: 10) {
            Button(action: {
                showInstructions = false
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
                        .fill(colorPalettes[safe: colorPaletteIndex]?[0] ?? .clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                        )
                )
                .buttonStyle(CustomButtonStyle())
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Note About Custom Colors"),
                    message: Text("Currently, the custom colors editing doesn't work, and simply act as one more color palette. \n\nI'm actively trying to fix this issue."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    struct CustomButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding()
                .background(configuration.isPressed ? Color.gray.opacity(0.5) : Color.clear)
                .cornerRadius(8)
                .border(configuration.isPressed ? Color.clear : Color.blue, width: 2)
        }
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
            customColorNote
            Spacer()
            fontSelector
            Spacer()
            timeIntervalPicker
            Spacer()
            notificationSection
            Spacer()
            composeButton
            Spacer()
            aboutMeSection
        }
        .sheet(isPresented: $isAddingQuote) {
            VStack(spacing: 10) {
                Text("Quote Submission")
                    .font(.title)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .black)
                    .padding()
                Button(action: {
                    showSubmissionInfoAlert = true
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                        Text("How This Works")
                            .font(.title3)
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                            .padding(.leading, 5)
                    }
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
                .alert(isPresented: $showSubmissionInfoAlert) {
                    Alert(
                        title: Text("How Quote Submission Works"),
                        message: Text("Once you submit a quote, it'll show up on my admin portal, where I'll be able to edit typos or insert missing fields, such as author and classification—so don't worry about these issues. \n\nThen, I'll either approve the quote submission to be added into the app's quote database, or delete it.\n\nNote that if your quote exactly matches another one's text, the submission will not go through."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                TextEditor(text: $quoteText)
                    .frame(minHeight: 100, maxHeight: 150)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .onTapGesture {
                        if quoteText == "Quote Text" {
                            quoteText = ""
                        }
                    }
                    .onAppear {
                        quoteText = "Quote Text"
                    }
                TextEditor(text: $author)
                    .frame(minHeight: 25, maxHeight: 50)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .onTapGesture {
                        if author == "Author" {
                            author = ""
                        }
                    }
                    .onAppear {
                        author = "Author"
                    }

                submissionQuoteCategoryPicker
                Button("Submit") {
                    addQuote(text: quoteText, author: author, classification: selectedCategory.rawValue) { success, error in
                        if success {
                            submissionMessage = "Thanks for submitting a quote. It is now awaiting approval to be added to this app's quote database."
                            // Set showSubmissionReceivedAlert to true after successful submission
                        } else if let error = error {
                            submissionMessage = error.localizedDescription
                        } else {
                            submissionMessage = "An unknown error occurred."
                        }
                        isAddingQuote = false
                        showSubmissionReceivedAlert = true // <-- Set to true after successful submission
                    }
                    
                }
                .padding()
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .black)
                .alert(isPresented: $showSubmissionReceivedAlert) { // Modify this line
                    Alert(
                        title: Text("Submission Received"),
                        message: Text(submissionMessage),
                        dismissButton: .default(Text("OK")) {
                            showSubmissionReceivedAlert = false // Dismisses the alert when OK is clicked
                        }
                    )
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .background(ColorPaletteView(colors: [colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear]))
            .cornerRadius(0) // Remove corner radius
            .edgesIgnoringSafeArea(.all) // Ignore safe area insets
        }
        .onAppear {
            notificationToggleEnabled = UserDefaults.standard.bool(forKey: notificationToggleKey)
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    notificationPermissionGranted = settings.authorizationStatus == .authorized
                }
            }
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear]))
    }
    private func formattedFrequency() -> String {
        return frequencyOptions[quoteFrequencyIndex]
    }
}
let notificationPermissionKey = "notificationPermissionGranted"
let notificationToggleKey = "notificationToggleEnabled"
private var scheduledNotificationIDs: Set<String> = Set() // for the quotes shown already
struct ColorPaletteView: View {
    var colors: [Color]
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
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

