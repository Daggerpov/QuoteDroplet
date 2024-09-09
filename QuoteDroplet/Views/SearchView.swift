//
//  SearchView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-09-08.
//

import Foundation
import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import StoreKit
import UniformTypeIdentifiers

@available(iOS 16.0, *)
struct SearchView: View {
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
    @State private var searchText: String = ""
    @State private var isLoadingMore: Bool = false
   
    private let quotesPerPage = 5
    
    private let maxQuotes = 10
    
    @State private var totalQuotesLoaded = 0
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView(.vertical) {
                    LazyVStack(spacing: 15) {
                        ForEach(quotes.indices, id: \.self) { index in
                            if let quote = quotes[safe: index] {
                                SingleQuoteView(quote: quote, searchText: searchText)
                                // likely an issue with using the indices ->
                                // that's what's causing the
                                /*https://stackoverflow.com/questions/78737833/instance-of-struct-affecting-anothers-state*/
                            }
                        }
                        
                    }
                    //            .safeAreaPadding(15)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        ExpandableSearchBar()
                    }
                }
                AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/1609477369")                    .frame(height: 50)
                    .padding(.bottom, 10)
            }
            
            .frame(maxWidth: .infinity)
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
            .onAppear() {
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
            }
        }
    }
    
    @ViewBuilder
    func ExpandableSearchBar(_ title: String = "Quote Search") -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                .padding(.bottom, 5)
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass").font(.title3)
                TextField("Search Quotes by Keyword", text: $searchText)
                    .onChange(of: searchText) { _ in
                        loadQuotesBySearch(searchText: searchText)
                    }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(height: 45)
            .background{
                RoundedRectangle(cornerRadius: 25).fill(.background)
            }
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
        
    }
    
    private func loadQuotesBySearch(searchText: String = "") {
        guard !isLoadingMore else { return }
        
        self.quotes = []
        
        isLoadingMore = true
        let group = DispatchGroup()
        
        getQuotesBySearchKeyword(searchKeyword: searchText) {quotes, error in
            if let error = error {
                print("Error fetching quotes: \(error)")
                return
            }
            
            guard let quotes = quotes else {
                print("No quotes found.")
                return
            }
            
            let quotesToAppend = quotes.prefix(quotesPerPage)
            
            for quote in quotesToAppend {
                DispatchQueue.main.async {
                    if !self.quotes.contains(where: { $0.id == quote.id }) {
                        self.quotes.append(quote)
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.isLoadingMore = false
            self.totalQuotesLoaded += self.quotesPerPage
        }
    }
}

@available(iOS 16.0, *)
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
