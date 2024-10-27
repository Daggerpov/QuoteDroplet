//
//  CommunityViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-24.
//

import Foundation

class CommunityViewModel: ObservableObject {
    
    @Published var recentQuotes: [Quote] = []
    
    let localQuotesService: LocalQuotesService
    let apiService: APIService
    
    init(localQuotesService: LocalQuotesService, apiService: APIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    public func getRecentQuotes() {
        // Fetch recent quotes when the view appears
        apiService.getRecentQuotes(limit: 3) { quotes, error in
            if let error = error {
                print("Error fetching recent quotes: \(error)")
                return
            }
            
            if let quotes = quotes {
                DispatchQueue.main.async { [weak self] in
                    self?.recentQuotes = quotes
                }
            }
        }
    }
}
