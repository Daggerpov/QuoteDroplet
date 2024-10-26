//
//  TimeIntervalPicker.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-25.
//

import Foundation
import SwiftUI
import WidgetKit

struct TimeIntervalPicker: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @AppStorage("quoteFrequencySelected", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencySelected: QuoteFrequency = QuoteFrequency.oneDay

    private var renderPickerSelections: some View {
        ForEach(QuoteFrequency.allCases, id: \.rawValue) { frequencyOption in
            Text("Every \(frequencyOption.displayName)")
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
        }
    }

    private var headerText: some View {
        Text("Reload Widget:")
            .font(.headline)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            .padding(.horizontal, 5)
    }

    private var picker: some View {
        Picker("", selection: $quoteFrequencySelected) {
            renderPickerSelections
        }
        .pickerStyle(MenuPickerStyle())
        .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
        .onChange(of: quoteFrequencySelected) { _ in
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
        }
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
            )
    }

    var body: some View {
        HStack {
            headerText
            HStack {
                picker
            }
        }
        .padding(10)
        .background(background)
    }
}
