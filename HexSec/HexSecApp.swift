import SwiftUI

@main
struct HexSecApp: App {
    @StateObject var store = DomainStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
        }
    }
}

struct MainView: View {
    @StateObject private var auth = AuthManager.shared
    
    @AppStorage("domainList") private var domainListData: String = "[]"

    @State private var domainList: [String] = []
        
    var body: some View {
        
        ZStack (alignment: .trailing){
            if auth.isLoggedIn {
                MainAppView()
                    .environmentObject(AppViewModel.shared)
                    .environmentObject(DomainStore())
                    .transition(.blurReplace.animation(.easeInOut(duration: 1.6)).combined(with: .opacity).animation(.easeInOut(duration: 1.6)))
                
            } else {
                VStack{
                    LoginView()
                }
                .transition(.blurReplace.combined(with: .opacity).animation(.easeInOut(duration: 0.8)))
            }
            
            FeedbackView()

        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

