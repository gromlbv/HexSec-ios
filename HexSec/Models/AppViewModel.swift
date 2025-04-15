//
//  AppViewModel.swift
//  HexSec
//
//  Created by dmitry lbv on 09.04.2025.
//

import SwiftUI

class AppViewModel: ObservableObject {
    static let shared = AppViewModel()

    @Published var selectedTab: Int = 1
    @Published var flashSection: Section? = nil
    @Published var domains: [String] {
        didSet {
            saveDomains()
        }
    }
    
    enum Section {
        case settingsDomains
    }
    
    init() {
        self.domains = AppViewModel.loadDomains()
    }
    
    func flashSection(_ section: Section) {
        selectedTab = 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                self.flashSection = section
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        self.flashSection = nil
                    }
                }
            }
        }
    }

    func addDomain(_ domain: String) {
        domains.append(domain)
        objectWillChange.send()
    }

    private func saveDomains() {
        UserDefaults.standard.set(domains, forKey: "myDomains")
    }
    
    private static func loadDomains() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "myDomains") ?? []
    }
}
