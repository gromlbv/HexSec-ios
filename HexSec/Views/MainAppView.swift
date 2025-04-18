//
//  MainAppView.swift
//  HexSec
//
//  Created by dmitry lbv on 09.04.2025.
//

import SwiftUI

struct MainAppView: View {
    @ObservedObject var appViewModel = AppViewModel.shared
    @State private var selection: String? = nil
    @StateObject private var auth = AuthManager.shared
    @State private var token: String = (loadToken() ?? "none")
    
    var body: some View {

        TabView(selection: $appViewModel.selectedTab) {
            
            MonitoringView()
                .tabItem {
                    Label("Мониторинг", systemImage: "doc.text")
                }
                .tag(0)
            
            ScanView()
                .tabItem {
                    Label {
                        Text("Сканирование")
                    } icon: {
                        if appViewModel.selectedTab == 1 {
                            Image("scanSvg")
                        } else {
                            Image("scanSvgInactive")
                                .transition(.blurReplace)
                        }
                    }
                }
                .tag(1)
            
            
            #if os(macOS)
            
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
                .tag(2)
            
            #else

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
                .tag(2)
            
            #endif
            
            
        }
        .background(Color.black.ignoresSafeArea(.all))
        #if os(macOS)
        .toolbar(removing: .title)
        .toolbar {

        }
        .toolbarBackground(Color.black)
#endif
    }
}

#Preview {
    MainAppView()
        .environmentObject(DomainStore())
}
