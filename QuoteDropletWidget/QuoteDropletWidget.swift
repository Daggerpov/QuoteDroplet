//
//  QuoteDropletWidget.swift
//  QuoteDropletWidget
//
//  Created by Daniel Agapov on 2023-08-30.
//

import WidgetKit
import SwiftUI
import Intents
import Foundation
import AppIntents

// Fonts for widget and widget preview
let availableFonts = [
    "Georgia", "Times New Roman",
    "Verdana", "Palatino", "Baskerville", "Didot",
    "Optima", "Arial"
]

// Extension to disable content margins
extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

struct Provider: IntentTimelineProvider {
    var data = DataService()
    
    func placeholder(in context: Context) -> SimpleEntry {
        let defaultQuote = Quote(id: 1, text: "More is lost by indecision than by wrong decision.", author: "Cicero", classification: "Sample Classification", likes: 15)
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: defaultQuote, widgetColorPaletteIndex: data.getIndex(), widgetCustomColorPalette: data.getColorPalette(), quoteFrequencyIndex: data.getQuoteFrequencyIndex(), quoteCategory: data.getQuoteCategory())
    }
    
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, quote: nil, widgetColorPaletteIndex: data.getIndex(), widgetCustomColorPalette: data.getColorPalette(), quoteFrequencyIndex: data.getQuoteFrequencyIndex(), quoteCategory: data.getQuoteCategory())
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let startDate = Calendar.current.date(byAdding: .second, value: 0, to: currentDate)!
        
        // Calculate the frequency in seconds based on the selected index
        let frequencyInSeconds = getFrequencyInSeconds(for: data.getQuoteFrequencyIndex())
        
        // Schedule the next update based on the calculated frequency
        let nextUpdate = Calendar.current.date(byAdding: .second, value: frequencyInSeconds, to: startDate)!
        
        if data.getQuoteCategory().lowercased() == "favorites" {
            let bookmarkedQuotes = data.getBookmarkedQuotes()
            
            if !bookmarkedQuotes.isEmpty {
                let randomIndex = Int.random(in: 0..<bookmarkedQuotes.count)
                let entry = SimpleEntry(date: nextUpdate, configuration: configuration, quote: bookmarkedQuotes[randomIndex], widgetColorPaletteIndex: data.getIndex(), widgetCustomColorPalette: data.getColorPalette(), quoteFrequencyIndex: data.getQuoteFrequencyIndex(), quoteCategory: data.getQuoteCategory())
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } else {
                // TODO: add an error or maybe a quote with the message "No Favourites Added" Please go into the Droplets section of the app to favourite some quotes, so they can show up here"
                completion(Timeline(entries: [], policy: .after(nextUpdate)))
            }
        } else {
            // Fetch the initial quote
            getRandomQuoteByClassification(classification: data.getQuoteCategory().lowercased()) { quote, error in
                if var quote = quote {
                    // Check if the quote is too long
                    while isQuoteTooLong(text: quote.text, context: context, author: quote.author) {
                        // Fetch a new quote
                        getRandomQuoteByClassification(classification: data.getQuoteCategory().lowercased()) { newQuote, _ in
                            if let newQuote = newQuote {
                                quote = newQuote
                            }
                        }
                    }
                    
                    let entry = SimpleEntry(date: nextUpdate, configuration: configuration, quote: quote, widgetColorPaletteIndex: data.getIndex(), widgetCustomColorPalette: data.getColorPalette(), quoteFrequencyIndex: data.getQuoteFrequencyIndex(), quoteCategory: data.getQuoteCategory())
                    
                    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                    completion(timeline)
                }
            }
        }
    }
    
    // Helper function to check if a quote is too long
    private func isQuoteTooLong(text: String, context: Context, author: String?) -> Bool {
        let maxWidth: CGFloat = {
            switch context.family {
            case .systemSmall:
                return 20
            case .systemMedium:
                return 200
            case .systemLarge:
                return 300
            case .systemExtraLarge:
                return 400
            case .accessoryCircular:
                return 120
            case .accessoryRectangular:
                return 180
            case .accessoryInline:
                return 100
            @unknown default:
                return 100
            }
        }()
        
        var maxHeight: CGFloat = {
            switch context.family {
            case .systemSmall:
                return 20
            case .systemMedium:
                return 40
            case .systemLarge:
                return 100
            case .systemExtraLarge:
                return 200
            case .accessoryCircular:
                return 120
            case .accessoryRectangular:
                return 180
            case .accessoryInline:
                return 60
            @unknown default:
                return 20
            }
        }()
        
        // Check if the author is going to take up 2 lines and adjust the maxHeight accordingly
        
        // adjusted
        if let author = author, (!author.isEmpty && author != "Unknown Author" && author != "" && author != "NULL") {
            let authorFont = UIFont.systemFont(ofSize: 14) // Use an appropriate font size for the author
            let authorBoundingBox = author.boundingRect(
                with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin],
                attributes: [NSAttributedString.Key.font: authorFont],
                context: nil
            )
            
            if authorBoundingBox.height > maxHeight / 2 {
                maxHeight = maxHeight * 0.85 // Adjust the factor as needed
            }
        }
        
        let font = UIFont.systemFont(ofSize: 16) // Use an appropriate font size
        let boundingBox = text.boundingRect(
            with: CGSize(width: maxWidth, height: maxHeight),
            options: [.usesLineFragmentOrigin],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        
        // Check if the quote has an author
        
        // adjusted
        if let author = author, (!author.isEmpty && author != "Unknown Author" && author != "" && author != "NULL") {
            return boundingBox.height > maxHeight
        } else {
            // Allow the quote to be 5% longer when there is no author
            let maxAllowedHeight = maxHeight * 1.05
            return boundingBox.height > maxAllowedHeight
        }
    }
    
}

// Helper function to convert selected frequency index to seconds
public func getFrequencyInSeconds(for index: Int) -> Int {
    switch index {
    case 0: return 28800                // 8 hrs
    case 1: return 43200                // 12 hrs
    case 2: return 86400                // 1 day
    case 3: return 172800               // 2 days
    case 4: return 345600               // 4 days
    case 5: return 604800               // 1 week
    default: return 86400               // 1 Day
    }
}

@available(iOS 16.0, *)
public func getFontSizeForText(familia: WidgetFamily, whichText: String) -> CGFloat {
    if (whichText == "text") {
        // widgetAppropriateTextFontSize
        if familia == .systemExtraLarge {
            return 32
        } else if familia == .systemLarge {
            return 24
        } else {
            // .systemSmall & .systemMedium
            // stays as it was earlier
            return 16
        }
    } else {
        // author
        if familia == .systemExtraLarge {
            return 22
        } else if familia == .systemLarge {
            return 18
        } else {
            // .systemSmall & .systemMedium
            // stays as it was earlier
            return 14
        }
    }
}

public func getTextForWidgetPreview(familia: WidgetFamily) -> [String] {
    if familia == .systemSmall {
        return ["More is lost by indecision than by wrong decision.", "Cicero"];
    } else if familia == .systemMedium {
        return ["Our anxiety does not come from thinking about the future, but from wanting to control it.", "Khalil Gibran"];
    } else {
        // .systemLarge
        return ["Show me a person who has never made a mistake and I'll show you someone who hasn't achieved much.", "Joan Collins"];
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let quote: Quote?  // Include the fetched quote here
    let widgetColorPaletteIndex: Int
    let widgetCustomColorPalette: [Color]
    let quoteFrequencyIndex: Int
    let quoteCategory: String
}

struct MinimumFontModifier: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    let minimumSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: max(size, minimumSize), weight: weight, design: design))
            .lineLimit(nil) // Remove line limit to prevent truncation
    }
}

@available(iOS 16.0, *)
struct QuoteDropletWidgetEntryView : View {
    var data = DataService()
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    let widgetQuote: Quote
    
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @AppStorage("likedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var likedQuotesData: Data = Data()
    
    @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var bookmarkedQuotesData: Data = Data()
    
    @AppStorage("interactions", store: UserDefaults(suiteName: "group.selectedSettings"))
    var interactions = 0
    
    @State private var isLiked: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var likes: Int = 69 // Change likes to non-optional
    @State private var isLiking: Bool = false // Add state for liking status
    
    @State private var isIntentsActive: Bool = false
    
    init(entry: SimpleEntry, isIntentsActive: Bool) {
        self.entry = entry
        self.widgetQuote = entry.quote ?? Quote(id: 1, text: "", author: "", classification: "", likes: 15)
        self._isBookmarked = State(initialValue: isQuoteBookmarked(widgetQuote))
        self._isLiked = State(initialValue: isQuoteLiked(widgetQuote))
        self._isIntentsActive = State(initialValue: isIntentsActive)
    }
    
    var colors: [Color] {
        if (data.getIndex() == 3) {
            return data.getColorPalette()
        } else {
            return colorPalettes[safe: data.getIndex()] ?? [Color.clear]
        }
    }
    
    private func getQuoteLikeCountMethod(completion: @escaping (Int) -> Void) {
        getLikeCountForQuote(quoteGiven: widgetQuote) { likeCount in
            completion(likeCount)
        }
    }
    
    private func getLikeCountForQuote(quoteGiven: Quote, completion: @escaping (Int) -> Void) {
        guard let url = URL(string: "http://quote-dropper-production.up.railway.app/quoteLikes/\(quoteGiven.id)") else {
            completion(0)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let likeCount = json["likes"] as? Int {
                completion(likeCount)
            } else {
                completion(0)
            }
        }.resume()
    }
    
    private var authorWithLikes: some View {
        HStack {
            if (widgetQuote.author != "Unknown Author" && widgetQuote.author != nil && widgetQuote.author != "" && widgetQuote.author != "NULL") {
                Text("— \(widgetQuote.author ?? "")")
                    .foregroundColor(colors[2]) // Use the third color for author text color
                    .padding(.horizontal, 10)
            }
            
            if #available(iOSApplicationExtension 17.0, *) {
                Button(intent: LikeQuoteIntent()) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(colors[2])
                }.backgroundStyle(colors[2])
            } else {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(colors[2])
            }
            
            Text("\(widgetQuote.likes ?? 69)")
                .foregroundColor(colors[2])
        }
        .font(Font.custom(availableFonts[data.selectedFontIndex], size: 14))
    }
    
    var body: some View {
        ZStack {
            colors[0] // Use the first color as the background color
            
            VStack {
                if widgetQuote.text != "" {
                    Text("\(widgetQuote.text)")
                        .font(Font.custom(availableFonts[data.selectedFontIndex], size: 500)) // Use the selected font
                        .foregroundColor(colors[1]) // Use the second color for text color
                        .padding(.horizontal, 10)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        .minimumScaleFactor(0.01)
                    if family == .systemSmall || !isIntentsActive {
                        if (widgetQuote.author != "Unknown Author" && widgetQuote.author != nil && widgetQuote.author != "" && widgetQuote.author != "NULL") {
                            Text("— \(widgetQuote.author ?? "")")
                                .font(Font.custom(availableFonts[data.selectedFontIndex], size: getFontSizeForText(familia: family, whichText: "author"))) // Use the selected font for author text
                                .foregroundColor(colors[2]) // Use the third color for author text color
                                .padding(.horizontal, 5)
                        }
                    } else {
                        authorWithLikes
                    }
                } else {
                    Text("\(getTextForWidgetPreview(familia: family)[0])")
                        .font(Font.custom(availableFonts[data.selectedFontIndex], size: 500)) // Use the selected font
                        .foregroundColor(colors[1]) // Use the second color for text color
                        .padding(.horizontal, 10)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        .minimumScaleFactor(0.01)
                    Spacer() // Add a spacer to push the author text to the center
                    
                    Text("— \(getTextForWidgetPreview(familia: family)[1])")
                        .font(Font.custom(availableFonts[data.selectedFontIndex], size: getFontSizeForText(familia: family, whichText: "author"))) // Use the selected font for author text
                        .foregroundColor(colors[2]) // Use the third color for author text color
                        .padding(.horizontal, 10)
                    
                }
            }
            .padding()
            
        }
        .onAppear {
            isBookmarked = isQuoteBookmarked(widgetQuote)
            
            getQuoteLikeCountMethod { fetchedLikeCount in
                likes = fetchedLikeCount
            }
            isLiked = isQuoteLiked(widgetQuote)
        }
        
    }
    
    private func toggleBookmark() {
        isBookmarked.toggle()
        
        var bookmarkedQuotes = getBookmarkedQuotes()
        if isBookmarked {
            bookmarkedQuotes.append(widgetQuote)
        } else {
            bookmarkedQuotes.removeAll { $0.id == widgetQuote.id }
        }
        saveBookmarkedQuotes(bookmarkedQuotes)
        
        interactionsIncrease()
    }
    
    private func toggleLike() {
        isLiked.toggle()
        
        var likedQuotes = getLikedQuotes()
        if isLiked {
            likedQuotes.append(widgetQuote)
        } else {
            likedQuotes.removeAll { $0.id == widgetQuote.id }
        }
        saveLikedQuotes(likedQuotes)
        
        interactionsIncrease()
    }
    
    private func interactionsIncrease() {
        interactions += 1
    }
    
    private func likeQuoteAction() {
        guard !isLiking else { return }
        isLiking = true
        
        // Check if the quote is already liked
        let isAlreadyLiked = isQuoteLiked(widgetQuote)
        
        // Call the like/unlike API based on the current like status
        if isAlreadyLiked {
            unlikeQuote(quoteID: widgetQuote.id) { updatedQuote, error in
                DispatchQueue.main.async {
                    if let updatedQuote = updatedQuote {
                        // Update likes count
                        self.likes = updatedQuote.likes ?? 15
                    }
                    self.isLiking = false
                }
            }
        } else {
            likeQuote(quoteID: widgetQuote.id) { updatedQuote, error in
                DispatchQueue.main.async {
                    if let updatedQuote = updatedQuote {
                        // Update likes count
                        self.likes = updatedQuote.likes ?? 15
                    }
                    self.isLiking = false
                }
            }
        }
    }
    
    private func isQuoteLiked(_ quote: Quote) -> Bool {
        return getLikedQuotes().contains(where: { $0.id == quote.id })
    }
    
    private func getLikedQuotes() -> [Quote] {
        if let quotes = try? JSONDecoder().decode([Quote].self, from: likedQuotesData) {
            return quotes
        }
        return []
    }
    
    private func saveLikedQuotes(_ quotes: [Quote]) {
        if let data = try? JSONEncoder().encode(quotes) {
            likedQuotesData = data
        }
    }
    
    private func isQuoteBookmarked(_ quote: Quote) -> Bool {
        return getBookmarkedQuotes().contains(where: { $0.id == quote.id })
    }
    
    private func getBookmarkedQuotes() -> [Quote] {
        if let quotes = try? JSONDecoder().decode([Quote].self, from: bookmarkedQuotesData) {
            return quotes
        }
        return []
    }
    
    private func saveBookmarkedQuotes(_ quotes: [Quote]) {
        if let data = try? JSONEncoder().encode(quotes) {
            bookmarkedQuotesData = data
        }
    }
}


@available(iOSApplicationExtension 15.0, *)
struct QuoteDropletWidget: Widget {
    let kind: String = "QuoteDropletWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 16.0, *) {
                QuoteDropletWidgetEntryView(entry: entry, isIntentsActive: false)
            } else {
                // Fallback on earlier versions
            }
        }
        .disableContentMarginsIfNeeded() // Use the extension here
        .configurationDisplayName("Example Widget")
        .description("Note that the color palette and font are customizable.")
        .supportedFamilies([.systemMedium, .systemSmall, .systemLarge, .systemExtraLarge])
    }
}

@available(iOSApplicationExtension 15.0, *)
struct QuoteDropletWidgetWithIntents: Widget {
    let kind: String = "QuoteDropletWidgetWithIntents"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 16.0, *) {
                QuoteDropletWidgetEntryView(entry: entry, isIntentsActive: true)
            } else {
                // Fallback on earlier versions
            }
        }
        .disableContentMarginsIfNeeded() // Use the extension here
        .configurationDisplayName("Example Widget")
        .description("Note that the color palette and font are customizable.")
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
    }
}

struct QuoteDropletWidget_Previews: PreviewProvider {
    static var previews: some View {
        let widgetEntry = SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: Quote(id: 1, text: "Sample Quote", author: "Sample Author", classification: "Sample Classification", likes: 15), widgetColorPaletteIndex: 420, widgetCustomColorPalette: [Color(hex: "1C7C54"), Color(hex: "E2B6CF"), Color(hex: "DEF4C6")], quoteFrequencyIndex: 3, quoteCategory: "All")
        
        
        if #available(iOSApplicationExtension 16.0, *) {
            QuoteDropletWidgetEntryView(entry: widgetEntry, isIntentsActive: false)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        } else {
            // Fallback on earlier versions
        }
    }
}

@available(iOS 16.0, *)
struct LikeQuoteIntent: AppIntent {
    let widgetQuote: Quote
    
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @AppStorage("likedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var likedQuotesData: Data = Data()
    
//    @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
//    private var bookmarkedQuotesData: Data = Data()
    
    @AppStorage("interactions", store: UserDefaults(suiteName: "group.selectedSettings"))
    var interactions = 0
    
    @State private var isLiked: Bool = false
//    @State private var isBookmarked: Bool = false
    @State private var likes: Int = 69 // Change likes to non-optional
    @State private var isLiking: Bool = false // Add state for liking status
    
    init() {
        self.widgetQuote = Quote(id: 1, text: "", author: "", classification: "", likes: 15)
        self._isLiked = State(initialValue: false)
    }
    
    init(quote: Quote) {
        self.widgetQuote = quote
//        self._isBookmarked = State(initialValue: isQuoteBookmarked(widgetQuote))
        self._isLiked = State(initialValue: isQuoteLiked(widgetQuote))
    }
    
    static var title: LocalizedStringResource = "Like Quote Button"
    
    static var description = IntentDescription("Like/Unlike Quote")
    
    func perform() async throws -> some IntentResult {
        likeQuoteAction()
        toggleLike()
        
        return .result()
    }
    
    private func toggleLike() {
        isLiked.toggle()
        
        var likedQuotes = getLikedQuotes()
        if isLiked {
            likedQuotes.append(widgetQuote)
        } else {
            likedQuotes.removeAll { $0.id == widgetQuote.id }
        }
        saveLikedQuotes(likedQuotes)
        
        interactionsIncrease()
    }
    
    private func interactionsIncrease() {
        interactions += 1
    }
    
    private func likeQuoteAction() {
        guard !isLiking else { return }
        isLiking = true
        
        // Check if the quote is already liked
        let isAlreadyLiked = isQuoteLiked(widgetQuote)
        
        // Call the like/unlike API based on the current like status
        if isAlreadyLiked {
            unlikeQuote(quoteID: widgetQuote.id) { updatedQuote, error in
                DispatchQueue.main.async {
                    if let updatedQuote = updatedQuote {
                        // Update likes count
                        self.likes = updatedQuote.likes ?? 15
                    }
                    self.isLiking = false
                }
            }
        } else {
            likeQuote(quoteID: widgetQuote.id) { updatedQuote, error in
                DispatchQueue.main.async {
                    if let updatedQuote = updatedQuote {
                        // Update likes count
                        self.likes = updatedQuote.likes ?? 15
                    }
                    self.isLiking = false
                }
            }
        }
    }
    
    private func isQuoteLiked(_ quote: Quote) -> Bool {
        return getLikedQuotes().contains(where: { $0.id == quote.id })
    }
    
    private func getLikedQuotes() -> [Quote] {
        if let quotes = try? JSONDecoder().decode([Quote].self, from: likedQuotesData) {
            return quotes
        }
        return []
    }
    
    private func saveLikedQuotes(_ quotes: [Quote]) {
        if let data = try? JSONEncoder().encode(quotes) {
            likedQuotesData = data
        }
    }
}
