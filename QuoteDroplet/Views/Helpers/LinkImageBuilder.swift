//
//  LinkImageBuilder.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
@ViewBuilder func buildLinkImage (urlForImage: String, imageName: String, widthSpecified: CGFloat? = 50) -> some View {
    if let url: URL = URL(string: urlForImage) {
        
        HStack{
            Link(destination: url) {
                Image(imageName)
                    .resizable()
                    .frame(width: widthSpecified, height: 50)
            }
        }
        .padding(8)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
