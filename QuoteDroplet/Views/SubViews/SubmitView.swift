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
    @ObservedObject var viewModel: SubmitViewModel
    
    init(viewModel: SubmitViewModel) {
        self.viewModel = viewModel
    }
    
    private var composeButton: some View {
        Button(action: {
            viewModel.isAddingQuote = true
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
            viewModel.showSubmissionInfoAlert = true
        }) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.title3)
                Text("How This Works")
            }
            .padding()
        }
        .alert(isPresented: $viewModel.showSubmissionInfoAlert) {
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
                        TextField("Quote Text", text: $viewModel.quoteText)
                        TextField("Quote Author", text: $viewModel.author)
                        submissionQuoteCategoryPicker
                    }
                    Button("Submit") {
                        viewModel.addQuote()
                    }
                    .alert(isPresented: $viewModel.showSubmissionReceivedAlert) { // Modify this line
                        Alert(
                            title: Text("Submission Received"),
                            message: Text(viewModel.submissionMessage),
                            dismissButton: .default(Text("OK")) {
                                viewModel.showSubmissionReceivedAlert = false // Dismisses the alert when OK is clicked
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
            Picker("Quote Category", selection: $viewModel.selectedCategory) {
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
        }.sheet(isPresented: $viewModel.isAddingQuote) {
            quoteAddition
            // TODO: maybe move this .sheet modifier back to caller body, and just publish this isaddingquote var for caller to observe
        }
    }
}
