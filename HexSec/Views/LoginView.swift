//
//  LoginView.swift
//  HexSec
//
//  Created by dmitry lbv on 08.04.2025.
//

import SwiftUI

struct LoginView: View {
    @State private var inputUsername = ""
    @State private var inputPassword = ""
    @ObservedObject private var auth = AuthManager.shared
    @State private var isEmail = false
    @State private var isPassword = false
    @State private var resultText: String? = nil
    
    var body: some View {
        NavigationStack() {
            ZStack {
                TimelineView(.animation) { timeline in
                    let time = timeline.date.timeIntervalSince1970
                    let x = (sin(time * 0.5) + 1) / 2
                    let y = (cos(time * 0.5) + 1) / 2
                    
                    MeshGradient(width: 3, height: 3, points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [Float(x), Float(y)], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ], colors: [
                        .accentColor, .accentColor, .accentColor,
                        .accentColor, .black, .accentColor,
                        .accentColor, .accentColor, .black
                    ])
                }
                .ignoresSafeArea()
                .opacity(0.6)
                .blur(radius: 12)
                .scaleEffect(1.5)
                
                LoginExtractedView(
                    inputUsername: $inputUsername,
                    inputPassword: $inputPassword,
                    resultText: $resultText,
                    action: {
                        auth.validateEmail(inputUsername) { emailResult in
                            guard emailResult == "Email совпал" else {
                                resultText = emailResult
                                return
                            }
                            
                            
                            
                            
                        }
                        auth.validatePassword(email: inputUsername, password: inputPassword) { pwResult in
                            guard pwResult == "Пароль подошел" else {
                                resultText = pwResult
                                return
                            }
                            
                            auth.sendOTP(email: inputUsername) { success in
                                resultText = success ? "OTP отправлен" : "Не удалось отправить OTP"
                            }
                        }
                    }
                )
                
            }
            .frame(width: 600)
            
        }
    }
}
struct LoginExtractedView: View {
    @StateObject private var auth = AuthManager.shared
    
    @Binding var inputUsername: String
    @Binding var inputPassword: String
    @Binding var resultText: String?
    
    @State var isAlertVisible: Bool = false
    
    
    var action: () -> Void
    
    var body: some View {
        VStack {
            VStack {
                Button{
                    auth.isLoggedIn = true
                } label : {
                    Text("[DEBUG] - Войти без данных")
                }
                .buttonStyle(.bordered)
                
                Image(.fullLogo)
                Text("Авторизуйтесь чтобы продолжить")
                    .font(.caption)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Divider()
            
            
            VStack(alignment: .leading) {
                Text("Ваша почта")
                    .font(.title2)
                    .bold()
                
                TextField("yourmailmail.com", text: $inputUsername)
                    .textContentType(.emailAddress)
#if os(iOS)
                    .autocapitalization(.none)
#endif
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.24), lineWidth: 1)
                    )
                    .padding(.bottom, 12)
                
                Text("Пароль")
                    .font(.title2)
                    .bold()
                
                SecureField("Никому не скажем", text: $inputPassword)
                    .textContentType(.password)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.24), lineWidth: 1)
                    )
            }
            .padding()
            .frame(maxWidth: 400)
            
            Spacer()
            
            VStack {
                Button(action: {
                    action()
                    //isAlertVisible = true
                }) {
                    Text("СОЗДАТЬ ИЛИ ВОЙТИ В АККАУНТ")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(.infinity)
                .frame(maxWidth: .infinity)
                
                if let resultText {
                    Text(resultText)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
            .frame(maxWidth: 400)
            
            
        }
        .alert(isPresented: $isAlertVisible) {
            Alert(
                title: Text("Ранняя сборка"),
                message: Text("Пока что регистрация и вход не работает(осталось доделать проверку OTP), но возможно вам пришло письмо с OTP в спам"),
                primaryButton: .default(Text("Войти через debug")) {
                    isAlertVisible = false
                    auth.isLoggedIn = true
                },
                secondaryButton: .default(Text("Назад"))
                
            )
        }
        .onAppear{
            print("AAA")
        }
    }
}

#Preview {
    LoginView()
}
