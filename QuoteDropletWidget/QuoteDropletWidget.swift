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
                return 50
            case .systemLarge:
                return 150
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
        if let author = author, !author.isEmpty {
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
        if let author = author, !author.isEmpty {
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

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let quote: Quote?  // Include the fetched quote here
    let colorPaletteIndex: Int
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
                        .foregroundColor(colors[1]) // Use the second color for text color
                        .padding(.horizontal, 5)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                    if quote.author != "Unknown Author" {
                        Text("- \(quote.author ?? "")")
                            .font(.subheadline)
                            .foregroundColor(colors[2]) // Use the third color for author text color
                            .padding(.horizontal, 5)
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
                            .lineLimit(1) // Ensure the author text is limited to one line
                            .minimumScaleFactor(0.5) // Allow author text to scale down if needed
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
                            .lineLimit(1) // Ensure the author text is limited to one line
                            .minimumScaleFactor(0.5) // Allow author text to scale down if needed
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
        .disableContentMarginsIfNeeded() // Use the extension here
        .configurationDisplayName("Example Widget")
        .description("Note that the color palette is modifiable.")
        .supportedFamilies([.systemMedium, .systemSmall])
    }
}

struct QuoteDropletWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuoteDropletWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: Quote(id: 1, text: "Sample Quote", author: "Sample Author", classification: "Sample Classification"), colorPaletteIndex: 420, quoteFrequencyIndex: 3, quoteCategory: "all"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
