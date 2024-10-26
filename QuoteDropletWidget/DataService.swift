//
//  DataService.swift
//  QuoteDropletWidgetExtension
//
//  Created by Daniel Agapov on 2023-08-31.
//

import Foundation
import SwiftUI

struct DataService {
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"
    
    func getColorPalette() -> [Color] {
        return [
            widgetCustomColorPaletteFirstIndex,
            widgetCustomColorPaletteSecondIndex,
            widgetCustomColorPaletteThirdIndex
        ].map { Color(hex: $0) }
    }
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetColorPaletteIndex = 0
    
    func getIndex() -> Int {
        return widgetColorPaletteIndex
    }
    
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var quoteCategory = QuoteCategory.all

    func getQuoteCategory() -> QuoteCategory {
        return quoteCategory
    }

    @AppStorage("quoteFrequencySelected", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var quoteFrequencySelected = QuoteFrequencyOption.oneDay

    func getQuoteFrequencySelected() -> QuoteFrequencyOption {
        return quoteFrequencySelected
    }

    // Add @AppStorage property for selectedFontIndex
    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0
}
