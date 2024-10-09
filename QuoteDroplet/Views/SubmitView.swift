//
//  SubmitView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-08.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct SubmitView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    // ----------------------------------------------------- SUBMIT QUOTE
    
    @State private var isAddingQuote = false
    @State private var selectedCategory: QuoteCategory = .all
    @State private var submissionMessage = ""
    @State private var showSubmissionReceivedAlert = false
    @State private var showSubmissionInfoAlert = false
    @State private var quoteText = ""
    @State private var author = ""

    // ----------------------------------------------------- SUBMIT QUOTE
    
    private var composeButton: some View {
        Button(action: {
            isAddingQuote = true
        }) {
            HStack {
                Text("Submit a Quote")
                    .font(.headline)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                Image(systemName: "paperplane.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
            )
        }
    }
    var howWorksPopUp: some View {
        Button(action: {
            showSubmissionInfoAlert = true
        }) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.title3)
                Text("How This Works")
            }
            .padding()
        }
        .alert(isPresented: $showSubmissionInfoAlert) {
            Alert(
                title: Text("How Quote Submission Works"),
                message: Text("Submitted quotes will either be approved to be added into the app's quote database, or dismissed.\n\nI'll be able to edit typos or insert missing fields, such as author and classification, so don't worry about this when submitting."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    private var quoteAddition: some View {
        VStack {
            howWorksPopUp
            NavigationStack {
                Text("Submit a Quote")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 5)
                Form{
                    //                    Section(header: Text("Quote Info"))
                    Section() { // without header
                        TextField("Quote Text", text: $quoteText)
                        TextField("Quote Author", text: $author)
                        submissionQuoteCategoryPicker
                    }
                    Button("Submit") {
                        addQuote(text: quoteText, author: author, classification: selectedCategory.rawValue) { success, error in
                            if success {
                                submissionMessage = "Thanks for submitting a quote. It is now awaiting approval to be added to this app's quote database."
                                // Set showSubmissionReceivedAlert to true after successful submission
                            } else if let error = error {
                                submissionMessage = error.localizedDescription
                            } else {
                                submissionMessage = "An unknown error occurred."
                            }
                            isAddingQuote = false
                            showSubmissionReceivedAlert = true // <-- Set to true after successful submission
                        }
                        quoteText = ""
                        author = ""
                        selectedCategory = .wisdom
                    }
                    .alert(isPresented: $showSubmissionReceivedAlert) { // Modify this line
                        Alert(
                            title: Text("Submission Received"),
                            message: Text(submissionMessage),
                            dismissButton: .default(Text("OK")) {
                                showSubmissionReceivedAlert = false // Dismisses the alert when OK is clicked
                            }
                        )
                    }
                    
                }
//                .navigationTitle("Quote Submission")
                .accentColor(.blue)
            }
            AdBannerViewController(adUnitID:
                                    //                                    "ca-app-pub-5189478572039689/1371107555"
                                   "ca-app-pub-5189478572039689/1609477369" // new one from Mar 25
            )                    .frame(height: 50)    // Fourth person banner ad, for submission inside Quotes View
        }
        
    }
    private var submissionQuoteCategoryPicker: some View {
        HStack {
            Picker("Quote Category", selection: $selectedCategory) {
                // Create a custom array that places .all at the beginning and filters out .bookmarkedQuotes
                ForEach([.all] + QuoteCategory.allCases.filter { $0 != .bookmarkedQuotes && $0 != .all }, id: \.self) { category in
                    Text(category == .all ? "Unsure" : category.rawValue)
                }
            }
        }
    }
    var body: some View {
        VStack{
            composeButton
        }.sheet(isPresented: $isAddingQuote) {
            quoteAddition
            // TODO: maybe move this .sheet modifier back to caller body, and just publish this isaddingquote var for caller to observe
        }
    }
}
