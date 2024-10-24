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
import StoreKit
import UniformTypeIdentifiers

@available(iOS 16.0, *)
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
    @State private var savedQuotes: [Quote] = []
    @State private var recentQuotes: [Quote] = []
    
    @State private var isLoadingMore: Bool = false
    private let quotesPerPage = 5
    
    @State private var totalQuotesLoaded = 0
    @State private var totalSavedQuotesLoaded = 0
    @State private var totalRecentQuotesLoaded = 0
    
    @State private var selected = 1
    
    private let maxQuotes = 15
    
    let localQuotesService: LocalQuotesService
    let apiService: APIService
    
    init(localQuotesService: LocalQuotesService, apiService: APIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    private var topNavBar: some View {
        Picker(selection: $selected, label: Text("Picker"), content: {
            Text("Feed").tag(1)
            Text("Saved").tag(2)
            Text("Recent").tag(3)
        })
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var titles: some View {
        HStack {
            Spacer()
            if selected == 1 {
                Text("Quotes Feed")
                    .font(.largeTitle.bold())
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                    .padding(.bottom, 5)
            } else if selected == 2 {
                Text("Saved Quotes")
                    .font(.largeTitle.bold())
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                    .padding(.bottom, 5)
            } else {
                Text("Recent Quotes")
                    .font(.largeTitle.bold())
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                    .padding(.bottom, 5)
            }
            Spacer()
        }
    }
    
    private var quotesListView: some View {
        ScrollView {
            Spacer()
            LazyVStack{
                titles
                Spacer()
                if selected == 1{
                    if quotes.isEmpty {
                        Text("Loading Quotes Feed...")
                            .font(.title2)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                            .padding(.bottom, 5)
                            .frame(alignment: .center)
                    } else {
                        ForEach(quotes.indices, id: \.self) { index in
                            if let quote = quotes[safe: index] {
                                SingleQuoteView(quote: quote, localQuotesService: localQuotesService, apiService: apiService)
                                // likely an issue with using the indices ->
                                // that's what's causing the
                                /*https://stackoverflow.com/questions/78737833/instance-of-struct-affecting-anothers-state*/
                            }
                        }
                    }
                    
                } else if selected == 2 {
                    if savedQuotes.isEmpty {
                        Text("You have no saved quotes. \n\nPlease save some from the Quotes Feed by pressing this:")
                            .font(.title2)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                            .padding()
                            .frame(alignment: .center)
                            .multilineTextAlignment(.center)
                        Image(systemName: "bookmark")
                            .font(.title)
                            .scaleEffect(1)
                            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                    } else {
                        ForEach(savedQuotes.indices, id: \.self) { index in
                            if let quote = savedQuotes[safe: index] {
                                SingleQuoteView(quote: quote, localQuotesService: localQuotesService, apiService: apiService)
                            }
                        }
                    }
                } else if selected == 3 {
                    
                    if recentQuotes.isEmpty {
//                        Text("You have no recent quotes. \n\nBe sure to add the Quote Droplet widget and/or enable notifications to see them listed here.")
                        Text("You have no recent quotes. \n\nBe sure to enable notifications to see them listed here.")
                            .font(.title2)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                            .padding()
                            .frame(alignment: .center)
                            .multilineTextAlignment(.center)
                        Spacer()
                        Text("Quotes shown from the app's widget will appear here soon. Stay tuned for that update.")
                            .font(.title2)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                            .padding()
                            .frame(alignment: .center)
                            .multilineTextAlignment(.center)
                        // TODO: add apple widget help link here
                    } else {
                        Text("These are your most recent quotes from notifications.")
                            .font(.title2)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                            .padding()
                            .frame(alignment: .center)
                            .multilineTextAlignment(.center)
                        ForEach(recentQuotes.indices.reversed(), id: \.self) { index in
                            if let quote = recentQuotes[safe: index] {
                                SingleQuoteView(quote: quote, localQuotesService: localQuotesService, apiService: apiService)
                            }
                        }
                    }
                }
                
                if selected == 1{
                    Color.clear.frame(height: 1)
                        .onAppear {
                            if !isLoadingMore && quotes.count < maxQuotes {
                                loadMoreQuotes()
                            }
                        }
                } else if selected == 2 {
                    Color.clear.frame(height: 1)
                        .onAppear {
                            if !isLoadingMore && savedQuotes.count < maxQuotes {
                                loadMoreQuotes()
                            }
                        }
                } else if selected == 3 {
                    Color.clear.frame(height: 1)
                        .onAppear {
                            if !isLoadingMore && recentQuotes.count < maxQuotes {
                                loadMoreQuotes()
                            }
                        }
                }
                if !isLoadingMore {
                    if (selected == 1 && quotes.count >= maxQuotes) || (selected == 2 && savedQuotes.count >= maxQuotes) || (selected == 3 && recentQuotes.count >= maxQuotes){
                        Text("You've reached the quote limit of \(maxQuotes). Maybe take a break?")
                            .font(.title2)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                            .padding()
                            .frame(alignment: .center)
                            .multilineTextAlignment(.center)
                    }
                }
                Spacer()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
                VStack{
                    topNavBar
                    Spacer()
                    quotesListView
                }
                .padding()
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
                
                // Schedule notifications:
                // will schedule with previous date and category values
                NotificationScheduler.shared.scheduleNotifications()
            }
            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                .onEnded { value in
                    //                    print(value.translation)
                    switch(value.translation.width, value.translation.height) {
                    case (...0, -30...30):
                        //                    print("left swipe")
                        selected += 1
                    case (0..., -30...30):
                        //                    print("right swipe")
                        selected -= 1
                        //                    case (-100...100, ...0):  /*print("up swipe")*/
                        //                    case (-100...100, 0...):  /*print("down swipe")*/
                    default: break
                    }
                }
            )
        }
    }
    
    private func loadInitialQuotes() {
        totalQuotesLoaded = 0
        totalSavedQuotesLoaded = 0
        totalRecentQuotesLoaded = 0
        loadMoreQuotes() // Initial load
    }
    
    private func loadMoreQuotes() {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        let group = DispatchGroup()
        
        if selected == 1 {
            for _ in 0..<quotesPerPage {
                group.enter()
                apiService.getRandomQuoteByClassification(classification: "all") { quote, error in
                    if let quote = quote, !self.quotes.contains(where: { $0.id == quote.id }) {
                        DispatchQueue.main.async {
                            self.quotes.append(quote)
                        }
                    }
                    group.leave()
                }
            }
        } else if selected == 2 {
            let bookmarkedQuotes = localQuotesService.getBookmarkedQuotes()
            var bookmarkedQuoteIDs: [Int] = []
            for bookmarkedQuote in bookmarkedQuotes {
                bookmarkedQuoteIDs.append(bookmarkedQuote.id)
            }
            for id in bookmarkedQuoteIDs {
                group.enter()
                apiService.getQuoteByID(id: id) { quote, error in
                    if let quote = quote, !self.savedQuotes.contains(where: { $0.id == quote.id }) {
                        DispatchQueue.main.async {
                            self.savedQuotes.append(quote)
                        }
                    }
                    group.leave()
                }
            }
        } else if selected == 3 {
            NotificationScheduler.shared.saveSentNotificationsAsRecents()
            let recentQuotes = localQuotesService.getRecentLocalQuotes()
            var recentQuoteIDs: [Int] = []
            for recentQuote in recentQuotes {
                recentQuoteIDs.append(recentQuote.id)
            }
            for id in recentQuoteIDs {
                group.enter()
                apiService.getQuoteByID(id: id) { quote, error in
                    if let quote = quote, !self.recentQuotes.contains(where: { $0.id == quote.id }) {
                        DispatchQueue.main.async {
                            self.recentQuotes.append(quote)
                        }
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.isLoadingMore = false
            if selected == 1{
                self.totalQuotesLoaded += self.quotesPerPage
            } else if selected == 2  {
                self.totalSavedQuotesLoaded += self.quotesPerPage
            }else if selected == 3  {
                self.totalRecentQuotesLoaded += self.quotesPerPage
            }
        }
    }
}

@available(iOS 16.0, *)
struct DropletsView_Previews: PreviewProvider {
    static var previews: some View {
        DropletsView(localQuotesService: LocalQuotesService(), apiService: APIService())
    }
}

