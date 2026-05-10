//
//  PhosphorIcon.swift
//  Thaqalayn
//
//  Phosphor icon helper. Renders an asset-catalog image as a tintable
//  template image at the specified size. Use .foregroundColor to tint.
//

import SwiftUI

struct PhosphorIcon: View {
    let name: String
    var size: CGFloat = 18

    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}
