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
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: Quote(id: 1, text: "Default Quote", author: nil, classification: nil))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, quote: Quote(id: 1, text: "Default Quote", author: nil, classification: nil))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        var fetchedQuoteCount = 0  // Track the number of fetched quotes

        for minuteOffset in 0 ..< 5 {  // Fetch 5 quotes, one every minute
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!

            // Fetch a new quote here
            getRandomQuoteByClassification(classification: "all") { quote, error in
                fetchedQuoteCount += 1

                if let quote = quote {
                    Swift.print("Fetched quote: \(quote)") // Print the fetched quote
                    let entry = SimpleEntry(date: entryDate, configuration: configuration, quote: quote)
                    entries.append(entry)
                }else {
                    Swift.print("no quote")
                }

                if fetchedQuoteCount == 5 {  // Check if you've fetched quotes for all 5 entries
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                }
            }
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
                Text("Loading quote...")
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
        .onBackgroundURLSessionEvents { (sessionIdentifier, completionHandler) in
            // Handle background URL session events if needed
        }
    }
}

struct QuoteDropletWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuoteDropletWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: Quote(id: 1, text: "Default Quote", author: nil, classification: nil)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
