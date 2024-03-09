//
//  QuotesView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

struct QuotesView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var body: some View {
        VStack {
            Text("Quote Adjustments")
//            Text("\(sharedVars.testNumber)")
//            Button("test number change", action: {sharedVars.testNumber = 3})
            Text("\(sharedVars.colorPaletteIndex)")
        }
    }
}
struct QuotesView_Previews: PreviewProvider {
    static var previews: some View {
        QuotesView()
    }
}
