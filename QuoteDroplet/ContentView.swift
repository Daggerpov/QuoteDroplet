//
//  ContentView.swift
//  QuoteDroplet
//
//  Created by Daniel Agapov on 2023-08-30.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedCategory = "All"  // Default selection

    var body: some View {
        VStack {
            Text("Quote Category:")
                .font(.headline)
                .padding(.bottom, 5)
            
            Picker("", selection: $selectedCategory) {
                Text("Wisdom").tag("Wisdom")
                Text("Motivation").tag("Motivation")
                Text("Discipline").tag("Discipline")
                Text("Philosophy").tag("Philosophy")
                Text("Inspiration").tag("Inspiration")
                Text("All").tag("All")
            }
            .pickerStyle(MenuPickerStyle())
            

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
