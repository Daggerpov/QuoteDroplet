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

@available(iOS 16.0, *)
struct AuthorView: View {
    var viewModel: AuthorViewModel
    
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
    
    let localQuotesService: LocalQuotesService
    let apiService: APIService
    
    init(localQuotesService:  LocalQuotesService, apiService: APIService, viewModel: AuthorViewModel) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/7801914805").frame(height: 50)
                HStack {
                    Spacer()
                    Text("Quotes by \(viewModel.quote.author ?? "Author"):")
                        .font(.largeTitle.bold())
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                        .padding(.bottom, 5)
                    
                    Spacer()
                }
                
                ZStack{
                    Image("authorimageframe")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    AsyncImage(url: URL(string: "https://your_image_url_address"))
                    

                }
                
                
                ScrollView {
                    Spacer()
                    LazyVStack{
                        if viewModel.quotes.isEmpty {
                            Text("Loading Quotes...")
                                .font(.title2)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                .padding(.bottom, 5)
                                .frame(alignment: .center)
                        } else {
                            ForEach(viewModel.quotes.indices, id: \.self) { index in
                                if let quote = viewModel.quotes[safe: index] {
                                    SingleQuoteView(quote: quote, from: "AuthorView", localQuotesService: localQuotesService, apiService: apiService)
                                }
                            }
                        }
                        Color.clear.frame(height: 1)
                            .onAppear {
                                if !viewModel.isLoadingMore && viewModel.quotes.count < AuthorViewModel.maxQuotes {
                                    viewModel.loadMoreQuotes()
                                }
                            }
                        Spacer()
                        
                        VStack{
                            Text("Missing a quote from this author?\nI'd greatly appreciate submissions:")
                                .font(.title2)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                            
                            SubmitView(apiService: apiService)
                        }
                        
                        if !viewModel.isLoadingMore {
                            if (viewModel.quotes.count >= AuthorViewModel.maxQuotes) {
                                Text("You've reached the quote limit of \(AuthorViewModel.maxQuotes). Maybe take a break?")
                                    .font(.title2)
                                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                    .padding()
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
                viewModel.loadInitialQuotes()
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
                
                loadRemoteJSON("https://www.googleapis.com/customsearch/v1?key=AIzaSyBzqkgygHO3r6i7sJC56r-vU5icYBA_f6Y&cx=238ad9d0296fb425a&searchType=image&q=Marcus%20Aurelius"){ (data: TestModel) in
                 //data is your returned value of the generic type T.
                    print(data)
                }

            }
        }
    }
}

func loadRemoteJSON<T: Decodable>(_ urlString: String, completion: @escaping  ((T) -> Void)) {
    guard let url = URL(string: urlString) else {
        fatalError("Invalid URL")
    }
    
    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else {
            fatalError(error?.localizedDescription ?? "Unknown Error")
        }
        
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(T.self, from: data)
            print("data printed from loadremoteJSON")
            print(data)
            completion(data)
        } catch {
            fatalError("Couldn't parse data from \(urlString)\n\(error)")
        }
    }
}

struct TestModel: Decodable {}
