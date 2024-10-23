//
//  ColorPaletteView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

struct ColorPaletteView: View {
    var colors: [Color]
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}
