//
//  MyUserDefaults.swift
//  HexSec
//
//  Created by dmitry lbv on 05.04.2025.
//

import Foundation

private let domainsKey = "myDomains"
private let tokenKey = "authToken"
private let notificationKey = "isNotificationSubscription"
private let feedbackEnabledKey = "isFeedbackEnabled"

// MARK: - Domains

func saveDomain(_ domain: String) {
    var domains = getDomains()
    if !domains.contains(domain) {
        domains.append(domain)
        UserDefaults.standard.set(domains, forKey: "myDomains")
    }
}

func getDomains() -> [String] {
    UserDefaults.standard.stringArray(forKey: "myDomains") ?? []
}

func deleteDomain(_ domain: String) {
    var domains = getDomains()
    domains.removeAll { $0 == domain }
    UserDefaults.standard.set(domains, forKey: "myDomains")
}

func getCurrentDomain() -> String {
    getDomains().first ?? "just-wholly-osprey.ngrok-free.app/auth/test"
}

// MARK: - Token

func saveToken(_ token: String) {
    UserDefaults.standard.set(token, forKey: tokenKey)
}

func deleteToken() {
    UserDefaults.standard.removeObject(forKey: tokenKey)
}

func loadToken() -> String? {
    UserDefaults.standard.string(forKey: tokenKey)
}

// MARK: - Notification

func updateNotification(_ isSubscribed: Bool) {
    UserDefaults.standard.set(isSubscribed, forKey: notificationKey)
}



// MARK: - Feedback

func toggleFeedbackEnabled() {
    let current = getFeedbackEnabled()
    let toggled = !(current)
    UserDefaults.standard.set(toggled, forKey: feedbackEnabledKey)
}

func getFeedbackEnabled() -> Bool {
    UserDefaults.standard.bool(forKey: feedbackEnabledKey)
}
