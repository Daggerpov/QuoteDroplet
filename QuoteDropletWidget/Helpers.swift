//
//  Helpers.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-25.
//

import Foundation

// Helper function to convert selected quote frequency to seconds
private func getFrequencyInSeconds(quoteFrequency: QuoteFrequency) -> Int {
    switch quoteFrequency {
        case .eightHours: return 28800
        case .twelveHours: return 43200
        case .oneDay: return 86400
        case .twoDays: return 172800
        case .fourDays: return 345600
        case .oneWeek: return 604800
    }
}

@available(iOS 16.0, *)
private func getFontSizeForText(familia: WidgetFamily, whichText: TextSize) -> CGFloat {
    if (whichText == .quoteText) {
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
