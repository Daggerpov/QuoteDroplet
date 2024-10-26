//
//  ColorPickerWithoutLabel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
public struct ColorPickerWithoutLabel: UIViewRepresentable {
    @Binding var selection: Color
    var supportsAlpha: Bool = true
    
    public init(selection: Binding<Color>, supportsAlpha: Bool = true) {
        self._selection = selection
        self.supportsAlpha = supportsAlpha
    }
    
    
    public func makeUIView(context: Context) -> UIColorWell {
        let well = UIColorWell()
        well.supportsAlpha = supportsAlpha
        return well
    }
    
    public func updateUIView(_ uiView: UIColorWell, context: Context) {
        uiView.selectedColor = UIColor(selection)
    }
}
