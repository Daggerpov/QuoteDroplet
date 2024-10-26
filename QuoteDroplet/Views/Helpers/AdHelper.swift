//
//  AdHelper.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-20.
//

import Foundation
import UIKit
import GoogleMobileAds
import SwiftUI

// UIViewControllerRepresentable wrapper for AdMob banner view
struct AdBannerViewController: UIViewControllerRepresentable {
    let adUnitID: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner) // Use a predefined ad size
        bannerView.adUnitID = adUnitID
        
        let viewController = UIViewController()
        viewController.view.addSubview(bannerView)
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        bannerView.load(GADRequest())
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
