import SwiftUI
import WidgetKit
import UserNotifications
import UIKit

@available(iOS 16, *)
struct ContentView: View {
    @StateObject var sharedVars = SharedVarsBetweenTabs()
    @Environment(\.colorScheme) var colorScheme
    
    let localQuotesService: LocalQuotesService = LocalQuotesService()
    
    var body: some View {
        TabView {
            DropletsView(localQuotesService: localQuotesService)
                .tabItem {
                    VStack {
                        Spacer(minLength: 20)
                        Image(uiImage: resizeImage(UIImage(systemName: "drop.circle.fill")!, targetSize: CGSize(width: 30, height: 27))!)
                        Text("Droplets")
                    }
                }
            SearchView(localQuotesService: localQuotesService)
                .tabItem {
                    VStack {
                        Spacer(minLength: 20)
                        Image(uiImage: resizeImage(UIImage(systemName: "magnifyingglass.circle.fill")!, targetSize: CGSize(width: 30, height: 27))!)
                        Text("Search")
                    }
                }
            AppearanceView(localQuotesService: localQuotesService)
                .tabItem {
                    Spacer(minLength: 20)
                    Image(uiImage: resizeImage(UIImage(systemName: "paintbrush.fill")!, targetSize: CGSize(width: 30, height: 27))!)
                    Text("Appearance")
                }
            QuotesView(localQuotesService: localQuotesService)
                .tabItem {
                    Spacer(minLength: 20)
                    Image(uiImage: resizeImage(UIImage(systemName: "quote.bubble.fill")!, targetSize: CGSize(width: 30, height: 27))!)
                    Text("Quotes")
                }
            CommunityView(localQuotesService: localQuotesService)
                .tabItem {
                    VStack {
                        Spacer(minLength: 20)
                        Image(uiImage: resizeImage(UIImage(systemName: "house.fill")!, targetSize: CGSize(width: 30, height: 27))!)
                        Text("Community")
                    }
                }
        }
        .environmentObject(sharedVars)
        .accentColor(.blue)
        .onChange(of: colorScheme) { newColorScheme in
            updateTabBarAppearance(for: newColorScheme)
        }
        .onAppear {
            updateTabBarAppearance(for: colorScheme)
        }
    }
    func updateTabBarAppearance(for colorScheme: ColorScheme) {
        if (colorScheme == .light) {
            UITabBar.appearance().backgroundColor = UIColor.white
            UITabBar.appearance().unselectedItemTintColor = UIColor.black
        } else {
            UITabBar.appearance().backgroundColor = UIColor.black
            UITabBar.appearance().unselectedItemTintColor = UIColor.white
        }
    }
}

class SharedVarsBetweenTabs: ObservableObject {
    @Published var colorPaletteIndex = 0
}

@available(iOS 16, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
