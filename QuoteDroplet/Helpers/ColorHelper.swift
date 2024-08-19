//
//  ColorHelper.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-20.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation
import GoogleMobileAds

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
    var hex: String {
        guard let components = cgColor?.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

var colorPalettes = [
    [Color(hex: "504136"), Color(hex: "EEC584"), Color(hex: "F8F3E1")],
    [Color(hex: "85C7F2"), Color(hex: "0C1618"), Color(hex: "83781B")], // Best one, keep as is
    [Color(hex: "EFF8E2"), Color(hex: "DC9E82"), Color(hex: "423E37")], // Change second colour (quote text)
    [Color(hex: "1C7C54"), Color(hex: "E2B6CF"), Color(hex: "DEF4C6")], // Alright
    
    // New ones added
    [Color(hex: "#242434"), Color(hex: "#F79256"), Color(hex: "#F0EFF4")], // 4th (similar to Colombia flag colors), from playing around
    [Color(hex: "A0B9C6"), Color(hex: "33658A"), Color(hex: "2F4858")], // Alright
    [Color(hex: "39474F"), Color(hex: "E7F3F1"), Color(hex: "DEAABE")], // New one
    // Could also try: E2856E, 03312E, 070707, 564138, 931621, C1292E (lighter than prev red, 931621)
    
]

struct ColorPaletteView: View {
    var colors: [Color]
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}
