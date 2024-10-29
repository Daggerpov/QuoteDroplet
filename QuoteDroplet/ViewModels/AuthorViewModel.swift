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
    
    let apiService: IAPIService
    let localQuotesService: ILocalQuotesService

    init(quote: Quote, localQuotesService: ILocalQuotesService, apiService: IAPIService) {
        self.quote = quote
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    func loadRemoteJSON<T: Decodable>(_ urlString: String, completion: @escaping  ((T) -> Void)) {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                fatalError(error?.localizedDescription ?? "Unknown Error")
            }
            
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(T.self, from: data)
                print("data printed from loadremoteJSON")
                print(data)
                completion(data)
            } catch {
                fatalError("Couldn't parse data from \(urlString)\n\(error)")
            }
        }
    }
    
    public func loadInitialQuotes() {
        totalQuotesLoaded = 0
        loadMoreQuotes() // Initial load
    }
    
    public func loadMoreQuotes() {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        let group = DispatchGroup()
        
        guard let author: String = quote.author else { return }

        apiService.getQuotesByAuthor(author: author) { [weak self] quotes, error in
            guard let self = self else {return}
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
                    if (self.quotes.contains(where: { $0.id == quote.id })){
                        self.quotes.append(quote)
                    }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else {return}
            self.isLoadingMore = false
            self.totalQuotesLoaded += AuthorViewModel.quotesPerPage
        }
    }
}

