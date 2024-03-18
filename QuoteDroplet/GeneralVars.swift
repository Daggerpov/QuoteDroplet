//
//  GeneralVars.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

import GoogleMobileAds

let notificationPermissionKey = "notificationPermissionGranted"
let notificationToggleKey = "notificationToggleEnabled"
private var scheduledNotificationIDs: Set<String> = Set() // for the quotes shown already
struct ColorPaletteView: View {
    var colors: [Color]
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
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
}
struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
var colorPalettes = [
    [Color(hex: "504136"), Color(hex: "EEC584"), Color(hex: "FE5F55")], // Change third colour (author text) maybe: 68B0AB
    [Color(hex: "85C7F2"), Color(hex: "0C1618"), Color(hex: "83781B")], // Best one, keep as is
    [Color(hex: "EFF8E2"), Color(hex: "DC9E82"), Color(hex: "423E37")], // Change second colour (quote text)
    [Color(hex: "1C7C54"), Color(hex: "E2B6CF"), Color(hex: "DEF4C6")], // Alright
    // New ones added
    [Color(hex: "ffffcc"), Color(hex: "00a968"), Color(hex: "0047ab")], // Khang's, it's good
    [Color(hex: "A0B9C6"), Color(hex: "33658A"), Color(hex: "2F4858")], // Alright
    [Color(hex: "1C7C54"), Color(hex: "E2B6CF"), Color(hex: "DEF4C6")], // Copied from custom
    
]
enum QuoteCategory: String, CaseIterable {
    case wisdom = "Wisdom"
    case motivation = "Motivation"
    case discipline = "Discipline"
    case philosophy = "Philosophy"
    case inspiration = "Inspiration"
    case upliftment = "Upliftment"
    case love = "Love"
    case all = "All"
    var displayName: String {
        return self.rawValue
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.gray.opacity(0.5) : Color.clear)
            .cornerRadius(8)
            .border(configuration.isPressed ? Color.clear : Color.blue, width: 2)
    }
}


// UIViewControllerRepresentable wrapper for AdMob banner view
struct AdBannerViewController: UIViewControllerRepresentable {
    let adUnitID: String

    func makeUIViewController(context: Context) -> UIViewController {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner) // Use a predefined ad size
        bannerView.adUnitID = adUnitID
        
        let viewController = UIViewController()
        viewController.view.addSubview(bannerView)
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        bannerView.load(GADRequest())
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
