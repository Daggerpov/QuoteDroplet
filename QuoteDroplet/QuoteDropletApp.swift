//
//  QuoteDropletApp.swift
//  QuoteDroplet
//
//  Created by Daniel Agapov on 2023-08-30.
//

import SwiftUI
import GoogleMobileAds
import FirebaseCore
import ComposableArchitecture

@available(iOS 16, *)
@main
struct QuoteDropletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate might not need for firebase, since I have the above one from GoogleMobileAds

    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: QuoteDropletApp.store)
        }
    }
}

@available(iOS 15, *)
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
//                print("All set!")
                // what was previously in `registerNotifications()` function call is this 3-line block:
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                    NotificationSchedulerService.shared.scheduleNotifications()
            } else if let error {
                print(error.localizedDescription)
            }
        }
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        FirebaseApp.configure()
        
        return true
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
