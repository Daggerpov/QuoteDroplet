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
    @Published var isLiked: Bool = false
    @Published var isBookmarked: Bool = false
    @Published var likes: Int = 0
    @Published var isLiking: Bool = false
    
    func toggleBookmark(for quote: Quote) {
        DispatchQueue.main.async {
            self.isBookmarked.toggle()
            
            var bookmarkedQuotes = getBookmarkedQuotes()
            if self.isBookmarked {
                bookmarkedQuotes.append(quote)
            } else {
                bookmarkedQuotes.removeAll { $0.id == quote.id }
            }
            saveBookmarkedQuotes(bookmarkedQuotes)
            
            interactionsIncrease()
        }
    }
    
    func toggleLike(for quote: Quote) {
        DispatchQueue.main.async {
            
            self.isLiked.toggle()
            
            var likedQuotes = getLikedQuotes()
            if self.isLiked {
                likedQuotes.append(quote)
            } else {
                likedQuotes.removeAll { $0.id == quote.id }
            }
            saveLikedQuotes(likedQuotes)
            
            interactionsIncrease()
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
    
    
}
