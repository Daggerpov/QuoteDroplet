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
//                    Label("Home", systemImage: "house.fill")
                    VStack {
                        Spacer(minLength: 20)
                        Image(uiImage: resizeImage(UIImage(systemName: "house.fill")!, targetSize: CGSize(width: 30, height: 27))!)
                        Text("Home")
                      }
                }
            AppearanceView()
                .tabItem {
//                    Label("Appearance", systemImage: "paintbrush.fill")
                    Spacer(minLength: 20)
                    Image(uiImage: resizeImage(UIImage(systemName: "paintbrush.fill")!, targetSize: CGSize(width: 30, height: 27))!)
                    Text("Appearance")
                }
            QuotesView()
                .tabItem {
//                    Label("Quotes", systemImage: "quote.bubble.fill")
                    Spacer(minLength: 20)
                    Image(uiImage: resizeImage(UIImage(systemName: "quote.bubble.fill")!, targetSize: CGSize(width: 30, height: 27))!)
                    Text("Quotes")
                }
        }
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
