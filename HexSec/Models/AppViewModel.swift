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
    
    enum Section {
        case settingsDomains
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
}
