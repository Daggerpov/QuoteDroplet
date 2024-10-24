//
//  AuthorViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

class AuthorViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var isLoadingMore: Bool = false
    static let quotesPerPage = 100
    private var totalQuotesLoaded = 0
    
    static let maxQuotes = 200
    
    let quote: Quote // given when made
    
    let apiService: APIService
    
    init(quote: Quote, apiService: APIService) {
        self.quote = quote
        self.apiService = apiService
    }
    
    
    public func loadInitialQuotes() {
        totalQuotesLoaded = 0
        loadMoreQuotes() // Initial load
    }
    
    public func loadMoreQuotes() {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        let group = DispatchGroup()
        
        apiService.getQuotesByAuthor(author: quote.author!) { [weak self] quotes, error in
            if let error = error {
                print("Error fetching quotes: \(error)")
                return
            }
            
            guard let quotes = quotes else {
                print("No quotes found.")
                return
            }
            
            let quotesToAppend = quotes.prefix(AuthorViewModel.quotesPerPage)
            
            for quote in quotesToAppend {
                DispatchQueue.main.async {
                    if !(self?.quotes.contains(where: { $0.id == quote.id }) ?? false) {
                        self?.quotes.append(quote)
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.isLoadingMore = false
            self.totalQuotesLoaded += AuthorViewModel.quotesPerPage
        }
    }
}
