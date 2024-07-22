//
//  HeaderView.swift
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

struct HeaderView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var body: some View {
        HStack{
            NavigationLink(destination: InfoView()) {
                if #available(iOS 15.0, *) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title)
                        .scaleEffect(1)
                        .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                } else {
                    // Fallback on earlier versions
                }
            }
            AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/7801914805")
                
        }
        .frame(height: 60) // TODO: test with putting this here vs. below the AdBannerViewController, like it was before
        // TODO: test between height = 60 vs. height = 50
    }
}


