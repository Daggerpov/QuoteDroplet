//
//  AuthorView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-21.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation
import StoreKit

struct AuthorView: View {
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
    private let quotesPerPage = 5
    @State private var totalQuotesLoaded = 0
    
    private let maxQuotes = 100
    
    let quote: Quote // given when made
    
    var body: some View {
        NavigationView {
            VStack {
                AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/9761642936")
                    .frame(height: 60)
                
                Spacer()
                ScrollView {
                    Spacer()
                    LazyVStack{
                        HStack {
                            Spacer()
                            Text("Quotes by \(quote.author ?? "Author"):")
                                .font(.title)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                .padding(.bottom, 5)
                            
                            Spacer()
                        }
                        Spacer()
                        if quotes.isEmpty {
                            Text("Loading Quotes...")
                                .font(.title2)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                .padding(.bottom, 5)
                                .frame(alignment: .center)
                        } else {
                            ForEach(quotes.indices, id: \.self) { index in
                                if let quote = quotes[safe: index] {
                                    if #available(iOS 16.0, *) {
                                        SingleQuoteView(quote: quote)
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                }
                            }
                        }
                        Color.clear.frame(height: 1)
                            .onAppear {
                                if !isLoadingMore && quotes.count < maxQuotes {
                                    loadMoreQuotes()
                                }
                            }
                        
                        
                        
                        if !isLoadingMore {
                            if (quotes.count >= maxQuotes) {
                                Text("You've reached the quote limit of \(maxQuotes). Maybe take a break?")
                                    .font(.title2)
                                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
            .onAppear {
                // Fetch initial quotes when the view appears
                loadInitialQuotes()
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
            }
        }
    }
    
    private func loadInitialQuotes() {
        totalQuotesLoaded = 0
        loadMoreQuotes() // Initial load
    }
    
    private func loadMoreQuotes() {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        let group = DispatchGroup()
        
        for index in 0..<quotesPerPage {
            group.enter()
            getQuoteByAuthorAndIndex(author: quote.author!, index: index) { quote, error in
                if let quote = quote, !self.quotes.contains(where: { $0.id == quote.id }) {
                    DispatchQueue.main.async {
                        self.quotes.append(quote)
                    }
                }
                group.leave()
            }
        }
        
        
        group.notify(queue: .main) {
            self.isLoadingMore = false
            self.totalQuotesLoaded += self.quotesPerPage
        }
    }
}
