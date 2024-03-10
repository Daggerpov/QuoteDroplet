//
//  QuoteDropletApp.swift
//  QuoteDroplet
//
//  Created by Daniel Agapov on 2023-08-30.
//

import SwiftUI
//import UIKit
//import UserNotifications

@main
struct QuoteDropletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        registerForNotifications()
        return true
    }

    // Register for remote notifications
    private func registerForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Handle the registration failure
    }

    // MARK: - UNUserNotificationCenterDelegate

    // Handle notification when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Customize the presentation of the notification when the app is in the foreground
        completionHandler([.alert, .sound, .badge])
    }

    // Handle tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the action triggered by the user (e.g., open a specific view)
        completionHandler()
    }

    // Observer method to handle notification permission granted
    @objc private func handleNotificationPermissionGranted() {
        // Implement the code to handle notification permission granted
        // For example, update UI, show a message, etc.
    }
}
