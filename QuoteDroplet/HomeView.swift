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

struct HomeView: View {
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
                        
                        if let author = (quote.author && quote.author != "Unknown Author" && quote.author != nil && quote.author != "") {
                            HStack{
                                Spacer()
                                Text("— \(author)")
                                    .font(.body)
                                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                                    .padding(.bottom, 5)
                                    .frame(alignment: .trailing)
                            }
                            
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

    private var aboutMeSection: some View {
        HStack {
            Text("Contact:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .padding(.leading, 10)
            
            Spacer()
            
            Link(destination: URL(string: "https://www.linkedin.com/in/danielagapov/")!) {
                Image("linkedinlogo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
            
            Link(destination: URL(string: "https://github.com/Daggerpov")!) {
                Image("githublogo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
            
            Link(destination: URL(string: "mailto:danielagapov1@gmail.com?subject=Quote%20Droplet%20Contact")!) {
                Image("gmaillogo")
                    .resizable()
                    .frame(width: 60, height: 50)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
        }
        
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    var body: some View {
        VStack {
//            AdBannerViewController(adUnitID:
//                                    "ca-app-pub-5189478572039689/4071075476")
//                            .frame(height: 50)
            AdBannerViewController(adUnitID:
                                                "ca-app-pub-5189478572039689/4810355771") // new one: Home New (Mar 25)
                                        .frame(height: 50)
            Spacer()
            quoteSection
            Spacer()
            aboutMeSection
            Spacer()
        }
        .frame(maxWidth: .infinity)
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
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

