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
    var body: some View {
        Text("Quote Adjustments")
        Text("\(ColorPaletteManager.colorPaletteIndex)")
    }
}
struct QuotesView_Previews: PreviewProvider {
    static var previews: some View {
        QuotesView()
    }
}
