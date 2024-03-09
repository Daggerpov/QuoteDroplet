import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
struct ContentView: View {
    var body: some View {
        
        TabView {
            AppearanceView()
                .tabItem {
                    Text("Appearance")
                    Image(systemName: "person.fill")
                  }
            HomeView()
                .tabItem {
                    Text("Home")
                    Image(systemName: "house.fill")
                }
            QuotesView()
                .tabItem {
                    Text("Quotes")
                    Image(systemName: "phone.fill")
                }
        }
    }
}
