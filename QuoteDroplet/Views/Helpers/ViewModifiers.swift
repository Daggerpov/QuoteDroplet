//
//  ViewModifiers.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-25.
//

import SwiftUI
import Foundation


struct DatePickerStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
        .datePickerStyle(WheelDatePickerStyle())
        .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
        .padding()
        .scaleEffect(1.25)
    }
}

