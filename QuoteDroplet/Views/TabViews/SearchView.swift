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
    
    // for top UI stuff:
    @State private var activeCategory: QuoteCategory = .all
    @Namespace private var animation
    
    let localQuotesService: LocalQuotesService
    let apiService: APIService

    init(localQuotesService: LocalQuotesService, apiService: APIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView(.vertical) {
                    LazyVStack(spacing: 15) {
                        if searchText != "" {
                            ForEach(quotes.indices, id: \.self) { index in
                                if let quote = quotes[safe: index] {
                                    SingleQuoteView(quote: quote, searchText: searchText, localQuotesService: localQuotesService, apiService: apiService)
                                }
                            }
                        } else {
                            DummyQuotesView()
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
                        loadQuotesBySearch(searchText: searchText, searchCategory: activeCategory.rawValue.lowercased())
                    }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(height: 45)
            .background{
                RoundedRectangle(cornerRadius: 25).fill(.background)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(QuoteCategory.allCases, id: \.rawValue) { category in
                        Button(action: {
                            withAnimation(.snappy) {
                                activeCategory = category
                            }
                            
                        }) {
                            Text(category.rawValue)
                                .font(.callout)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .blue)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 15)
                                .background {
                                    if activeCategory == category {
                                        Capsule()
                                            .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                            .matchedGeometryEffect(id: "ACTIVECATEGORY", in: animation)
                                    } else {
                                        Capsule()
                                            .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        
                    }
                }
                .onChange(of: activeCategory) { _ in
                    loadQuotesBySearch(searchText: searchText, searchCategory: activeCategory.rawValue.lowercased())
                }
                .padding(.top, 10)
            }
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 20)
        
    }
    
    // Dummy Quotes View
    @ViewBuilder
    func DummyQuotesView() -> some View {
        ForEach(0..<20, id: \.self) { _ in
            VStack {
                HStack {
                    VStack {
                        HStack {
                            Rectangle().frame(width: CGFloat(Int.random(in: 200..<250)), height:9.5)
                                .font(.title3)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                .padding(.bottom, 2)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        
                        HStack{
                            Rectangle().frame(width: CGFloat(Int.random(in: 40..<130)), height:9.5)
                                .font(.title3)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                .padding(.bottom, 2)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        
                        HStack{
                            Rectangle().frame(width: CGFloat(Int.random(in: 40..<130)), height:9.5)
                                .font(.title3)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                .padding(.bottom, 2)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        
                    }
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    Text("— ")
                        .font(.body)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                        .padding(.bottom, 5)
                        .frame(alignment: .trailing)
                    Rectangle().frame(width: CGFloat(Int.random(in: 70..<150)), height: 9.5)
                        .font(.body)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                        .padding(.bottom, 5)
                        .frame(alignment: .trailing)
                }
            }
            .padding()
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
    }
    
    private func loadQuotesBySearch(searchText: String = "", searchCategory: String = QuoteCategory.all.rawValue) {
        guard !isLoadingMore else { return }
        
        self.quotes = []
        
        isLoadingMore = true
        let group = DispatchGroup()
        
        apiService.getQuotesBySearchKeyword(searchKeyword: searchText, searchCategory: searchCategory) {quotes, error in
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
        SearchView(localQuotesService: LocalQuotesService(), apiService: APIService())
    }
}
