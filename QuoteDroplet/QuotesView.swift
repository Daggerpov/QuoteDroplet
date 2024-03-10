//
//  QuotesView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

struct QuotesView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    @State private var isAddingQuote = false
    @State private var showSubmissionInfoAlert = false
    @State private var quoteText = ""
    @State private var author = ""
    @State private var selectedCategory: QuoteCategory = .wisdom
    @State private var submissionMessage = ""
    @State private var showSubmissionReceivedAlert = false
    
    
    private var composeButton: some View {
        Button(action: {
            isAddingQuote = true
        }) {
            HStack {
                Text("Submit a quote")
                    .font(.headline)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue, lineWidth: 2)
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
    private var quoteAddition: some View {
        VStack(spacing: 10) {
            Text("Quote Submission")
                .font(.title)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                .padding()
            Button(action: {
                showSubmissionInfoAlert = true
            }) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    Text("How This Works")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                        .padding(.leading, 5)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                        )
                )
                .buttonStyle(CustomButtonStyle())
            }
            .alert(isPresented: $showSubmissionInfoAlert) {
                Alert(
                    title: Text("How Quote Submission Works"),
                    message: Text("Once you submit a quote, it'll show up on my admin portal, where I'll be able to edit typos or insert missing fields, such as author and classification—so don't worry about these issues. \n\nThen, I'll either approve the quote submission to be added into the app's quote database, or delete it.\n\nNote that if your quote exactly matches another one's text, the submission will not go through."),
                    dismissButton: .default(Text("OK"))
                )
            }
            TextEditor(text: $quoteText)
                .frame(minHeight: 100, maxHeight: 150)
                .padding()
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .onTapGesture {
                    if quoteText == "Quote Text" {
                        quoteText = ""
                    }
                }
                .onAppear {
                    quoteText = "Quote Text"
                }
            TextEditor(text: $author)
                .frame(minHeight: 25, maxHeight: 50)
                .padding()
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .onTapGesture {
                    if author == "Author" {
                        author = ""
                    }
                }
                .onAppear {
                    author = "Author"
                }

            submissionQuoteCategoryPicker
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
                
            }
            .padding()
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
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
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(0) // Remove corner radius
        .edgesIgnoringSafeArea(.all) // Ignore safe area insets
    }
    private var submissionQuoteCategoryPicker: some View {
        HStack {
            Text("Quote Category:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            Picker("", selection: $selectedCategory) {
                ForEach(QuoteCategory.allCases, id: \.self) { category in
                    Text(category.displayName)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0])
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1])
            .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
        }
    }

    var body: some View {
        VStack {
            Spacer()
            composeButton
        }
        .sheet(isPresented: $isAddingQuote) {
            quoteAddition
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .frame(maxWidth: .infinity)
    }
    
}
struct QuotesView_Previews: PreviewProvider {
    static var previews: some View {
        QuotesView()
    }
}
