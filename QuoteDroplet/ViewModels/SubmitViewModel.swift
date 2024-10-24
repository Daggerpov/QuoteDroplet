//
//  SubmitViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

class SubmitViewModel: ObservableObject {
    @Published var isAddingQuote = false
    @Published var selectedCategory: QuoteCategory = .all
    @Published var submissionMessage = ""
    @Published var showSubmissionReceivedAlert = false
    @Published var showSubmissionInfoAlert = false
    @Published var quoteText = ""
    @Published var author = ""
    
    
}
