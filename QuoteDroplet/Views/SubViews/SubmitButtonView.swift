//
//  SubmitButtonView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-26.
//

import SwiftUI

@available(iOS 15.0, *)
struct SubmitButtonView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var text: String
    var imageSystemName: String

    var body: some View {
        HStack {
            Text(text)
                .font(.headline)
            Image(systemName: imageSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
        }
        .modifier(RoundedRectangleStyling())
    }
}
