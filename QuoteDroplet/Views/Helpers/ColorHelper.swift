//
//  ColorHelper.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-20.
//

import SwiftUI

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
    // first row (of 4):
    [Color(hex: "504136"), Color(hex: "EEC584"), Color(hex: "F8F3E1")],
    [Color(hex: "85C7F2"), Color(hex: "0C1618"), Color(hex: "83781B")],
    [Color(hex: "EFF8E2"), Color(hex: "DC9E82"), Color(hex: "423E37")],
    // custom one:
    [Color(hex: "1C7C54"), Color(hex: "E2B6CF"), Color(hex: "DEF4C6")],
    
    [Color(hex: "001427"), Color(hex: "EDD4B2"), Color(hex: "D0A98F")],
   
    // second row (of 4):
    [Color(hex: "242434"), Color(hex: "F79256"), Color(hex: "F0EFF4")],
    [Color(hex: "A0B9C6"), Color(hex: "33658A"), Color(hex: "2F4858")],
    [Color(hex: "39474F"), Color(hex: "E7F3F1"), Color(hex: "DEAABE")],
    [Color(hex: "2A2E40"), Color(hex: "DADFE3"), Color(hex: "909AAB")],
]
