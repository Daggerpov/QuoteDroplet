//
//  SingleQuoteview.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-09-08.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation
import StoreKit
import UniformTypeIdentifiers

@available(iOS 16.0, *)
struct SingleQuoteView: View {
    @StateObject var viewModel: SingleQuoteViewModel =
    )
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    var quote: Quote
    var from: String?
    var searchText: String?
    
    // TODO: change from to an enum
    init(quote: Quote, from: String?, searchText: String?) {
        SingleQuoteViewModel(
            localQuotesService: LocalQuotesService(),
            apiService: APIService(), quote: quote, from: from)
    }
    
    
    var body: some View {
            VStack {
                HStack {
                    Text(attributedString)//                Text("\(quote.text)")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                        .padding(.bottom, 2)
                        .frame(alignment: .leading)
                    Spacer()
                }
                
                if let author = quote.author, isAuthorValid(authorGiven: quote.author) {
                    HStack {
                        Spacer()
                        Text("— \(author)")
                            .font(.body)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                            .padding(.bottom, 5)
                            .frame(alignment: .trailing)
                    }
                }
                
                HStack {
                    // TODO: what I need to do here is make it so likes are fetched by using the `getLikeCountForQuote` method
                    HStack {
                        Button(action: {
                            viewModel.likeQuoteAction(for: quote)
                            viewModel.toggleLike(for: quote)
                        }) {
                            Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                .font(.title)
                                .scaleEffect(1)
                                .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                        }
                        
                        // Display the like count next to the heart button
                        Text("\(viewModel.likes)")
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                    }
                    
                    Button(action: {
                        viewModel.toggleBookmark(for: quote)
                    }) {
                        Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.title)
                            .scaleEffect(1)
                            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                    }.padding(.leading, 5)
                    
                    let authorForSharing = (isAuthorValid(authorGiven: quote.author)) ? quote.author : ""
                    let wholeAuthorText = (authorForSharing != "") ? "\n— \(authorForSharing ?? "Unknown Author")" : ""
                    
                    Button(action: {
                        UIPasteboard.general.setValue("\(quote.text)\(wholeAuthorText)",
                                                      forPasteboardType: UTType.plainText.identifier)
                        viewModel.toggleCopy(for: quote)
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.title)
                            .scaleEffect(1)
                            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                    }.padding(.leading, 5)
                    
                    ShareLink(item: URL(string: "https://apps.apple.com/us/app/quote-droplet/id6455084603")!, message: Text("From the Quote Droplet app:\n\n\"\(quote.text)\"\(wholeAuthorText)")) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title)
                            .scaleEffect(1)
                            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                    
                    if (viewModel.shouldShowArrow()) {
                        NavigationLink(destination: AuthorView()) {
                            Image(systemName: "arrow.turn.down.right")
                                .font(.title)
                                .scaleEffect(1)
                                .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                        }
                    }

                }
            }
            .padding()
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.horizontal)
            .onAppear {
                viewModel.getQuoteInfo()
            }
        
    }
    
    private var attributedString: AttributedString {
        var attributedString = AttributedString(quote.text)
        let searchTextLowercased = (searchText ?? "").lowercased()
        let textLowercased = quote.text.lowercased()
        var searchStartIndex = textLowercased.startIndex

        // Loop to find and highlight all occurrences
        while let range = textLowercased.range(of: searchTextLowercased, range: searchStartIndex..<textLowercased.endIndex) {
            // Convert String.Index to AttributedString.Index
            if let attributedRange = Range(NSRange(range, in: textLowercased), in: attributedString) {
                attributedString[attributedRange].backgroundColor = (colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .yellow).opacity(0.3)
            }
            // Move searchStartIndex to the end of the found range to continue searching
            searchStartIndex = range.upperBound
        }

        return attributedString
    }
}
