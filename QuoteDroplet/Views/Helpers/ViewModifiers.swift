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
struct DropletsPageTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            .padding()
            .frame(alignment: .center)
            .multilineTextAlignment(.center)
    }
}
struct DummyQuoteTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            .padding(.bottom, 2)
            .frame(alignment: .leading)
    }
}

struct DummyQuoteAuthorTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
            .padding(.bottom, 5)
            .frame(alignment: .trailing)
    }
}

struct MainScreenBackgroundStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
    }
}

struct QuoteInteractionButtonStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.title)
            .scaleEffect(1)
            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
    }
}
