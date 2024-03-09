import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
struct ContentView: View {
    @StateObject var sharedVars = SharedVarsBetweenTabs()
    var body: some View {
        TabView {
            HomeView().environmentObject(sharedVars)
                .tabItem {
                    Text("Home")
                    Image(systemName: "house.fill")
                }
            AppearanceView().environmentObject(sharedVars)
                .tabItem {
                    Text("Appearance")
                    Image(systemName: "paintbrush.fill")
                  }
            QuotesView().environmentObject(sharedVars)
                .tabItem {
                    Text("Quotes")
                    Image(systemName: "quote.bubble.fill")
                }
        }
    }
}

class SharedVarsBetweenTabs: ObservableObject {
    @Published var testNumber = 0
}
