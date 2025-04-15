//
//  ContentView.swift
//  HexSec
//
//  Created by dmitry lbv on 27.01.2025.
//

import SwiftUI
import StoreKit

struct ScanView: View {
    
    @State var statusText: String = "СКАНИРОВАТЬ"
    @State var loading: CGFloat = 0.0
    @State var objUnitX: CGFloat = 0.5
    @State var opacity: CGFloat = 1
    
    @State var isLoading: Bool = false
    
    
    var body: some View {
        VStack(spacing:20) {
            Image("FullLogo")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Spacer()
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 300, height: 287)
                    .background(
                        EllipticalGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.89, green: 0, blue: 0.18), location: 0.00),
                                Gradient.Stop(color: Color(red: 0.89, green: 0, blue: 0.18).opacity(0), location: 1.00),
                            ],
                            center: UnitPoint(x: 0.5, y: 0.5)
                        )
                        .rotationEffect(Angle(degrees: loading))
                    )
                    .onTapGesture {
                        if isLoading == false{
                            statusText = "СКАНИРУЮ..."
                            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false), {
                                loading = loading + 360;
                            })
                            withAnimation(Animation.easeInOut(duration: 1), {
                                objUnitX = 0.0
                            })
                            isLoading = true;
                        }
                        
                    }
                    .cornerRadius(135)
                    .blur(radius: 30)
                    .opacity(0.5)
                
                VStack(spacing: 8) {
                    if isLoading {
                        Text(statusText)
                            .font(
                                Font.custom("Onest", size: 18)
                                    .weight(.semibold)
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .blurReplace))
                    }
                    else {
                        Text(statusText)
                            .font(
                                Font.custom("Onest", size: 18)
                                    .weight(.semibold)
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .blurReplace))
                    }
                    
                    Text("домен lbv.dev")
                        .font(Font.custom("Onest", size: 14))
                        .foregroundColor(.white)
                        .opacity(0.32)
                }
            }
            .opacity(opacity)
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.1)) {
                    opacity = 0.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            opacity = 1
                        }
                    }
                }
            }
            Spacer()
            
        }
    }
}

#Preview {
    ScanView()
}
