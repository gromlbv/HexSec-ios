//
//  NotificationView.swift
//  HexSec
//
//  Created by dmitry lbv on 06.04.2025.
//

import SwiftUI

struct NotificationView: View {
    @State private var isNotificationSubscription: Bool = false
    @State private var isNotification1: Bool = false
    @State private var isNotification2: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section (header: Text("Уведомлять об..."), footer: Text("Пока-что смена настроек ни на что не влияет")){
                        
                        Toggle(isOn: $isNotificationSubscription) {
                            Text("Возобновление подписки")
                        }
                        .disabled(true)

                        Toggle(isOn: $isNotification1) {
                            Text("О проблемах с безопасностью на добавленных сайтах")
                        }
                        .disabled(true)

                        Toggle(isOn: $isNotification1) {
                            Text("О проблемах с доступом к сайту")
                        }
                        .disabled(true)

                        Toggle(isOn: $isNotification2) {
                            Text("Акции и события")
                            
                        }
                        .disabled(true)
                        
                    }
                }

                Spacer()

                HStack {
                    // Button {
                    //
                    // } label: {
                    //     Text("Отключить")
                    //         .font(.headline)
                    //         .frame(maxWidth: .infinity)
                    //         .padding(12)
                    // }
                    // .buttonStyle(BorderedButtonStyle())
                    //
                    // Button {
                    //     // Действие
                    // } label: {
                    //     Text("Включить все")
                    //         .font(.headline)
                    //         .frame(maxWidth: .infinity)
                    //         .padding(12)
                    // }
                    // .buttonStyle(BorderedProminentButtonStyle())
                    
                }
                .padding()
                .padding(.bottom, 24)
                            
            }
            .toolbarVisibility(.hidden)

        }
        .navigationTitle("Уведомления")
        .navigationTransition(.automatic)
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
}

#Preview {
    NotificationView()
}
