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
    
    // TODO: Add frequency
    
    // TODO: Add quote category
}
