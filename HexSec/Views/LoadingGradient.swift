//
//  LoadingGradient.swift
//  HexSec
//
//  Created by dmitry lbv on 16.04.2025.
//

import SwiftUI

struct LoadingGradient: View {
    @State private var offset: CGFloat = -1.0
    
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: [.white.opacity(0.1), .white.opacity(0.3), .white.opacity(0)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width * 1)
            .offset(x: offset * geometry.size.width)
            .blur(radius: 12)
        }
        .drawingGroup() // Ключевое изменение!
        .clipped()
        .background(.white.opacity(0.1))
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    offset = 1.0
                }
            }
        }
    }
}
