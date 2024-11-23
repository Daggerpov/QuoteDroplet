import SwiftUI

@available(iOS 16, *)
struct ContentView: View {
    @StateObject var sharedVars = SharedVarsBetweenTabs()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView {
            DropletsView()
                .tabItem {
                    VStack {
                        TabButtonView(imageSystemName: "drop.circle.fill", text: "Droplets")
                    }
                }
            SearchView()
                .tabItem {
                    VStack {
                        TabButtonView(imageSystemName: "magnifyingglass.circle.fill", text: "Search")
                    }
                }
            AppearanceView()
                .tabItem {
                    TabButtonView(imageSystemName: "paintbrush.fill", text: "Appearance")
                }
            QuotesView()
                .tabItem {
                    TabButtonView(imageSystemName: "quote.bubble.fill", text: "Quotes")
                }
            CommunityView()
                .tabItem {
                    VStack {
                        TabButtonView(imageSystemName: "house.fill", text: "Community")
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
