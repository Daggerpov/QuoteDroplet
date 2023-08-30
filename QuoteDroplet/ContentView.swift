//
//  ContentView.swift
//  QuoteDroplet
//
//  Created by Daniel Agapov on 2023-08-30.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedCategory = "All"
    @State private var quoteFrequencyIndex = 3
    @State private var selectedPaletteIndex = 0
    
    let frequencyOptions = ["30 sec", "10 min", "1 hour", "2 hours", "4 hours", "8 hours", "1 day"]
    
    let colorPalettes = [
        [Color(hex: "FCAA67"), Color(hex: "27233A"), Color(hex: "444545")],
        [Color(hex: "505168"), Color(hex: "C5E0D8"), Color(hex: "EFF8E2")],
        [Color(hex: "93B5C6"), Color(hex: "504136"), Color(hex: "EEC584")]
    ]
    
    var body: some View {
        VStack {
            Text("Quote Category:")
                .font(.headline)
                .foregroundColor(selectedPaletteIndex == 0 ? .white : .black)
                .padding(.bottom, 5)
            
            Picker("", selection: $selectedCategory) {
                Text("Wisdom").tag("Wisdom")
                    .foregroundColor(selectedPaletteIndex == 0 ? .white : .black)
                Text("Motivation").tag("Motivation")
                    .foregroundColor(selectedPaletteIndex == 0 ? .white : .black)
                Text("Discipline").tag("Discipline")
                    .foregroundColor(selectedPaletteIndex == 0 ? .white : .black)
            }
            .pickerStyle(MenuPickerStyle())
            
            Text("Time interval between quotes:")
                .font(.headline)
                .foregroundColor(selectedPaletteIndex == 0 ? .white : .black)
                .padding(.top, 20)
            
            Picker("", selection: $quoteFrequencyIndex) {
                ForEach(0..<frequencyOptions.count, id: \.self) { index in
                    Text(self.frequencyOptions[index])
                        .foregroundColor(selectedPaletteIndex == 0 ? .white : .black)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Text("Color Palette:")
                .font(.headline)
                .foregroundColor(selectedPaletteIndex == 0 ? .white : .black)
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
            .edgesIgnoringSafeArea(.all)
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
