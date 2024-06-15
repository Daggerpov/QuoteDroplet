//
//  HomeView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

struct CommunityView: View {
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
    
    @State private var recentQuotes: [Quote] = []
    
    @State private var isAddingQuote = false
    @State private var showSubmissionInfoAlert = false
    @State private var quoteText = ""
    @State private var author = ""
    @State private var selectedCategory: QuoteCategory = .wisdom
    @State private var submissionMessage = ""
    @State private var showSubmissionReceivedAlert = false
    
    private var quoteSection: some View {
        VStack(alignment: .leading) {
            HStack{
                Spacer()
                Text("Newest Quotes")
                    .font(.title)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                    .padding(.bottom, 5)
                Spacer()
            }
            
            
            if recentQuotes.isEmpty {
                Text("Loading Quotes ...")
                    .font(.title3)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    .padding(.bottom, 2)
                ForEach(1..<4) { index in
                    VStack() {
                        HStack {
                            Text("Quote Loading")
                                .font(.title3)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                .padding(.bottom, 2)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        
                        HStack{
                            Spacer()
                            Text("— Author Loading")
                                .font(.body)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                                .padding(.bottom, 5)
                                .frame(alignment: .trailing)
                        }
                    }
                }
            } else {
                ForEach(recentQuotes, id: \.id) { quote in
                    VStack() {
                        HStack{
                            Text("\"\(quote.text)\"")
                                .font(.title3)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                .padding(.bottom, 2)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        
                        // adjusted
                        if let author = quote.author, author != "Unknown Author", !author.isEmpty, author != "NULL", author != "" {
                            HStack{
                                Spacer()
                                Text("— \(author)")
                                    .font(.body)
                                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                                    .padding(.bottom, 5)
                                    .frame(alignment: .trailing)
                            }
                        } else {
                            Text("")
                                .font(.body)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                                .padding(.bottom, 5)
                                .frame(alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
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
    private var addQuoteButton: some View {
        Button(action: {
            isAddingQuote = true
        }) {
            Image("compose")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
        }
        .padding()
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
                ForEach(QuoteCategory.allCases, id: \.self) { category in
                    Text(category.displayName)
                }
            }
        }
    }
    
    // ----------------------------------------------------- SUBMIT QUOTE
    
    var body: some View {
        VStack {
            AdBannerViewController(adUnitID:
                                                "ca-app-pub-5189478572039689/4810355771") // new one: Home New (Mar 25)
                                        .frame(height: 50)
            Spacer()
            quoteSection
            Spacer()
            
            composeButton
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $isAddingQuote) {
            quoteAddition
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .onAppear {
            // Fetch recent quotes when the view appears
            getRecentQuotes(limit: 3) { quotes, error in
                if let quotes = quotes {
                    recentQuotes = quotes
                } else if let error = error {
                    print("Error fetching recent quotes: \(error)")
                }
            }
            sharedVars.colorPaletteIndex = widgetColorPaletteIndex
            
            colorPalettes[3][0] = Color(hex:widgetCustomColorPaletteFirstIndex)
            colorPalettes[3][1] = Color(hex:widgetCustomColorPaletteSecondIndex)
            colorPalettes[3][2] = Color(hex:widgetCustomColorPaletteThirdIndex)
        }
    }
}
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}

