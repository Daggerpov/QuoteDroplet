//
//  SingleQuoteViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-21.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation
import StoreKit

@MainActor @available(iOS 16.0, *)
class SingleQuoteViewModel: ObservableObject {
    @Published var isCopied: Bool = false
    @Published var isLiked: Bool = false
    @Published var isBookmarked: Bool = false
    @Published var likes: Int = 0
    @Published var isLiking: Bool = false
    
    //------------------------------------------------------------------------------------
    @AppStorage("interactions", store: UserDefaults(suiteName: "group.selectedSettings"))
    var interactions: Int = 0
    
    @Environment(\.requestReview) var requestReview: RequestReviewAction
    //------------------------------------------------------------------------------------
    
    var quote: Quote
    var from: SingleQuoteSource
    var searchText: String?
    
    let localQuotesService: LocalQuotesService
    let apiService: APIService

    init(
        localQuotesService: LocalQuotesService,
        apiService: APIService,
        quote: Quote,
        from: SingleQuoteSource = .standardView,
        searchText: String = ""
    ) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
        self.quote = quote
        self.from = from
        self.searchText = searchText
    }
    
    public func shouldShowArrow() -> Bool {
        return isAuthorValid(authorGiven: quote.author) && from != .authorView
    }
    
    public func getQuoteInfo() {
        isBookmarked = localQuotesService.isQuoteBookmarked(quote)
        
        getQuoteLikeCountMethod(for: quote) { [weak self] fetchedLikeCount in // to avoid memory leaks
            self?.likes = fetchedLikeCount
        }
        isLiked = localQuotesService.isQuoteLiked(quote)
    }
        
    func increaseInteractions() {
        DispatchQueue.main.async { [weak self] in
            self?.interactions += 1
            if (self?.interactions == 21) {
                // within app, so review should show
                self?.requestReview()
            }
        }
    }
    
    func toggleCopy(for quote: Quote) {
        DispatchQueue.main.async { [weak self] in
            self?.isCopied.toggle()
            self?.increaseInteractions()
        }
    }
    
    func toggleBookmark(for quote: Quote) {
        DispatchQueue.main.async { [weak self] in // weak self to avoid memory leaks
            self?.isBookmarked.toggle()
            
            if let isBookmarked = self?.isBookmarked {
                
                self?.localQuotesService.saveBookmarkedQuote(quote: quote, isBookmarked: isBookmarked)
            }
            
            self?.increaseInteractions()
        }
    }
    
    func toggleLike(for quote: Quote) {
        DispatchQueue.main.async { [weak self] in // weak self to avoid memory leaks
            self?.isLiked.toggle()
            
            if let isLiked = self?.isLiked {
                self?.localQuotesService.saveLikedQuote(quote: quote, isLiked: isLiked)
            }
            
            self?.increaseInteractions()
        }
    }
    
    func getQuoteLikeCountMethod(for quote: Quote, completion: @escaping (Int) -> Void) {
        apiService.getLikeCountForQuote(quoteGiven: quote) { likeCount in
            DispatchQueue.main.async {
                completion(likeCount)
            }
        }
    }
    
    func likeQuoteAction(for quote: Quote) {
        guard !isLiking else { return }
        
        DispatchQueue.main.async {
            self.isLiking = true
        }
        
        // Check if the quote is already liked
        let isAlreadyLiked = localQuotesService.isQuoteLiked(quote)
        
        // Call the like/unlike API based on the current like status
        if isAlreadyLiked {
            apiService.unlikeQuote(quoteID: quote.id) { updatedQuote, error in
                DispatchQueue.main.async {
                    if let updatedQuote = updatedQuote {
                        // Update likes count
                        self.likes = updatedQuote.likes ?? 0
                    }
                    self.isLiking = false
                }
            }
        } else {
            apiService.likeQuote(quoteID: quote.id) { updatedQuote, error in
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
    
    
}
