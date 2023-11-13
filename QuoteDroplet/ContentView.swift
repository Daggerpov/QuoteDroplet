//
//  ContentView.swift
//  QuoteDroplet
//
//  Created by Daniel Agapov on 2023-08-30.
//

import SwiftUI
import WidgetKit

let colorPalettes = [
    [Color(hex: "504136"), Color(hex: "EEC584"), Color(hex: "CC5803")],
    [Color(hex: "85C7F2"), Color(hex: "0C1618"), Color(hex: "83781B")],
    [Color(hex: "EFF8E2"), Color(hex: "DC9E82"), Color(hex: "423E37")]
]

enum QuoteCategory: String, CaseIterable {
    case wisdom = "Wisdom"
    case motivation = "Motivation"
    case discipline = "Discipline"
    case philosophy = "Philosophy"
    case inspiration = "Inspiration"
    case upliftment = "Upliftment"
    case all = "All"
    
    var displayName: String {
        return self.rawValue
    }
}

struct ContentView: View {
    @AppStorage("colorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var colorPaletteIndex = 0
    @AppStorage("quoteFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencyIndex = 3
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all
    
    @State private var showInstructions = false
    
    @State private var customPalette: [Color] = [.red, .green, .blue] // Default custom colors
    
    let frequencyOptions = ["30 sec", "10 min", "1 hr", "2 hrs", "4 hrs", "8 hrs", "1 day"]

    var body: some View {
        VStack {
            HStack {
                Text("Quote Category:")
                    .font(.title2)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                
                Picker("", selection: $quoteCategory) {
                    ForEach(QuoteCategory.allCases, id: \.self) { category in
                        Text(category.displayName)
                            .font(.headline)
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                .onTapGesture{
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                }
            }
            
            Group {
                Text("Time interval between quotes:")
                    .font(.title2) // Increased font size
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    .padding(.top, 20)
                
                Picker("", selection: $quoteFrequencyIndex) {
                    ForEach(0..<frequencyOptions.count, id: \.self) { index in
                        Text(self.frequencyOptions[index])
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onReceive([self.quoteFrequencyIndex].publisher.first()) { _ in
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                }
                
            }
            .padding(.bottom, 20) // Increased spacing
            
            // Color Palette Section
            Group {
                HStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Sample Colour Palettes:")
                            .font(.subheadline) // Increased font size
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                            .padding(.top, 10)
                        HStack(spacing: 10) {
                            ForEach(0..<colorPalettes.count, id: \.self) { paletteIndex in
                                ColorPaletteView(colors: colorPalettes[safe: paletteIndex] ?? [])
                                    .frame(width: 60, height: 60) // Adjusted size
                                    .border(colorPaletteIndex == paletteIndex ? Color.blue : Color.clear, width: 2)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        colorPaletteIndex = paletteIndex
                                        WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                                    }
                            }
                        }
                        
                        VStack(spacing: 10) {
                            Text("Custom Colour Palette:")
                                .font(.subheadline) // Increased font size
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                                .padding(.top, 10)
                            
                        }
                        HStack(spacing: 10) {
                            ForEach(0..<customPalette.count, id: \.self) { customIndex in
                                // Use ColorPicker for each custom color
                                ColorPicker(
                                    "",
                                    selection: Binding(
                                        get: {
                                            customPalette[customIndex]
                                        },
                                        set: { newColor in
                                            customPalette[customIndex] = newColor
                                            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                                        }
                                    ),
                                    supportsOpacity: false
                                )
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                            }
                        }
                        .onChange(of: customPalette) { _ in
                            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                        }
                    }
                    
                    VStack {
                        Text("Widget Preview:")
                            .font(.subheadline) // Increased font size
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorPalettes[safe: colorPaletteIndex]?[0] ?? .clear) // Use the first color as the background color
                                .overlay(
                                    VStack {
                                        Spacer()
                                        Text("More is lost by indecision than by wrong decision.")
                                            .font(.headline)
                                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white) // Use the second color for text color
                                            .padding(.horizontal, 20) // SPLIT BY ME
                                            .padding(.vertical, 10) // SPLIT BY ME
                                            .multilineTextAlignment(.center) // Center-align the text
                                            .lineSpacing(4) // Adjusted line spacing
                                            .minimumScaleFactor(0.5)
                                            .frame(maxHeight: .infinity)

                                        Text("- Cicero")
                                            .font(.subheadline)
                                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .white) // Use the third color for author text color
                                            .padding(.horizontal, 20) // ! SPLIT BY ME
                                            .padding(.bottom, 10) // ! CHANGED BY ME
                                            .lineLimit(1) // Ensure the author text is limited to one line
                                            .minimumScaleFactor(0.5) // Allow author text to scale down if needed
                                    }
                                )
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 0) // Add a subtle shadow for depth
                                .padding(.trailing, 0)
                        }
                        .frame(width: 150, height: 150)
                    }                    
                }
            }

            
            Spacer() // Create spacing
            
            if showInstructions {
                VStack(alignment: .leading, spacing: 4) {
                    Text("1. Press and hold an empty area of your home screen.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    
                    Text("2. Tap the '+' button (top left).")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    
                    Text("3. Find and select 'Quote Droplet'.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    
                    Text("4. Tap 'Add Widget,' then place it.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
            } else {
                Text("Be sure to add this widget to your home screen.")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                showInstructions.toggle()
            }) {
                if showInstructions{
                    Text("Hide Instructions")
                        .font(.headline)
                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                } else {
                    Text("Show Instructions")
                        .font(.headline)
                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                }
            }
               
            Spacer()
            
            // About Me Section
            VStack {
                Text("About Me")
                    .font(.title2) // Increased font size
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                
                HStack {
                    Spacer()
                    Link(destination: URL(string: "https://github.com/Daggerpov")!) {
                        Image("githublogo")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    }
                    
                    Link(destination: URL(string: "https://www.linkedin.com/in/danielagapov/")!) {
                        Image("linkedinlogo")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    }
                    Spacer()
                }
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            .background(ColorPaletteView(colors: [colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear]))
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear]))
    }

    
    private func formattedFrequency() -> String {
        return frequencyOptions[quoteFrequencyIndex]
    }
}

// A view that displays a gradient background using the provided colors
struct ColorPaletteView: View {
    var colors: [Color]
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea() // This line will make the background take up the whole screen
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
