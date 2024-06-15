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
    @AppStorage("likedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var likedQuotesData: Data = Data()
    
    @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var bookmarkedQuotesData: Data = Data()
    
    
    @State private var isLiked: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var likes: Int = 0 // Change likes to non-optional
    @State private var isLiking: Bool = false // Add state for liking status
    
    init(quote: Quote) {
        self.quote = quote
        self._isBookmarked = State(initialValue: isQuoteBookmarked(quote))
        self._isLiked = State(initialValue: isQuoteLiked(quote))
        self._likes = State(initialValue: quote.likes ?? 0) // Initialize likes with initial value
    }
    private func getQuoteLikeCountMethod(completion: @escaping (Int) -> Void) {
        let group = DispatchGroup()
        var theCompletionCount: Int = 0
        group.enter()
        getLikeCountForQuote(quoteGiven: quote) {likeCount in
            theCompletionCount = likeCount
            group.leave()
        }
        group.notify(queue: .main) {
            completion(theCompletionCount)
        }
    }
    
    private func getLikeCountForQuote(quoteGiven: Quote, completion: @escaping (Int) -> Void) {
        guard let url = URL(string: "http://quote-dropper-production.up.railway.app/quoteLikes/\(quoteGiven.id)") else {
            completion(0)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let likeCount = json["likeCount"] as? Int {
                completion(likeCount)
            } else {
                completion(0)
            }
        }.resume()
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
            
            if let author = quote.author, author != "Unknown Author", !author.isEmpty, author != "NULL", author != "" {
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
                        likeQuoteAction()
                        toggleLike()
                    }) {
                        Image(uiImage: resizeImage(UIImage(systemName: isLiked ? "heart.fill" : "heart")!, targetSize: CGSize(width: 75, height: 27))!)
                            .foregroundColor(isLiked ? .yellow : .gray)
                    }
                    
                    // Display the like count next to the heart button
                    Text("\(likes)")
                }
                
                Button(action: {
                    toggleBookmark()
                }) {
                    Image(uiImage: resizeImage(UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark")!, targetSize: CGSize(width: 75, height: 27))!)
                        .foregroundColor(isBookmarked ? .yellow : .gray)
                }
                
                if #available(iOS 16.0, *) {
                    let authorForSharing = (quote.author != "Unknown Author" && quote.author != "NULL" && quote.author != "" && quote.author != nil) ? quote.author : ""
                    let wholeAuthorText = (authorForSharing != "") ? "\n— \(authorForSharing ?? "Unknown Author")" : ""
                    
                    ShareLink(item: URL(string: "https://apps.apple.com/us/app/quote-droplet/id6455084603")!, message: Text("From the Quote Droplet app:\n\n\"\(quote.text)\"\(wholeAuthorText)")) {
                        Image(uiImage: resizeImage(UIImage(systemName: "square.and.arrow.up")!, targetSize: CGSize(width: 75, height: 27))!)
                    }
                } else {
                    // Fallback on earlier versions
                }
                
                Spacer()
            }
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
        .onAppear {
            isBookmarked = isQuoteBookmarked(quote)

            getQuoteLikeCountMethod { fetchedLikeCount in
                likes = fetchedLikeCount
            }
            isLiked = isQuoteLiked(quote)
        }
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
    
    private func toggleLike() {
        isLiked.toggle()
        
        var likedQuotes = getLikedQuotes()
        if isLiked {
            likedQuotes.append(quote)
        } else {
            likedQuotes.removeAll { $0.id == quote.id }
        }
        saveLikedQuotes(likedQuotes)
    }
    
    private func likeQuoteAction() {
        guard !isLiking else { return }
        isLiking = true
        
        // Check if the quote is already liked
        let isAlreadyLiked = isQuoteLiked(quote)
        
        // Call the like/unlike API based on the current like status
        if isAlreadyLiked {
            unlikeQuote(quoteID: quote.id) { updatedQuote, error in
                DispatchQueue.main.async {
                    if let updatedQuote = updatedQuote {
                        // Update likes count
                        self.likes = updatedQuote.likes ?? 0
                    }
                    self.isLiking = false
                }
            }
        } else {
            likeQuote(quoteID: quote.id) { updatedQuote, error in
                DispatchQueue.main.async {
                    if let updatedQuote = updatedQuote {
                        // Update likes count
                        self.likes = updatedQuote.likes ?? 0
                    }
                    self.isLiking = false
                }
            }
        }
    }
    
    private func isQuoteLiked(_ quote: Quote) -> Bool {
        return getLikedQuotes().contains(where: { $0.id == quote.id })
    }
    
    private func getLikedQuotes() -> [Quote] {
        if let quotes = try? JSONDecoder().decode([Quote].self, from: likedQuotesData) {
            return quotes
        }
        return []
    }
    
    private func saveLikedQuotes(_ quotes: [Quote]) {
        if let data = try? JSONEncoder().encode(quotes) {
            likedQuotesData = data
        }
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
 
