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
    
    @State private var quotes: [Quote] = []
    @State private var isLoadingMore: Bool = false
    @State private var lastLoadedIndex: Int = 0
    
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
            
            if let quote = quotes[safe: lastLoadedIndex] {
                VStack {
                    HStack {
                        Text("\"\(quote.text)\"")
                            .font(.title3)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                            .padding(.bottom, 2)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    
                    if let author = quote.author, author != "Unknown Author", !author.isEmpty {
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
            } else {
                Text("Loading Quotes ...")
                    .font(.title3)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    .padding(.bottom, 2)
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
            AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/7801914805")
                .frame(height: 50)
            Spacer()
            ScrollView {
                VStack {
                    ForEach(quotes.indices, id: \.self) { index in
                        singleQuote
                            .id(index)
                            .onAppear {
                                if index == quotes.count - 1 && !isLoadingMore {
                                    loadMoreQuotes()
                                }
                            }
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.height)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .onAppear {
            // Fetch initial quote when the view appears
            loadInitialQuotes()
            sharedVars.colorPaletteIndex = widgetColorPaletteIndex
            
            colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
            colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
            colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
        }
    }
    
    private func loadInitialQuotes() {
        loadMoreQuotes() // Initial load
    }
    
    private func loadMoreQuotes() {
        isLoadingMore = true
        getRandomQuoteByClassification(classification: "all") { quote, error in
            if let quote = quote {
                DispatchQueue.main.async {
                    quotes.append(quote)
                    isLoadingMore = false
                }
            } else if let error = error {
                print("Error fetching more quotes: \(error)")
                isLoadingMore = false
            }
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DropletsView_Previews: PreviewProvider {
    static var previews: some View {
        DropletsView()
    }
}
