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
    @State private var isLoadingMore: Bool = false
    
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
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack {
                        ForEach(recentQuotes.indices, id: \.self) { index in
                            if index == currentQuoteIndex {
                                singleQuote
                                    .id(index)
                                    .onAppear {
                                        if index == recentQuotes.count - 1 && !isLoadingMore {
                                            loadMoreQuotes()
                                        }
                                    }
                            }
                        }
                    }
                    .background(GeometryReader {
                        Color.clear.preference(key: ViewOffsetKey.self, value: $0.frame(in: .global).minY)
                    })
                    .onPreferenceChange(ViewOffsetKey.self) { offset in
                        if offset < 200 {
                            if currentQuoteIndex < recentQuotes.count - 1 {
                                withAnimation {
                                    currentQuoteIndex += 1
                                    scrollView.scrollTo(currentQuoteIndex, anchor: .top)
                                }
                            }
                        }
                    }
                }
                .frame(height: UIScreen.main.bounds.height)
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
    
    private func loadMoreQuotes() {
        isLoadingMore = true
        getRecentQuotes(limit: 3) { newQuotes, error in
            if let newQuotes = newQuotes {
                recentQuotes.append(contentsOf: newQuotes)
            } else if let error = error {
                print("Error fetching more quotes: \(error)")
            }
            isLoadingMore = false
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


