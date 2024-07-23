//
//  InfoView.swift
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

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

@available(iOS 16.0, *)
struct InfoView: View {
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
    
    @Environment(\.requestReview) var requestReview
    
    @State private var showMacAlert = false
    
    private var aboutMeSection: some View {
        HStack {
//            Text("Contact:")
//                .font(.title2)
//                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
//                .padding(.leading, 10)
//            
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
    
    private var shareAppButton: some View {
        HStack{
            if #available(iOS 16.0, *) {
                HStack{
                    ShareLink(item: URL(string: "https://apps.apple.com/us/app/quote-droplet/id6455084603")!, message: Text("Check out this app, Quote Droplet.")){
                        Label("Share Quote Droplet", systemImage: "arrow.up.right.square")
                            .font(.title)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                    }
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                )
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    
    @available(iOS 16.0, *)
    private var reviewButton: some View {
        
        return HStack{
            Button(action: {
                requestReview()
            }) {
                HStack {
                    Image(systemName: "star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                    Text("Rate Quote Droplet")
                        .font(.title)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                )
            }
            .padding()
        }
    }
    
    private var macNoteSection: some View {
        VStack (spacing: 10){
            Button(action: {
                showMacAlert = true
            }) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    Text("Note for Mac Owners")
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
            .alert(isPresented: $showMacAlert) {
                Alert(
                    title: Text("Note for Mac Owners"),
                    message: Text("You can actually add this same iOS widget to your Mac's widgets by clicking the date in the top-right corner of your Mac -> Edit Widgets.\n\nAlso, Quote Droplet has a Mac version available on the App Store. It conveniently shows quotes from a small icon in your menu bar, even offline."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    var body: some View {
        NavigationView{
            VStack {
                AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/7801914805").frame(height: 50)
                Spacer()
                HStack {
                    Spacer()
                    Text("App Info")
                        .font(.title)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                        .padding(.bottom, 5)
                    
                    Spacer()
                }
                shareAppButton
                Spacer()
                if #available(iOS 16.0, *) {
                    reviewButton
                } else {
                    // Fallback on earlier versions
                }
                Spacer()
                macNoteSection
                Spacer()
                Text("App Version \(Bundle.main.releaseVersionNumber ?? "Unknown")")
                    .font(.title2)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                    .padding(.bottom, 5)
                Spacer()
                aboutMeSection
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
            .padding()
            .onAppear {
                // Fetch initial quotes when the view appears
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
            }
            
        }
        .frame(maxWidth: .infinity)
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .padding()
        .onAppear {
            // Fetch initial quotes when the view appears
            sharedVars.colorPaletteIndex = widgetColorPaletteIndex
            
            colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
            colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
            colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
        }
        
    }
    
    
    
}
