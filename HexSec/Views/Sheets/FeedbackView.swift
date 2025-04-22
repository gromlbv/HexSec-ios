//
//  FeedbackView.swift
//  HexSec
//
//  Created by dmitry lbv on 21.04.2025.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.openURL) private var openUrl
    @AppStorage("isFeedbackEnabled") private var isFeedbackEnabled: Bool = false
    @State private var isFeedbackActive: Bool = false

    var body: some View {

        if isFeedbackEnabled {
            VStack() {
                Spacer()
                
                ZStack {
                    Button {
                        toggleFeedback()
                    } label: {
                        Color.clear
                            .contentShape(Rectangle())
                    }
                    .frame(width: 21, height: 62)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .zIndex(6)
                    
                    .padding(0)
                    .buttonStyle(.plain)
                    .cornerRadius(0)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 8, height: 52, alignment: .trailing)
                    
                        .clipShape(
                            .rect(
                                topLeadingRadius: 80,
                                bottomLeadingRadius: 80,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 0
                            )
                        )
                        .zIndex(5)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                }
                
                
            }
            .padding(.bottom, isFeedbackActive ? 0 : 96)
            .opacity(isFeedbackActive ? 0 : 1)
        }
        
        
        VStack() {
            Spacer()
            VStack(spacing: 24) {
                HStack(alignment: .top) {
                    
                    Image(systemName: "list.bullet.clipboard.fill")
                        .font(.system(size: 32))
                        .imageScale(.large)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.accentColor)
                        .padding(.trailing, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Отправить отзыв")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Мы активно разрабатываем приложение, поэтому очень хотели бы услышать ваше мнения и предложения!")
                            .multilineTextAlignment(.leading)
                            .font(.caption)
                            .opacity(0.5)
                            .padding(.bottom, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    Button {
                        toggleFeedbackEnabled()
                    } label: {
                        HStack {
                            Image(systemName: "xmark")
                                .tint(.white)
                        }
                        .padding(8)
                        .foregroundStyle(.white)
                        
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(.infinity)
                    }
                    .buttonStyle(.plain)

                    
                }
                
                
                Button{
                    sendLetter(openUrl: openUrl)
                } label: {
                    HStack{
                        Text(verbatim: "feedback@hexsec.ru")
                        Spacer()
                        Text("Написать")
                            .font(.headline)
                    }
                    .padding()
                    
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
            #if os(iOS)
            .padding(.bottom, UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.safeAreaInsets.bottom ?? 0)
#endif

            
            .background(.black)
            .clipShape(
                .rect(
                    topLeadingRadius: 24,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 24
                )
            )
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
            
        }

        .blur(radius: isFeedbackActive ? 0 : 64)
        .offset(y: isFeedbackActive ? 0 : 424)

        .background(Color.black.mix(with: .gray, by: 0.2).opacity(0.5))
        
        .opacity(isFeedbackActive ? 1 : 0)
        .allowsHitTesting(isFeedbackActive)
        
        .ignoresSafeArea()
        .onTapGesture {
            toggleFeedback()
        }
        

    }
    
    func toggleFeedback() {
        withAnimation {
            isFeedbackActive.toggle()
        }
    }
    
    func sendLetter (openUrl: OpenURLAction) {
        let urlString = "mailto:feedback@hexsec.ru?subject=Отзыв о приложении HexSec&body="
        guard let url = URL(string: urlString) else { return }
        
        openUrl(url) { accepted in
            if !accepted {
                print("Failed to open URL")
            }
        }
    }
    
}


#Preview {
    FeedbackView()
}
