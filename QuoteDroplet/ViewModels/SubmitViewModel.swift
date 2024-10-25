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
    
    let apiService: APIService
    
    init (apiService: APIService) {
        self.apiService = apiService
    }
    
    func addQuote() {
        apiService.addQuote(text: quoteText, author: author, classification: selectedCategory.rawValue) { success, error in
            if success {
                self.submissionMessage = "Thanks for submitting a quote. It is now awaiting approval to be added to this app's quote database."
                // Set showSubmissionReceivedAlert to true after successful submission
            } else if let error = error {
                self.submissionMessage = error.localizedDescription
            } else {
                self.submissionMessage = "An unknown error occurred."
            }
            self.isAddingQuote = false
            self.showSubmissionReceivedAlert = true // <-- Set to true after successful submission
        }
        self.quoteText = ""
        self.author = ""
        self.selectedCategory = .wisdom
    }
}
