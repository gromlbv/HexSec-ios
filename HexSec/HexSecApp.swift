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
    @State private var isFeedbackActive: Bool = true

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
            
            VStack() {
                Spacer()
                Button {
                    withAnimation {
                        isFeedbackActive = true
                    }
                } label: {

                    ZStack{
                        RoundedRectangle(cornerRadius: 0)
                            .fill(isFeedbackActive ? .black : Color.white.opacity(0.2))
                        
                        VStack {
                            HStack{
                                VStack {
                                    Text("Отправить отзыв")
                                        .font(.headline)
                                    
                                }
                                
                                Spacer()
                                
                                Button {
                                } label: {
                                    HStack {
                                        Text("Отключить фидбек")
                                            .foregroundStyle(.white)
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
                            
                            .padding()
                            .opacity(isFeedbackActive ? 1 : 0)
                            
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
                            .padding()
                        }
                    }
                    

                }

                .frame(width: isFeedbackActive ? .infinity : 8)
                .frame(height: isFeedbackActive ?  240 : 52)
                
                .padding(0)
                .buttonStyle(.plain)
                .cornerRadius(0)

                .clipShape(
                    .rect(
                        topLeadingRadius: isFeedbackActive ? 20 : 80,
                        bottomLeadingRadius: isFeedbackActive ? 0 : 80,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: isFeedbackActive ? 20 : 0
                    )
                )
            }
            .padding(.bottom, isFeedbackActive ? 0 : 96)
            .background(isFeedbackActive ? .black.opacity(0.4) : .clear)
            .onTapGesture {
                isFeedbackActive = false
            }
            .ignoresSafeArea()
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
