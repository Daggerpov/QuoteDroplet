//
//  ContentView.swift
//  QuoteDroplet
//
//  Created by Daniel Agapov on 2023-08-30.
//

import SwiftUI

let colorPalettes = [
    [Color(hex: "504136"), Color(hex: "EEC584"), Color(hex: "CC5803")],
    [Color(hex: "85C7F2"), Color(hex: "0C1618"), Color(hex: "FAF4D3")],
    [Color(hex: "EFF8E2"), Color(hex: "DC9E82"), Color(hex: "423E37")]
]

enum QuoteCategory: String, CaseIterable {
    case wisdom = "Wisdom"
    case motivation = "Motivation"
    case discipline = "Discipline"
    case philosophy = "Philosophy"
    case inspiration = "Inspiration"
    case all = "All"
    
    var displayName: String {
        return self.rawValue
    }
}

struct ContentView: View {
    @State private var selectedCategory: QuoteCategory = .all
    @State private var quoteFrequencyIndex = 3
    @State private var selectedPaletteIndex = 0
    
    let frequencyOptions = ["30 sec", "10 min", "1 hr", "2 hrs", "4 hrs", "8 hrs", "1 day"]

    var body: some View {
        VStack {
            Text("Quote Category:")
                .font(.headline)
                .foregroundColor(colorPalettes[safe: selectedPaletteIndex]?[1] ?? .white)
                .padding(.bottom, 5)
            
            Picker("", selection: $selectedCategory) {
                ForEach(QuoteCategory.allCases, id: \.self) { category in
                    Text(category.displayName)
                        .foregroundColor(colorPalettes[safe: selectedPaletteIndex]?[1] ?? .white)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Text("Time interval between quotes:")
                .font(.headline)
                .foregroundColor(colorPalettes[safe: selectedPaletteIndex]?[1] ?? .white)
                .padding(.top, 20)
            
            Picker("", selection: $quoteFrequencyIndex) {
                ForEach(0..<frequencyOptions.count, id: \.self) { index in
                    Text(self.frequencyOptions[index])
                        .foregroundColor(colorPalettes[safe: selectedPaletteIndex]?[1] ?? .white)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Text("Color Palette:")
                .font(.headline)
                .foregroundColor(colorPalettes[safe: selectedPaletteIndex]?[1] ?? .white)
                .padding(.top, 20)
            
            HStack(spacing: 20) {
                ForEach(0..<colorPalettes.count, id: \.self) { paletteIndex in
                    ColorPaletteView(colors: colorPalettes[safe: paletteIndex] ?? [])
                        .frame(width: 100, height: 100)
                        .border(selectedPaletteIndex == paletteIndex ? Color.blue : Color.clear, width: 2)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedPaletteIndex = paletteIndex
                        }
                }
            }
            Spacer()
            
            // About Me Section
            VStack(spacing: 20) {
                Divider() // Add a divider line
                
                Text("About Me")
                    .font(.headline)
                    .foregroundColor(colorPalettes[safe: selectedPaletteIndex]?[1] ?? .white)
                
                HStack {
                    Spacer()
                    Link(destination: URL(string: "https://github.com/Daggerpov")!) {
                        Image("githublogo")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(colorPalettes[safe: selectedPaletteIndex]?[1] ?? .white)
                    }
                    
                    Link(destination: URL(string: "https://www.linkedin.com/in/danielagapov/")!) {
                        Image("linkedinlogo")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(colorPalettes[safe: selectedPaletteIndex]?[1] ?? .white)
                    }
                    Spacer()
                }
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            .background(ColorPaletteView(colors: [colorPalettes[safe: selectedPaletteIndex]?[0] ?? Color.clear]))
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: selectedPaletteIndex]?[0] ?? Color.clear]))
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
