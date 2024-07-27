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

@available(iOS 16.0, *)
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
    @State private var selectedCategory: QuoteCategory = .all
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
                            Text("\(quote.text)")
                                .font(.title3)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                .padding(.bottom, 2)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        
                        // adjusted
                        if let author = quote.author, isAuthorValid(authorGiven: quote.author) {
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
    
    // ----------------------------------------------------- SUBMIT QUOTE
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    NavigationLink(destination: InfoView()) {
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .scaleEffect(1)
                            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                        
                    }
                    AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/7801914805")
                    
                }
                .frame(height: 60) // TODO: test with putting this here vs. below the AdBannerViewController, like it was before
                // TODO: test between height = 60 vs. height = 50
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
}
@available(iOS 16.0, *)
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}

