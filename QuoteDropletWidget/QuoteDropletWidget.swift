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
    var data = DataService()
    
    func placeholder(in context: Context) -> SimpleEntry {
        let defaultQuote = Quote(id: 1, text: "More is lost by indecision than by wrong decision.", author: "Cicero", classification: "Sample Classification")
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: defaultQuote, colorPaletteIndex: data.getIndex(), quoteFrequencyIndex: data.getQuoteFrequencyIndex(), quoteCategory: data.getQuoteCategory())
    }


    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, quote: nil, colorPaletteIndex: data.getIndex(), quoteFrequencyIndex: data.getQuoteFrequencyIndex(), quoteCategory: data.getQuoteCategory())
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let startDate = Calendar.current.date(byAdding: .second, value: 0, to: currentDate)!
        
        // Calculate the frequency in seconds based on the selected index
        let frequencyInSeconds = getFrequencyInSeconds(for: data.getQuoteFrequencyIndex())
        
        // Schedule the next update based on the calculated frequency
        let nextUpdate = Calendar.current.date(byAdding: .second, value: frequencyInSeconds, to: startDate)!
        
        // Fetch the initial quote
        getRandomQuoteByClassification(classification: data.getQuoteCategory().lowercased()) { quote, error in
            if let quote = quote, !isQuoteTooLong(text: quote.text, context: context, author: quote.author) {
                let entry = SimpleEntry(date: nextUpdate, configuration: configuration, quote: quote, colorPaletteIndex: data.getIndex(), quoteFrequencyIndex: data.getQuoteFrequencyIndex(), quoteCategory: data.getQuoteCategory())
                
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }

    // Helper function to check if a quote is too long
    private func isQuoteTooLong(text: String, context: Context, author: String?) -> Bool {
        let maxWidth: CGFloat = {
            switch context.family {
            case .systemSmall:
                return 100 // Adjust as needed
            case .systemMedium:
                return 150 // Adjust as needed for .systemMedium
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
        
        let maxHeight: CGFloat = {
            switch context.family {
            case .systemSmall:
                return 100 // Adjust as needed
            case .systemMedium:
                return 200 // Adjust as needed for .systemMedium
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
            with: CGSize(width: maxWidth, height: maxHeight), // Use maxHeight for .systemMedium
            options: [.usesLineFragmentOrigin],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )

        // Check if the quote has an author
        if let author = author, !author.isEmpty {
            return boundingBox.height > maxHeight // Adjust the maximum height as needed
        } else {
            // Allow the quote to be 10% longer when there is no author
            let maxAllowedHeight = maxHeight * 1.1 // 10% longer than maxHeight
            return boundingBox.height > maxAllowedHeight
        }
    }
}

// Helper function to convert selected frequency index to seconds
public func getFrequencyInSeconds(for index: Int) -> Int {
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

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let quote: Quote?  // Include the fetched quote here
    let colorPaletteIndex: Int
    let quoteFrequencyIndex: Int
    let quoteCategory: String
}

struct QuoteDropletWidgetEntryView : View {
    var data = DataService()
    
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var colors: [Color] {
        return colorPalettes[safe: data.getIndex()] ?? [Color.clear]
    }
    
    var isLoading: Bool {
        return entry.quote == nil
    }

    var body: some View {
        ZStack {
            colors[0] // Use the first color as the background color
            
            VStack {
                if let quote = entry.quote {
                    Text(quote.text)
                        .font(.headline)
                        .foregroundColor(colors[1])
                        .multilineTextAlignment(.center)
                        .lineSpacing(4) // Add line spacing for readability
                        .minimumScaleFactor(0.5) // Allow text to scale down if needed
                        .padding(.horizontal, 20) // Adjust horizontal padding
                        .padding(.vertical, 10) // Adjust vertical padding
                        .frame(maxHeight: .infinity) // Allow the text to expand vertically
                    Spacer() // Add a spacer to push the author text to the center
                    if quote.author != "Unknown Author" {
                        Text("- \(quote.author ?? "")")
                            .font(.subheadline)
                            .foregroundColor(colors[2])
                            .padding(.horizontal, 20) // Adjust horizontal padding
                            .padding(.bottom, 10) // Adjust bottom padding
                    }
                } else {
                    if family == .systemMedium {
                        Text("Our anxiety does not come from thinking about the future, but from wanting to control it.")
                            .font(.headline)
                            .foregroundColor(colors[1])
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .minimumScaleFactor(0.5)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .frame(maxHeight: .infinity)
                        Spacer() // Add a spacer to push the author text to the center
                        Text("- Khalil Gibran")
                            .font(.subheadline)
                            .foregroundColor(colors[2])
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                    } else {
                        Text("More is lost by indecision than by wrong decision.")
                            .font(.headline)
                            .foregroundColor(colors[1])
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .minimumScaleFactor(0.5)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .frame(maxHeight: .infinity)
                        Spacer() // Add a spacer to push the author text to the center
                        Text("- Cicero")
                            .font(.subheadline)
                            .foregroundColor(colors[2])
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                    }
                }
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
        .configurationDisplayName("Example Widget")
        .description("Note that the color palette is modifiable.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct QuoteDropletWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuoteDropletWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: Quote(id: 1, text: "Sample Quote", author: "Sample Author", classification: "Sample Classification"), colorPaletteIndex: 420, quoteFrequencyIndex: 3, quoteCategory: "all"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
