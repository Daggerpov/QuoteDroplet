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

struct ApperanceView: View {
    @AppStorage("colorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var colorPaletteIndex = 0
    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0
    @State private var showCustomColorsPopover = false
    var body: some View {
        Text("About Us")
    }
}
struct ApperanceView_Previews: PreviewProvider {
    static var previews: some View {
        ApperanceView()
    }
}
