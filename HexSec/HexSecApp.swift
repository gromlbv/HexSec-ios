import SwiftUI

@main
struct HexSecApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    @Environment(\.openURL) private var openUrl
    @StateObject private var auth = AuthManager.shared
    @State private var isFeedbackActive: Bool = false
    @State private var isFeedbackEnabled: Bool = getFeedbackEnabled()
    
    
    var body: some View {
        ZStack (alignment: .trailing){
            if auth.isLoggedIn {
                MainAppView()
                    .preferredColorScheme(.dark)
                    .environmentObject(AppViewModel.shared)
                    .transition(.blurReplace.animation(.easeInOut(duration: 1.6)).combined(with: .opacity).animation(.easeInOut(duration: 1.6)))
                
            } else {
                VStack{
                    Button{
                        auth.isLoggedIn = true
                    } label : {
                        Text("[DEBUG] - Войти без данных")
                    }
                    
                    LoginView()
                        .preferredColorScheme(.dark)
                }
                .transition(.blurReplace.combined(with: .opacity).animation(.easeInOut(duration: 0.8)))
                
            }
            
            
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
                            .frame(maxWidth: .infinity, alignment: .trailing)

                    }
                    

                }
                .padding(.bottom, isFeedbackActive ? 0 : 96)
                .opacity(isFeedbackActive ? 0 : 1)
                
                
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
                                
                                .background(.white.opacity(0.2))
                                .buttonStyle(.borderless)
                                .cornerRadius(.infinity)
                            }
                            
                        }
                        
                        
                        
                        Button{
                            sendLetter(openUrl: openUrl)
                        } label: {
                            HStack{
                                Text(verbatim: "feedback@hexsec.ru")
                                    .font(.headline)
                                Spacer()
                                Text("Написать")
                            }
                            .padding()
                            
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(24)
                    .padding(.bottom, UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .first?.windows.first?.safeAreaInsets.bottom ?? 0)
                    
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
                .offset(y: isFeedbackActive ? 0 : 424)

                .background(Color.black.mix(with: .gray, by: 0.2).opacity(0.5))
                
                .opacity(isFeedbackActive ? 1 : 0)
                .allowsHitTesting(isFeedbackActive)
                
                .ignoresSafeArea()
                .onTapGesture {
                    toggleFeedback()
                }
            }
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


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .accentColor(Color("AccentColor"))
    }
}
