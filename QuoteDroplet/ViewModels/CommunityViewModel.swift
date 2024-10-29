//
//  CommunityViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-24.
//

import Foundation

class CommunityViewModel: ObservableObject {
    
    @Published var recentQuotes: [Quote] = []
    
    let localQuotesService: ILocalQuotesService
    let apiService: IAPIService
    
    init(localQuotesService: ILocalQuotesService, apiService: IAPIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    public func getRecentQuotes() -> Void {
        // Fetch recent quotes when the view appears
        apiService.getRecentQuotes(limit: 3) { [weak self] quotes, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching recent quotes: \(error)")
                return
            }
            
            if let quotes = quotes {
                DispatchQueue.main.async {
                    self.recentQuotes = quotes
                }
            }
        }
    }
}
