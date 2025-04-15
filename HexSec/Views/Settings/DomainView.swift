//
//  DomainView.swift
//  HexSec
//
//  Created by dmitry lbv on 11.04.2025.
//

import SwiftUI

struct DomainView: View {
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24){
                Spacer()
                    .frame(height: 40)

                Image(systemName: "globe")
                    .font(.system(size: 72, weight: .light, design: .monospaced))
                VStack(spacing: 12) {
                    Text("google.com")
                        .font(.title2)
                    Text("Состояние ОК")
                        .opacity(0.5)
                }
                Spacer()
            }
            .navigationTitle(Text("Домен"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        
    }
}

#Preview {
    DomainView()
}
