//
//  SearchViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var searchText: String = ""
    @Published var activeCategory: QuoteCategory = .all
    private var isLoadingMore: Bool = false
    
    static let quotesPerPage = 5
    private let maxQuotes = 10
    private var totalQuotesLoaded = 0
    
    let localQuotesService: LocalQuotesService
    let apiService: APIService

    init(localQuotesService: LocalQuotesService, apiService: APIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    public func loadQuotesBySearch() {
        guard !isLoadingMore else { return }
        
        self.quotes = []
        
        isLoadingMore = true
        let group = DispatchGroup()
        
        apiService.getQuotesBySearchKeyword(searchKeyword: searchText, searchCategory: activeCategory.rawValue.lowercased()) { [weak self] quotes, error in
            if let error = error {
                print("Error fetching quotes: \(error)")
                return
            }
            
            guard let quotes = quotes else {
                print("No quotes found.")
                return
            }
            
            let quotesToAppend = quotes.prefix(SearchViewModel.quotesPerPage)
            
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
            self.totalQuotesLoaded += SearchViewModel.quotesPerPage
        }
    }
}
