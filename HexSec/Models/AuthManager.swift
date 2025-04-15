//
//  Untitled.swift
//  HexSec
//
//  Created by dmitry lbv on 09.04.2025.
//

import Foundation

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isLoggedIn: Bool = false

    private init() {
        isLoggedIn = loadToken() != nil
    }

    func validateEmail(_ email: String, completion: @escaping (String) -> Void) {
        AuthService.shared.checkEmail(email: email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let exists):
                    completion(exists ? "Email есть" : "Аккаунта с такой почтой нет.")
                case .failure:
                    completion("Сервер не отвечает")
                }
            }
        }
    }

    func validatePassword(email: String, password: String, completion: @escaping (String) -> Void) {
        AuthService.shared.checkPassword(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let correct):
                    completion(correct ? "Пароль подошел" : "Пароль с такой почтой отсутсвует")
                case .failure:
                    completion("Сервер не отвечает")
                }
            }
        }
    }

    func checkEmail(email: String) {
        AuthService.shared.checkEmail(email: email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.isLoggedIn = true
                case .failure:
                    self.isLoggedIn = false
                }
            }
        }
    }
    
    func sendOTP(email: String) {
        AuthService.shared.checkEmail(email: email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.isLoggedIn = true
                case .failure:
                    self.isLoggedIn = false
                }
            }
        }
    }
    
    func login(email: String, password: String) {
        AuthService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "authToken")
                    self.isLoggedIn = true
                case .failure:
                    self.isLoggedIn = false
                }
            }
        }
    }
    

    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        isLoggedIn = false
    }

    func getToken() -> String? {
        UserDefaults.standard.string(forKey: "authToken")
    }

    func handleResponse(_ response: URLResponse?) {
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 403 {
            DispatchQueue.main.async {
                self.logout()
                deleteToken()
            }
        }

    }
}
