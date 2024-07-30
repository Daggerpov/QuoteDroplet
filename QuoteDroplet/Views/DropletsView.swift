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
    @State private var isLoadingMore: Bool = false
    private let quotesPerPage = 5
    @State private var totalQuotesLoaded = 0
    @State private var totalSavedQuotesLoaded = 0
    
    @State private var selected = 1
    
    private let maxQuotes = 15
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    
                    NavigationLink(destination: InfoView()) {
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .scaleEffect(1)
                            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                        
                    }
                    
                    AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/7801914805")
                }
                
                .padding()
                .frame(height: 60) // TODO: test with putting this here vs. below the AdBannerViewController, like it was before
                // TODO: test between height = 60 vs. height = 50
                
                Picker(selection: $selected, label: Text("Picker"), content: {
                    Text("Quotes Feed").tag(1)
                    Text("Saved Quotes").tag(2)
                })
                .pickerStyle(SegmentedPickerStyle())
                
                
                Spacer()
                ScrollView {
                    Spacer()
                    LazyVStack{
                        HStack {
                            Spacer()
                            if selected == 1 {
                                Text("Quotes Feed")
                                    .font(.title)
                                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                    .padding(.bottom, 5)
                            } else {
                                Text("Saved Quotes")
                                    .font(.title)
                                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                    .padding(.bottom, 5)
                            }
                            
                            Spacer()
                        }
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
                                        SingleQuoteView(quote: quote, from: "not author view, lol this is shit code")
                                        // likely an issue with using the indices ->
                                        // that's what's causing the
                                        /*https://stackoverflow.com/questions/78737833/instance-of-struct-affecting-anothers-state*/
                                    }
                                }
                            }
                            
                        } else {
                            if savedQuotes.isEmpty {
                                Text("You have no saved quotes. Please save some from the Quotes Feed by pressing this:")
                                    .font(.title2)
                                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                    .padding(.bottom, 5)
                                    .frame(alignment: .center)
                                Image(systemName: "bookmark")
                                    .font(.title)
                                    .scaleEffect(1)
                                    .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                            } else {
                                ForEach(savedQuotes.indices, id: \.self) { index in
                                    if let quote = savedQuotes[safe: index] {
                                        SingleQuoteView(quote: quote, from: "not from author view")
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
                        } else {
                            Color.clear.frame(height: 1)
                                .onAppear {
                                    if !isLoadingMore && savedQuotes.count < maxQuotes {
                                        loadMoreQuotes()
                                    }
                                }
                        }
                        if !isLoadingMore {
                            if (selected == 1 && quotes.count >= maxQuotes) || (selected == 2 && savedQuotes.count >= maxQuotes) {
                                Text("You've reached the quote limit of \(maxQuotes). Maybe take a break?")
                                    .font(.title2)
                                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        Spacer()
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
                        selected = 2
                    case (0..., -30...30):
                        //                    print("right swipe")
                        selected = 1
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
        loadMoreQuotes() // Initial load
    }
    
    private func loadMoreQuotes() {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        let group = DispatchGroup()
        
        if selected == 1 {
            for _ in 0..<quotesPerPage {
                group.enter()
                getRandomQuoteByClassification(classification: "all") { quote, error in
                    if let quote = quote, !self.quotes.contains(where: { $0.id == quote.id }) {
                        DispatchQueue.main.async {
                            self.quotes.append(quote)
                        }
                    }
                    group.leave()
                }
            }
        } else if selected == 2 {
            let bookmarkedQuotes = getBookmarkedQuotes()
            var bookmarkedQuoteIDs: [Int] = []
            for bookmarkedQuote in bookmarkedQuotes {
                bookmarkedQuoteIDs.append(bookmarkedQuote.id)
            }
            for id in bookmarkedQuoteIDs {
                group.enter()
                getBookmarkedQuoteByID(id: id) { quote, error in
                    if let quote = quote, !self.savedQuotes.contains(where: { $0.id == quote.id }) {
                        DispatchQueue.main.async {
                            self.savedQuotes.append(quote)
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
            } else {
                self.totalSavedQuotesLoaded += self.quotesPerPage
            }
        }
    }
}

@available(iOS 16.0, *)
struct SingleQuoteView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    let quote: Quote
    let from: String?
    
    @StateObject private var quoteBox = QuoteBox()
    
    var body: some View {
        VStack {
            HStack {
                Text("\(quote.text)")
                    .font(.title3)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    .padding(.bottom, 2)
                    .frame(alignment: .leading)
                Spacer()
            }
            
            if let author = quote.author, isAuthorValid(authorGiven: quote.author) {
                HStack {
                    Spacer()
                    Text("— \(author)")
                        .font(.body)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                        .padding(.bottom, 5)
                        .frame(alignment: .trailing)
                }
            }
            
            HStack {
                HStack {
                    Button(action: {
                        quoteBox.likeQuoteAction(for: quote)
                        quoteBox.toggleLike(for: quote)
                    }) {
                        Image(systemName: quoteBox.isLiked ? "heart.fill" : "heart")
                            .font(.title)
                            .scaleEffect(1)
                            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                    }
                    
                    // Display the like count next to the heart button
                    Text("\(quoteBox.likes)")
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                }
                
                Button(action: {
                    quoteBox.toggleBookmark(for: quote)
                }) {
                    Image(systemName: quoteBox.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.title)
                        .scaleEffect(1)
                        .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                }.padding(.leading, 5)
                
                let authorForSharing = (isAuthorValid(authorGiven: quote.author)) ? quote.author : ""
                let wholeAuthorText = (authorForSharing != "") ? "\n— \(authorForSharing ?? "Unknown Author")" : ""
                
                ShareLink(item: URL(string: "https://apps.apple.com/us/app/quote-droplet/id6455084603")!, message: Text("From the Quote Droplet app:\n\n\"\(quote.text)\"\(wholeAuthorText)")) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title)
                        .scaleEffect(1)
                        .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                }
                .padding(.leading, 5)
                
                Spacer()
                
                if (isAuthorValid(authorGiven: quote.author) && from != "AuthorView"){
                    NavigationLink(destination: AuthorView(quote: quote)) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.title)
                            .scaleEffect(1)
                            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                    }
                }
            }
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
        .onAppear {
            quoteBox.isBookmarked = isQuoteBookmarked(quote)
            
            quoteBox.getQuoteLikeCountMethod(for: quote) { fetchedLikeCount in
                quoteBox.likes = fetchedLikeCount
            }
            quoteBox.isLiked = isQuoteLiked(quote)
        }
    }
}

@available(iOS 16.0, *)
struct DropletsView_Previews: PreviewProvider {
    static var previews: some View {
        DropletsView()
    }
}

