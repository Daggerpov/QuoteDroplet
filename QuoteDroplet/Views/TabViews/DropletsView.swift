//
//  DropletsView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-05-18.
//
import SwiftUI

@available(iOS 16.0, *)
struct DropletsView: View {
    @StateObject var viewModel: DropletsViewModel = DropletsViewModel(
        localQuotesService: LocalQuotesService(),
        apiService: APIService()
    )
    
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0
    
    // actual colors of custom:
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
                VStack{
                    topNavBar
                    Spacer()
                    quotesListView
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
            .onAppear {
                // Fetch initial quotes when the view appears
                viewModel.loadInitialQuotes()
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
                
                // Schedule notifications:
                // will schedule with previous date and category values
                NotificationSchedulerService.shared.scheduleNotifications()
            }
            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                .onEnded { value in
                    switch(value.translation.width, value.translation.height) {
                    case (...0, -30...30): // left swipe
                        if viewModel.selected == .feed {
                            viewModel.selected = .saved
                        } else if viewModel.selected == .saved {
                            viewModel.selected = .recent
                        }
                    case (0..., -30...30): // right swipe
                        if viewModel.selected == .recent {
                            viewModel.selected = .saved
                        } else if viewModel.selected == .saved {
                            viewModel.selected = .feed
                        }
                    default: break
                    }
                }
            )
        }
    }
}

@available(iOS 16.0, *)
struct DropletsView_Previews: PreviewProvider {
    static var previews: some View {
        DropletsView()
    }
}

@available(iOS 16.0, *)
extension DropletsView {
    private var topNavBar: some View {
        Picker(selection: $viewModel.selected, label: Text("Picker"), content: {
            Text("Feed").tag(1)
            Text("Saved").tag(2)
            Text("Recent").tag(3)
        })
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var titles: some View {
        HStack {
            Spacer()
            Text(viewModel.getTitleText())
                .font(.largeTitle.bold())
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                .padding(.bottom, 5)

            Spacer()
        }
    }
    
    private var quotesListView: some View {
        ScrollView {
            Spacer()
            LazyVStack{
                titles
                Spacer()
                if viewModel.selected == .feed {
                    if viewModel.quotes.isEmpty {
                        Text("Loading Quotes Feed...")
                            .font(.title2)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                            .padding(.bottom, 5)
                            .frame(alignment: .center)
                    } else {
                        ForEach(viewModel.quotes) { quote in
                            SingleQuoteView(
                                quote: quote,
                                from: .standardView
                            )
                        }
                    }
                } else if viewModel.selected == .saved {
                    if viewModel.savedQuotes.isEmpty {
                        Text("You have no saved quotes. \n\nPlease save some from the Quotes Feed by pressing this:")
                            .modifier(DropletsPageTextStyling())
                        Image(systemName: "bookmark")
                            .font(.title)
                            .scaleEffect(1)
                            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                    } else {
                        ForEach(viewModel.savedQuotes) { quote in
                            SingleQuoteView(quote: quote, from: .standardView)
                        }
                    }
                } else if viewModel.selected == .recent {
                    
                    if viewModel.recentQuotes.isEmpty {
                        //                        Text("You have no recent quotes. \n\nBe sure to add the Quote Droplet widget and/or enable notifications to see them listed here.")
                        Text("You have no recent quotes. \n\nBe sure to enable notifications to see them listed here.")
                            .modifier(DropletsPageTextStyling())
                        Spacer()
                        Text("Quotes shown from the app's widget will appear here soon. Stay tuned for that update.")
                            .modifier(DropletsPageTextStyling())
                        // TODO: add apple widget help link here
                    } else {
                        Text("These are your most recent quotes from notifications.")
                            .modifier(DropletsPageTextStyling())
                        ForEach(viewModel.recentQuotes) {quote in
                            SingleQuoteView(quote: quote, from: .standardView)
                        }
                    }
                }
                
                Color.clear.frame(height: 1)
                    .onAppear {
                        viewModel.checkMoreQuotesNeeded()
                        
                    }
                if viewModel.checkLimitReached() {
                    Text("You've reached the quote limit of \(viewModel.maxQuotes). Maybe take a break?")
                        .modifier(DropletsPageTextStyling())
                }
                Spacer()
            }
        }
    }
}
