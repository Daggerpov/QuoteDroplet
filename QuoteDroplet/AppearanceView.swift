//
//  AppearanceView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

struct AppearanceView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    @State private var showCustomColorAlert = false
    
    private var customColorNote: some View {
        VStack(spacing: 10) {
            Button(action: {
                showCustomColorAlert = true
            }) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    Text("Note About Custom Colors")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                        .padding(.leading, 5)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                        )
                )
                .buttonStyle(CustomButtonStyle())
            }
            .alert(isPresented: $showCustomColorAlert) {
                Alert(
                    title: Text("Note About Custom Colors"),
                    message: Text("Currently, the custom colors editing doesn't work, and simply act as one more color palette. \n\nI'm actively trying to fix this issue."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            customColorNote
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .frame(maxWidth: .infinity)
    }
}
struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView()
    }
}
