//
//  DataService.swift
//  QuoteDropletWidgetExtension
//
//  Created by Daniel Agapov on 2023-08-31.
//

import Foundation
import SwiftUI

struct DataService {
    @AppStorage("colorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var colorPaletteIndex = 0
    
    func getIndex() -> Int {
        return colorPaletteIndex
    }
    
    @AppStorage("quoteFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var quoteFrequencyIndex = 3
    
    func getQuoteFrequencyIndex() -> Int {
        return quoteFrequencyIndex
    }
    
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var quoteCategory = "all"
    
    func getQuoteCategory() -> String {
        return quoteCategory
    }
    
    // Add @AppStorage property for selectedFontIndex
    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0
}
