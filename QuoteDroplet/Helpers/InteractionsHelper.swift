//
//  InteractionsHelper.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-21.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

//@available(iOS 16.0, *)
@MainActor @available(iOS 16.0, *)
func interactionsIncrease(from: String = "within app") {
    @AppStorage("interactions", store: UserDefaults(suiteName: "group.selectedSettings"))
    var interactions = 0
    
    @Environment(\.requestReview) var requestReview
    
    interactions += 1
    if (interactions == 21 && from != "widget") {
        // within app, so review should show
        requestReview()
    }
}