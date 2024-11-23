//
//  TabButtonView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 11/22/24.
//

import SwiftUI

struct TabButtonView: View {
    var imageSystemName: String
    var text: String
    
    var body: some View {
        Spacer(minLength: 20)
        Image(uiImage: resizeImage(UIImage(systemName: imageSystemName)!, targetSize: CGSize(width: 30, height: 27))!)
        Text(text)
    }
}
