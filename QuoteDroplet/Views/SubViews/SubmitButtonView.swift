//
//  SubmitButtonView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-26.
//

struct SubmitButtonView: View {
    var text: String
    var imageSystemName: String

    var body: some View {
        HStack {
            Text(text)
                .font(.headline)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
            Image(systemName: imageSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
        )
    }
}
