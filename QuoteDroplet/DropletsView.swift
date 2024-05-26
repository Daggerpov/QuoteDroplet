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
    
    var body: some View {
        VStack {
            AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/7801914805")
                .frame(height: 50)

            Spacer()
            ScrollView {
                Spacer()
                VStack {
                    HStack {
                        Spacer()
                        Text("Droplets")
                            .font(.title)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                            .padding(.bottom, 5)
                        Spacer()
                    }
                    Spacer()
                    ForEach(quotes.indices, id: \.self) { index in
                        if let quote = quotes[safe: index] {
                            SingleQuoteView(quote: quote)
                                .onAppear {
                                    if index == quotes.count - 1 && !isLoadingMore && quotes.count < 4 {
                                        loadMoreQuotes()
                                    }
                                }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
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
    
    private func loadInitialQuotes() {
        loadMoreQuotes() // Initial load
    }
    
    private func loadMoreQuotes() {
        guard !isLoadingMore && quotes.count < 4 else { return }
        
        isLoadingMore = true
        getRandomQuoteByClassification(classification: "all") { quote, error in
            if let quote = quote, !self.quotes.contains(where: { $0.id == quote.id }) {
                DispatchQueue.main.async {
                    self.quotes.append(quote)
                    self.isLoadingMore = false
                }
            } else if let error = error {
                print("Error fetching more quotes: \(error)")
                self.isLoadingMore = false
            } else {
                self.isLoadingMore = false
            }
        }
    }
}

struct SingleQuoteView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    let quote: Quote
    
    @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var bookmarkedQuotesData: Data = Data()
    
    @State private var isBookmarked: Bool = false
    
    init(quote: Quote) {
        self.quote = quote
        self._isBookmarked = State(initialValue: isQuoteBookmarked(quote))
    }
    
    var body: some View {
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
            
            Button(action: {
                toggleBookmark()
            }) {
                HStack{
                    Image(uiImage: resizeImage(UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark")!, targetSize: CGSize(width: 75, height: 27))!)
                        .foregroundColor(isBookmarked ? .yellow : .gray)
                        .frame(alignment: .leading)
                    Spacer()
                }
                
            }
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private func toggleBookmark() {
        isBookmarked.toggle()
        
        var bookmarkedQuotes = getBookmarkedQuotes()
        if isBookmarked {
            bookmarkedQuotes.append(quote)
        } else {
            bookmarkedQuotes.removeAll { $0.id == quote.id }
        }
        saveBookmarkedQuotes(bookmarkedQuotes)
    }
    
    private func isQuoteBookmarked(_ quote: Quote) -> Bool {
        return getBookmarkedQuotes().contains(where: { $0.id == quote.id })
    }
    
    private func getBookmarkedQuotes() -> [Quote] {
        if let quotes = try? JSONDecoder().decode([Quote].self, from: bookmarkedQuotesData) {
            return quotes
        }
        return []
    }
    
    private func saveBookmarkedQuotes(_ quotes: [Quote]) {
        if let data = try? JSONEncoder().encode(quotes) {
            bookmarkedQuotesData = data
        }
    }
}

struct DropletsView_Previews: PreviewProvider {
    static var previews: some View {
        DropletsView()
    }
}
