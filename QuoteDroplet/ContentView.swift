import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Text("Home")
                    Image(systemName: "house.fill")
                }
            AppearanceView()
                .tabItem {
                    Text("Appearance")
                    Image(systemName: "paintbrush.fill")
                  }
            QuotesView()
                .tabItem {
                    Text("Quotes")
                    Image(systemName: "quote.bubble.fill")
                }
        }
    }
}

