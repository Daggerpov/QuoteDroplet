//
//  GeneralVars.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import Foundation

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.gray.opacity(0.5) : Color.clear)
            .cornerRadius(8)
            .border(configuration.isPressed ? Color.clear : Color.blue, width: 2)
    }
}

func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
    let size = image.size
    
    // Calculate the scaling factor to fit the image to the target dimensions while maintaining the aspect ratio
    let widthRatio = targetSize.width / size.width
    let heightRatio = targetSize.height / size.height
    let ratio = min(widthRatio, heightRatio)
    
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    let yOffset = (targetSize.height - newSize.height) // Leave the top blank and align the bottom
    
    //Create a new image context
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let newImage = renderer.image { context in
        // Fill the background with a transparent color
        context.cgContext.setFillColor(UIColor.clear.cgColor)
        context.cgContext.fill(CGRect(origin: .zero, size: targetSize))
        
        // draw new image
        image.draw(in: CGRect(x: 0, y: yOffset, width: newSize.width, height: newSize.height))
    }
    
    return newImage
}


