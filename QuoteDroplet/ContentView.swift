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
        .environmentObject(sharedVars)
        .accentColor(.blue)
//        .onAppear {
//            if (sharedVars.colorPaletteIndex == 0) {
//                // as if on dark mode
//                UITabBar.appearance().unselectedItemTintColor = UIColor(Color(red: 133/255, green: 123/255, blue: 116/255))
//            } else if (sharedVars.colorPaletteIndex == 1) {
//                UITabBar.appearance().unselectedItemTintColor = UIColor(Color(red: 133/255, green: 123/255, blue: 116/255))
//            } else if (sharedVars.colorPaletteIndex == 2) {
//                UITabBar.appearance().unselectedItemTintColor = UIColor(Color(red: 133/255, green: 123/255, blue: 116/255))
//            // skipping custom one
//            } else if (sharedVars.colorPaletteIndex == 4) {
//                UITabBar.appearance().unselectedItemTintColor = UIColor(Color(red: 133/255, green: 123/255, blue: 116/255))
//            } else if (sharedVars.colorPaletteIndex == 5) {
//                UITabBar.appearance().unselectedItemTintColor = UIColor(Color(red: 133/255, green: 123/255, blue: 116/255))
//            // skipping custom one
//            } else if (sharedVars.colorPaletteIndex == 6) {
//                UITabBar.appearance().unselectedItemTintColor = UIColor(Color(red: 133/255, green: 123/255, blue: 116/255))
//            // skipping custom one
//            } else {
//                //
//                UITabBar.appearance().unselectedItemTintColor = UIColor(Color(red: 133/255, green: 123/255, blue: 116/255))
//            }
//          
//            // replacing this right above, to the right     ^^: NUIColor.white
//        }
    }
    
        
}

class SharedVarsBetweenTabs: ObservableObject {
    @Published var colorPaletteIndex = 0
}
