//
//  HeaderView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-08-01.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct HeaderView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    var body: some View {
        HStack{
            Spacer()
            NavigationLink(destination: InfoView()) {
                Image(systemName: "line.3.horizontal")
                    .font(.title)
                    .scaleEffect(1)
                    .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                
            }
            Spacer()
            AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/7801914805")
        }
        
        // Note that padding definitely shouldn't be added here, but perhaps removed from Home and Quotes Views
        // * Note that now, QuotesView and CommunityView match padding, while DropletsView and AppearanceView
        // are more to the left
        .frame(height: 55)
    }
}
