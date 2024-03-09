import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
struct ContentView: View {
    init() {
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            ColorPaletteManager.colorPaletteIndex = 0
            UserDefaults.standard.setValue(false, forKey: "isFirstLaunch")
//            selectedFontIndex = 0
        }
        // Initialize notificationPermissionGranted based on stored value
//        notificationPermissionGranted = UserDefaults.standard.bool(forKey: notificationPermissionKey)
    }
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

