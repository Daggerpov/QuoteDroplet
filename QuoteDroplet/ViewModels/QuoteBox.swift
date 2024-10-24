//
//  QuoteBox.swift
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
class QuoteBox: ObservableObject {
    @Published var isCopied: Bool = false
    @Published var isLiked: Bool = false
    @Published var isBookmarked: Bool = false
    @Published var likes: Int = 0
    @Published var isLiking: Bool = false
    
    //------------------------------------------------------------------------------------
    @AppStorage("interactions", store: UserDefaults(suiteName: "group.selectedSettings"))
    var interactions = 0
    
    @Environment(\.requestReview) var requestReview
    //------------------------------------------------------------------------------------
    
    let localQuotesService: LocalQuotesService
    
    init(localQuotesService: LocalQuotesService) {
        self.localQuotesService = localQuotesService
    }
    
    func toggleCopy(for quote: Quote) {
        DispatchQueue.main.async {
            self.isCopied.toggle()
            self.interactions += 1
            if (self.interactions == 21) {
                // within app, so review should show
                self.requestReview()
            }
        }
    }
    
    func toggleBookmark(for quote: Quote) {
        DispatchQueue.main.async { [weak self] in // weak self to avoid memory leaks
            self?.isBookmarked.toggle()
            
            if let isBookmarked = self?.isBookmarked {
                
                self?.localQuotesService.saveBookmarkedQuote(quote: quote, isBookmarked: isBookmarked)
            }
            
            self?.interactions += 1
            if (self?.interactions == 21) {
                // within app, so review should show
                self?.requestReview()
            }
        }
    }
    
    func toggleLike(for quote: Quote) {
        DispatchQueue.main.async { [weak self] in // weak self to avoid memory leaks
            self?.isLiked.toggle()
            
            if let isLiked = self?.isLiked {
                self?.localQuotesService.saveLikedQuote(quote: quote, isLiked: isLiked)
            }
            
            self?.interactions += 1
            if (self?.interactions == 21) {
                // within app, so review should show
                self?.requestReview()
            }
        }
    }
    
    func getQuoteLikeCountMethod(for quote: Quote, completion: @escaping (Int) -> Void) {
        getLikeCountForQuote(quoteGiven: quote) { likeCount in
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
    
    
}
