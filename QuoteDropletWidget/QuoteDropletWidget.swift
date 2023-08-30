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

        // Fetch a new quote based on the selected category
        let selectedCategory = UserDefaults(suiteName: "group.com.your.app.group")?.string(forKey: "selectedCategory") ?? "all"
        getRandomQuoteByClassification(classification: selectedCategory) { quote, error in
            if let quote = quote {
                let entry = SimpleEntry(date: startDate, configuration: configuration, quote: quote)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            } else {
                let entry = SimpleEntry(date: startDate, configuration: configuration, quote: nil)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        }
        
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

    var body: some View {
        VStack {
            if let quote = entry.quote {
                Text(quote.text)
                    .font(.headline)
                if let author = quote.author {
                    Text("- \(author)")
                        .font(.subheadline)
                }
            } else {
                Text("Issue retrieving quote...")
                    .foregroundColor(.red)
            }
        }
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
