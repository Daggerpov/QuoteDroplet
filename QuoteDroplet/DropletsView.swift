//
//  DropletsView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-05-18.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

struct DropletsView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0
    
    // actual colors of custom:
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"
    
    @State private var recentQuotes: [Quote] = []
    @State private var currentQuoteIndex: Int = 0
    
    private var singleQuote: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text("Droplets")
                    .font(.title)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                    .padding(.bottom, 5)
                Spacer()
            }
            
            if recentQuotes.isEmpty {
                Text("Loading Quotes ...")
                    .font(.title3)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    .padding(.bottom, 2)
            } else {
                let quote = recentQuotes[currentQuoteIndex]
                VStack {
                    HStack {
                        Text("\"\(quote.text)\"")
                            .font(.title3)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                            .padding(.bottom, 2)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    
                    if let author = (quote.author && quote.author != "Unknown Author" && quote.author != nil && quote.author != "") {
                        HStack {
                            Spacer()
                            Text("— \(author)")
                                .font(.body)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                                .padding(.bottom, 5)
                                .frame(alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    var body: some View {
        VStack {
            AdBannerViewController(adUnitID:
                                                "ca-app-pub-5189478572039689/7801914805") // new, for Droplets
                                        .frame(height: 50)
            Spacer()
            ScrollView {
                GeometryReader { geometry in
                    VStack {
                        singleQuote
                            .onAppear {
                                // Detect scrolling and load next quote if necessary
                                let offset = geometry.frame(in: .global).minY
                                if offset < 200 && currentQuoteIndex < recentQuotes.count - 1 {
                                    currentQuoteIndex += 1
                                }
                            }
                    }
                }
                .frame(height: UIScreen.main.bounds.height) // To make the scroll work properly
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .onAppear {
            // Fetch recent quotes when the view appears
            getRecentQuotes(limit: 3) { quotes, error in
                if let quotes = quotes {
                    recentQuotes = quotes
                } else if let error = error {
                    print("Error fetching recent quotes: \(error)")
                }
            }
            sharedVars.colorPaletteIndex = widgetColorPaletteIndex
            
            colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
            colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
            colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
        }
    }
}
struct DropletsView_Previews: PreviewProvider {
    static var previews: some View {
        DropletsView()
    }
}


