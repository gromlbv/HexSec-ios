//
//  AuthService.swift
//  HexSec
//
//  Created by dmitry lbv on 09.04.2025.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    private init() {}

    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://just-wholly-osprey.ngrok-free.app/auth/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "email=\(email)&pw=\(password)"
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "no response", code: -1)))
                return
            }

            if httpResponse.statusCode == 200, let data = data,
               let token = String(data: data, encoding: .utf8) {
                completion(.success(token))
            } else if httpResponse.statusCode == 401 {
                
            } else {
                completion(.failure(NSError(domain: "login failed", code: httpResponse.statusCode)))
            }
        }.resume()
    }
    
    func checkEmail(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "https://just-wholly-osprey.ngrok-free.app/auth/check/email?email=\(email)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "no response", code: -1)))
                return
            }

            if httpResponse.statusCode == 200, let data = data {
                let string = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                completion(.success(string == "true"))
            } else {
                let error = NSError(domain: "email check failed", code: httpResponse.statusCode)
                completion(.failure(error))
            }
        }
        .resume()
    }
    
    func checkPassword(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "https://just-wholly-osprey.ngrok-free.app/auth/check/password?email=\(email)&pw=\(password)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "no response", code: -1)))
                return
            }
            
            if httpResponse.statusCode == 200, let data = data {
                let string = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                completion(.success(string == "true"))
            } else {
                let error = NSError(domain: "email check failed", code: httpResponse.statusCode)
                completion(.failure(error))
            }
        }
        .resume()
    }
    
    func sendOTP(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "https://just-wholly-osprey.ngrok-free.app/auth/email/otp/send?email=\(email)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "no response", code: -1)))
                return
            }

            if httpResponse.statusCode == 204, let data = data {
                let string = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                completion(.success(string == "true"))
            } else {
                let error = NSError(domain: "email otp send failed", code: httpResponse.statusCode)
                completion(.failure(error))
            }
        }
        .resume()
    }
}
