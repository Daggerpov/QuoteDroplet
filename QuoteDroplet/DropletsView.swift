//
//  DropletsView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-05-18.
//
import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation
import StoreKit

struct DropletsView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "text.quote")
                }
            
            SavedQuotesView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
        }
    }
}

struct DropletsView_Previews: PreviewProvider {
    static var previews: some View {
        DropletsView()
    }
}

