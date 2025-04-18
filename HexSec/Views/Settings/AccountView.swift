//
//  AccountView.swift
//  HexSec
//
//  Created by dmitry lbv on 09.04.2025.
//

//
//  AppSettingsView.swift
//  HexSec
//
//  Created by dmitry lbv on 06.04.2025.
//

import SwiftUI

struct AccountView: View {
    @StateObject private var auth = AuthManager.shared
    @State private var token: String = (loadToken() ?? "Токена нет")
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                Form{
                    
                    Section {
                        HStack(spacing: 12){
                            
                            Image(systemName: "person.circle.fill")
                                .imageScale(.large)
                            VStack{
                                Text("debugAccount@hexsec.ru")
                                    .tint(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(auth.isLoggedIn ? "Успешно авторизован" : "Не в аккаунте (Что?)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    .tint(.white)
                                    .opacity(0.5)
                                
                            }
                        }
                        
                        Button{
                            auth.logout()
                        } label: {
                            Text("Выйти из аккаунта")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(8)
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        
                    }
                    Text(token)

                }
            }
            .toolbarVisibility(.hidden)

        }
        .navigationTitle("Аккаунт")
        .navigationTransition(.automatic)
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
}

#Preview {
    AccountView()
}
