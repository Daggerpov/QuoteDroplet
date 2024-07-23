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
    
    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0
    
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"
    
    @State private var showCustomColorAlert = false
    @State private var showMacAlert = false
    
    let availableFonts = [
        "Georgia", "Times New Roman", "Verdana",
        "Palatino", "Baskerville", "Didot", "Optima",
        "Arial"
    ]
    private var fontSelector: some View {
        HStack {
            Text("Widget Font:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            Picker("", selection: $selectedFontIndex) {
                ForEach(0..<availableFonts.count, id: \.self) { index in
                    Text(availableFonts[index])
                        .font(.custom(availableFonts[index], size: 16))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            .onChange(of: selectedFontIndex) { _ in
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            }
        }
    }
    private var sampleColorSection: some View {
        VStack {
            Text("Sample Colors:")
                .font(.title3)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 10)
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { paletteIndex in
                    ColorPaletteView(colors: colorPalettes[safe: paletteIndex] ?? [])
                        .frame(width: 60, height: 60)
                        .border(sharedVars.colorPaletteIndex == paletteIndex ? Color.blue : Color.clear, width: 2)
                        .cornerRadius(8)
                        .onTapGesture {
                            sharedVars.colorPaletteIndex = paletteIndex
                            widgetColorPaletteIndex = paletteIndex
                            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                        }
                }
            }
            HStack(spacing: 10) {
                ForEach(4..<colorPalettes.count, id: \.self) { paletteIndex in
                    ColorPaletteView(colors: colorPalettes[safe: paletteIndex] ?? [])
                        .frame(width: 60, height: 60)
                        .border(sharedVars.colorPaletteIndex == paletteIndex ? Color.blue : Color.clear, width: 2)
                        .cornerRadius(8)
                        .onTapGesture {
                            sharedVars.colorPaletteIndex = paletteIndex
                            widgetColorPaletteIndex = paletteIndex
                            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                        }
                }
            }
        }
    }
    
    private func customColorPicker(index: Int) -> some View {
        ColorPicker(
            "",
            selection: Binding(
                get: {
                    colorPalettes[3][index]
                },
                set: { newColor in
                    
                    colorPalettes[3][index] = newColor
                    
                    if (index == 0) {
                        widgetCustomColorPaletteFirstIndex = newColor.hex
                    } else if (index == 1) {
                        widgetCustomColorPaletteSecondIndex = newColor.hex
                    } else if (index == 2) {
                        widgetCustomColorPaletteThirdIndex = newColor.hex
                    } else {
                        // do nothing, idk
                    }
                    
                    sharedVars.colorPaletteIndex = 3
                    widgetColorPaletteIndex = 3
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                }
            ),
            supportsOpacity: false
        )
        .frame(width: 60, height: 60)
        .cornerRadius(8)
        .onChange(of: colorPalettes) { _ in
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
        }
    }
    private var customColorSection: some View {
        VStack(spacing: 10) {
            Text("Custom Colors:")
                .font(.title3)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 10)
            customColorPickers
        }
    }
    
    
    private var customColorPickers: some View {
        HStack(spacing: 10) {
            ForEach(0..<(colorPalettes.last?.count ?? 0), id: \.self) { customIndex in
                customColorPicker(index: customIndex)
            }
        }
    }
    
    private var widgetPreviewSection: some View {
        VStack {
            Text("Widget Preview:")
                .font(.title3)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                    .overlay(
                        VStack {
                            Spacer()
                            Text("More is lost by indecision than by wrong decision.")
                                .font(Font.custom(availableFonts[selectedFontIndex], size: 16))
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .minimumScaleFactor(0.5)
                                .frame(maxHeight: .infinity)
                            
                            Text("— Cicero")
                                .font(Font.custom(availableFonts[selectedFontIndex], size: 14))
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    )
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 0) // increased from black opacity of 0.2 and radius of 5
                    .padding(.trailing, 0)
            }
            .frame(width: 150, height: 150)
        }
    }
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
    
    private var reloadButton: some View {
        VStack{
            Button(action: {
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            }) {
                HStack {
                    Text("Reload Widget Now")
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
        }
    }
    
    private var macNoteSection: some View {
        VStack (spacing: 10){
            Button(action: {
                showMacAlert = true
            }) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    Text("Note for Mac Owners")
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
            .alert(isPresented: $showMacAlert) {
                Alert(
                    title: Text("Note for Mac Owners"),
                    message: Text("You can actually add this same iOS widget to your Mac's widgets by clicking the date in the top-right corner of your Mac -> Edit Widgets.\n\nAlso, Quote Droplet has a Mac version available on the App Store. It conveniently shows quotes from a small icon in your menu bar, even offline."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack{
                if #available(iOS 16.0, *) {
                    NavigationLink(destination: InfoView()) {
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .scaleEffect(1)
                            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                        
                    }
                } else {
                    // Fallback on earlier versions
                }
                AdBannerViewController(adUnitID: "ca-app-pub-5189478572039689/7801914805")
                
            }
            .frame(height: 60) // TODO: test with putting this here vs. below the AdBannerViewController, like it was before
            // TODO: test between height = 60 vs. height = 50
            Spacer()
            Group {
                HStack(spacing: 20) {
                    VStack(spacing: 10) {
                        sampleColorSection
                        customColorSection
                    }
                    widgetPreviewSection
                }
            }
            Spacer()
            fontSelector
            Spacer()
            macNoteSection
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        
    }
}
struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView()
    }
}
