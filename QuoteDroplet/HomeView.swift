//
//  HomeView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

struct HomeView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs

    private var aboutMeSection: some View {
        HStack {
            Text("Contact:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .padding(.leading, 10)
            
            Spacer()
            
            Link(destination: URL(string: "https://www.linkedin.com/in/danielagapov/")!) {
                Image("linkedinlogo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
            
            Link(destination: URL(string: "https://github.com/Daggerpov")!) {
                Image("githublogo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
            
            Link(destination: URL(string: "mailto:danielagapov1@gmail.com?subject=Quote%20Droplet%20Contact")!) {
                Image("gmaillogo")
                    .resizable()
                    .frame(width: 60, height: 50)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
            
            Spacer()
        }
        
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    var body: some View {
        VStack {
            Spacer()
            aboutMeSection
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
