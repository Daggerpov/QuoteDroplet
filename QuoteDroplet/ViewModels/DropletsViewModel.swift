//
//  DropletsViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

@available(iOS 15, *)
class DropletsViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var savedQuotes: [Quote] = []
    @Published var recentQuotes: [Quote] = []
    private var isLoadingMore: Bool = false
    let quotesPerPage = 5
    private var totalQuotesLoaded = 0
    private var totalSavedQuotesLoaded = 0
    private var totalRecentQuotesLoaded = 0
    @Published var selected = 1
    let maxQuotes = 15
    
    let localQuotesService: LocalQuotesService
    let apiService: APIService
    
    init(localQuotesService: LocalQuotesService, apiService: APIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    func loadInitialQuotes() {
        totalQuotesLoaded = 0
        totalSavedQuotesLoaded = 0
        totalRecentQuotesLoaded = 0
        loadMoreQuotes() // Initial load
    }
    
    public func checkMoreQuotesNeeded() {
        if !isLoadingMore && quotes.count < maxQuotes {
            loadMoreQuotes()
        }
    }
    
    public func checkLimitReached() -> Bool {
        return !isLoadingMore && (
            (selected == 1 && quotes.count >= maxQuotes) || (selected == 2 && savedQuotes.count >= maxQuotes) || (selected == 3 && recentQuotes.count >= maxQuotes))
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
            if self.selected == 1{
                self.totalQuotesLoaded += self.quotesPerPage
            } else if self.selected == 2  {
                self.totalSavedQuotesLoaded += self.quotesPerPage
            }else if self.selected == 3  {
                self.totalRecentQuotesLoaded += self.quotesPerPage
            }
        }
    }
}
