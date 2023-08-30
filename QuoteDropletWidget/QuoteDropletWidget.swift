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
        let entryDate = Calendar.current.date(byAdding: .minute, value: 0, to: currentDate)!
        
        // Retrieve the selected category from user defaults
        let selectedCategory = UserDefaults(suiteName: "group.com.your.app.group")?.string(forKey: "selectedCategory") ?? "all"
        
        // Fetch a new quote based on the selected category
        getRandomQuoteByClassification(classification: selectedCategory) { quote, error in
            if let quote = quote {
                let entry = SimpleEntry(date: entryDate, configuration: configuration, quote: quote)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            } else {
                let entry = SimpleEntry(date: entryDate, configuration: configuration, quote: nil)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
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
    }
}
struct QuoteDropletWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuoteDropletWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: Quote(id: 1, text: "Sample Quote", author: "Sample Author", classification: "Sample Classification")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
