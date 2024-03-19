import SwiftUI
import WidgetKit
import UserNotifications
import UIKit

struct ContentView: View {
    @StateObject var sharedVars = SharedVarsBetweenTabs()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            AppearanceView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush.fill")
                }
            QuotesView()
                .tabItem {
                    Label("Quotes", systemImage: "quote.bubble.fill")
                }
        }
        .padding(.top, 20)
        .environmentObject(sharedVars)
        .accentColor(.blue)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.black
            UITabBar.appearance().unselectedItemTintColor = UIColor.white
        }
    }
}

class SharedVarsBetweenTabs: ObservableObject {
    @Published var colorPaletteIndex = 0
}
