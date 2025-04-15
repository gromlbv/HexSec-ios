//
//  UnreleasedNavView.swift
//  HexSec
//
//  Created by dmitry lbv on 10.04.2025.
//

import SwiftUI

struct UnreleasedNavView: View {
    var body: some View {
        VStack (spacing: 24){
            Text("Этот экран будет добавлен после релиза")
                .multilineTextAlignment(.center)
                .opacity(0.6)
            Image(systemName: "hourglass.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)
                .background {
                    Circle()
                        .fill()
                        .foregroundColor(.white)
                        .frame(width: 47, height: 47)
                }
        }

    }
}

#Preview {
    UnreleasedNavView()
}
