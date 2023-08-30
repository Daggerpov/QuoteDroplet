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

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: nil)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, quote: nil)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()

        // Define the start date for the timeline
        let startDate = Calendar.current.date(byAdding: .second, value: 0, to: currentDate)!

        // Fetch quotes until a suitable one is found
        func fetchQuote() {
            let selectedCategory = UserDefaults(suiteName: "com.Daggerpov.QuoteDroplet")?.string(forKey: "selectedCategory") ?? "all"
            getRandomQuoteByClassification(classification: selectedCategory) { quote, error in
                if let quote = quote, !isQuoteTooLong(text: quote.text, context: context) {
                    let entry = SimpleEntry(date: startDate, configuration: configuration, quote: quote)
                    let timeline = Timeline(entries: [entry], policy: .atEnd)
                    completion(timeline)
                } else {
                    fetchQuote() // Try again if the quote is too long
                }
            }
        }
        fetchQuote()
    }

    // Helper function to check if a quote is too long
    private func isQuoteTooLong(text: String, context: Context) -> Bool {
        let maxWidth: CGFloat = {
            switch context.family {
            case .systemSmall:
                return 100 // Adjust as needed
            case .systemMedium:
                return 150 // Adjust as needed
            case .systemLarge:
                return 200 // Adjust as needed
            case .systemExtraLarge:
                return 250 // Adjust as needed
            case .accessoryCircular:
                return 120 // Adjust as needed for circular widgets
            case .accessoryRectangular:
                return 180 // Adjust as needed for rectangular widgets
            case .accessoryInline:
                return 100 // Adjust as needed for inline widgets
            @unknown default:
                return 100
            }
        }()

        
        let font = UIFont.systemFont(ofSize: 17) // Use an appropriate font size
        let boundingBox = text.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return boundingBox.height > 100 // Adjust the maximum height as needed
    }


    // Helper function to convert selected frequency index to seconds
    private func getFrequencyInSeconds(for index: Int) -> Int {
        switch index {
        case 0: return 30 // 30 sec
        case 1: return 600  // 10 minutes
        case 2: return 3600 // 1 hour
        case 3: return 7200 // 2 hours
        case 4: return 14400 // 4 hours
        case 5: return 28800 // 8 hours
        case 6: return 86400 // 1 day
        default: return 7200
        }
    }
}
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let quote: Quote?  // Include the fetched quote here
}

struct QuoteDropletWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var colors: [Color] {
        let selectedPaletteIndex = UserDefaults(suiteName: "com.Daggerpov.QuoteDroplet")?.integer(forKey: "selectedPaletteIndex") ?? 0
        return colorPalettes[safe: selectedPaletteIndex] ?? [Color.clear]
    }

    var body: some View {
        ZStack {
            colors[0] // Use the first color as the background color
            
            VStack {
                if let quote = entry.quote {
                    Text(quote.text)
                        .font(.headline)
                        .foregroundColor(colors[1]) // Use the second color for text color
                        .padding(.horizontal, 5)
                    if let author = quote.author {
                        Text("- \(author)")
                            .font(.subheadline)
                            .foregroundColor(colors[2]) // Use the third color for author text color
                            .padding(.horizontal, 5)
                    }
                } else {
                    Text("Issue retrieving quote...")
                        .foregroundColor(.red)
                }
            }
        }
        .widgetURL(URL(string: "yourapp://widget-tap")) // Change "yourapp" to your app's scheme
    }
}

struct QuoteDropletWidget: Widget {
    let kind: String = "QuoteDropletWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QuoteDropletWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
}
struct QuoteDropletWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuoteDropletWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: Quote(id: 1, text: "Sample Quote", author: "Sample Author", classification: "Sample Classification")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
