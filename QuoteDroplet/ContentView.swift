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
                    Image(systemName: "person.fill")
                  }
            QuotesView()
                .tabItem {
                    Text("Quotes")
                    Image(systemName: "phone.fill")
                }
        }
    }
}
