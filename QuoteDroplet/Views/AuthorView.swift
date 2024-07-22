//
//  AuthorView.swift
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

struct AuthorView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0
    
    // actual colors of custom:
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"
    
    @State private var quotes: [Quote] = []
    @State private var isLoadingMore: Bool = false
    private let quotesPerPage = 100
    @State private var totalQuotesLoaded = 0
    
    private let maxQuotes = 200
    
    let quote: Quote // given when made
    
    // ---------------------------QUOTE SUBMISSION ---------------------------
    
    @State private var isAddingQuote = false
    @State private var showSubmissionInfoAlert = false
    @State private var quoteText = ""
    @State private var author = ""
    @State private var selectedCategory: QuoteCategory = .all
    @State private var submissionMessage = ""
    @State private var showSubmissionReceivedAlert = false
    
    // ---------------------------QUOTE SUBMISSION ---------------------------
    
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
            if #available(iOS 16.0, *) {
                NavigationStack {
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
                    .navigationTitle("Quote Submission")
                    .accentColor(.blue)
                }
            } else {
                Form{
                    Section(header: Text("Quote Submission")) { // without header
                        TextField("Quote Text", text: $quoteText)
                        TextField("Author", text: $author)
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
        NavigationView {
            VStack {
                HeaderView()
                HStack {
                    Spacer()
                    Text("Quotes by \(quote.author ?? "Author"):")
                        .font(.title)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                        .padding(.bottom, 5)
                    
                    Spacer()
                }
                
                ScrollView {
                    Spacer()
                    LazyVStack{
                        if quotes.isEmpty {
                            Text("Loading Quotes...")
                                .font(.title2)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                .padding(.bottom, 5)
                                .frame(alignment: .center)
                        } else {
                            ForEach(quotes.indices, id: \.self) { index in
                                if let quote = quotes[safe: index] {
                                    if #available(iOS 16.0, *) {
                                        SingleQuoteView(quote: quote, from: "AuthorView")
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                }
                            }
                        }
                        Color.clear.frame(height: 1)
                            .onAppear {
                                if !isLoadingMore && quotes.count < maxQuotes {
                                    loadMoreQuotes()
                                }
                            }
                        Spacer()
                        
                        VStack{
                            Text("Missing a quote from this author?\nI'd greatly appreciate submissions:")
                                .font(.title2)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                .padding(.bottom, 5)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)

                            composeButton
                        }
                        
                        if !isLoadingMore {
                            if (quotes.count >= maxQuotes) {
                                Text("You've reached the quote limit of \(maxQuotes). Maybe take a break?")
                                    .font(.title2)
                                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        Spacer()
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
            .onAppear {
                // Fetch initial quotes when the view appears
                loadInitialQuotes()
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
            }
            .sheet(isPresented: $isAddingQuote) {
                quoteAddition
            }
        }
    }
    
    private func loadInitialQuotes() {
        totalQuotesLoaded = 0
        loadMoreQuotes() // Initial load
    }
    
    private func loadMoreQuotes() {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        let group = DispatchGroup()
        
        getQuotesByAuthor(author: quote.author!) {quotes, error in
            if let error = error {
                print("Error fetching quotes: \(error)")
                return
            }
            
            guard let quotes = quotes else {
                print("No quotes found.")
                return
            }

            let quotesToAppend = quotes.prefix(quotesPerPage)
            
            for quote in quotesToAppend {
                DispatchQueue.main.async {
                    if !self.quotes.contains(where: { $0.id == quote.id }) {
                        self.quotes.append(quote)
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.isLoadingMore = false
            self.totalQuotesLoaded += self.quotesPerPage
        }
    }
}
