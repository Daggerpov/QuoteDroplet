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
    
    static let quotesPerPage: Int = 5
    
    private var isLoadingMore: Bool = false
    private let maxQuotes: Int = 10
    private var totalQuotesLoaded: Int = 0
    
    let localQuotesService: ILocalQuotesService
    let apiService: IAPIService
    
    init(localQuotesService: ILocalQuotesService, apiService: IAPIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    public func loadQuotesBySearch() -> Void {
        guard !isLoadingMore else { return }
        
        self.quotes = []
        
        self.isLoadingMore = true
        let group: DispatchGroup = DispatchGroup()
        
        apiService.getQuotesBySearchKeyword(searchKeyword: searchText, searchCategory: activeCategory.rawValue.lowercased()) { [weak self] quotes, error in
            guard let self = self else { return }
            if let error: Error = error {
                print("Error fetching quotes: \(error)")
                return
            }
            
            guard let quotes: [Quote] = quotes else {
                print("No quotes found.")
                return
            }
            
            let quotesToAppend: [Quote] = Array(quotes.prefix(SearchViewModel.quotesPerPage))
            
            for quote in quotesToAppend {
                DispatchQueue.main.async {
                    if !self.quotes.contains(where: { $0.id == quote.id }) {
                        self.quotes.append(quote)
                    }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoadingMore = false
            self.totalQuotesLoaded += SearchViewModel.quotesPerPage
        }
    }
}
