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
    
    var body: some View {
        VStack {
            Text("Appearance Adjustments")
//            Text("\(sharedVars.testNumber)")
//            Button("test number change", action: {sharedVars.testNumber = 2})
            Text("\(sharedVars.colorPaletteIndex)")
        }
    }
}
struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView()
    }
}
