//
//  SettingsView.swift
//  HexSec
//
//  Created by dmitry lbv on 27.01.2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
    #if os(macOS)
        NavigationSplitView {
            ExtractedView()
                .padding()
                .navigationSplitViewColumnWidth(240)
                .navigationSplitViewStyle(.prominentDetail)

        } detail: {
            VStack {
                Text("Выберите настройку")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .navigationSplitViewStyle(.prominentDetail)
        .navigationTitle(Text("Настройки"))

#else
#if os(iOS)
if UIDevice.current.userInterfaceIdiom == .pad {
    NavigationSplitView(
        sidebar: {
            NavigationStack {
                ExtractedView()
            }
            .navigationSplitViewColumnWidth(410)

        },
        detail: {
            VStack {
                Text("Выберите настройку")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .toolbar(removing: .sidebarToggle)

        }

    )
} else {
    NavigationView {
        ExtractedView()
    }
}
#endif

#endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct ExtractedView: View {
    @StateObject private var auth = AuthManager.shared
    @ObservedObject var appViewModel = AppViewModel.shared
    @State private var isPremium: Bool = true
    
    @State private var isPopupPresented = false
    
    #if os(iOS)
    @State private var editMode: EditMode = .inactive
    #else
    @State private var isEditing = false
    #endif
    
    @State private var volumeLevel: Double = 50.0
    @State private var selectedOption: String = "Системный"
    @State private var newDomain: String = ""
    
    @State private var isFeedbackEnabled: Bool = getFeedbackEnabled()

    let colorSchemeOptions = ["Светлый", "Тёмный", "Системный"]
    
    @State private var selection: String? = nil
    
    var body: some View {
        VStack{
            VStack{
                Spacer()
                Text("HexSec")
                    .zIndex(2)
                    .font(.title2)
                    .bold()
                
                Text("Plus")
                    .foregroundStyle(Color.accentColor)
                    .font(.title)
                    .bold()
                    .background{
                        Circle()
                            .trim(from: 0.5, to: 1)
                            .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .scaledToFit()
                            .frame(width: 204, height: 204)
                            .padding(.top, 40)
                        Circle()
                            .trim(from: 0.5, to: 1)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.accentColor.opacity(1),
                                        Color.accentColor.opacity(0),
                                        Color.accentColor.opacity(0),
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 204, height: 204)
                            .opacity(0.35)
                            .padding(.top, 40)
                    }
            }
            .frame(height: 120)
            .padding(.bottom, 40)
            
            .opacity(appViewModel.flashSection == .settingsDomains ? 0.2 : 1)
            
            HStack{
#if os(iOS)
                NavigationLink(
                    destination: UnreleasedNavView()
                ){
                    VStack(alignment: .leading){
                        HStack{
                            Text("Подписка")
                                .bold()
                            Spacer()
                            Image(systemName: "arrow.trianglehead.2.clockwise")
                        }
                        Text("Осталось 14 дней")
                            .font(.callout)
                            .opacity(0.5)
                        
                    }
                }
                .foregroundStyle(.primary)
                
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Material.ultraThick)
                .cornerRadius(10)
                
                NavigationLink(
                    destination: AccountView()
                ){
                    VStack(alignment: .leading){
                        HStack{
                            Text("Аккаунт")
                                .bold()
                            Spacer()
                            Image(systemName: "person.circle")
                        }
                        Text("testuser")
                            .font(.callout)
                            .opacity(0.5)
                    }
                }
                
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Material.ultraThick)
                .cornerRadius(10)
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = "hexsec.ru"
                    } label: {
                        Label("Поделиться приложением", systemImage: "apple.logo")
                    }
                    Button(role: .destructive) {
                        auth.logout()
                    } label: {
                        Label("Выйти из аккаунта", systemImage: "rectangle.portrait.and.arrow.forward")
                    }
                }
                
#endif
            }
            .opacity(appViewModel.flashSection == .settingsDomains ? 0.2 : 1)
            
            .padding(.horizontal, 18)
            
            Divider()
#if os(iOS)
                .padding(.horizontal)
                .padding(.top, 18)
#endif
            
            Form {
                Section(header:
                            HStack{
                    Text("Мои домены")
                    Spacer()
                    
                    .font(.subheadline)
                    .transition(.opacity)
                },
                        footer: Text("При добавлении или удалении домена возможно прийдется перезагрузить приложение")) {
                    ForEach(getDomains(), id: \.self) { domain in
                        ZStack(alignment: .trailing) {
                            NavigationLink {
                                UnreleasedNavView()
                            } label: {
                                HStack {
                                        Image(systemName: "line.3.horizontal")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    
                                    VStack(alignment: .leading) {
                                        Text(domain)
                                        Text("211мс • Здесь будет статус")
                                            .font(.subheadline)
                                            .opacity(0.5)
                                    }
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            
                                Button(action: {
                                    deleteDomain(domain)
                                    isPopupPresented = true
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                        .imageScale(.small)
                                }
                                .zIndex(2)
                                .background {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 24, height: 24)
                                }
                                .padding(.trailing, 24)
                        
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteDomain(domain)
                                isPopupPresented = true
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                        
                    Button {
                        self.selection = "Second"
                    } label: {
                        Text("Добавить домен")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding(8)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    
                }
                .scaleEffect(appViewModel.flashSection == .settingsDomains ? 1.03 : 1)
                
                
                
                Section(header: Text("Настройки приложения")) {
                    Toggle(isOn: $isFeedbackEnabled) {
                        Text("Включить отправку отзыва")
                    }
                    .onChange(of: isFeedbackEnabled) {
                        toggleFeedbackEnabled()
                    }
                    
                    NavigationLink("Уведомления", destination: NotificationView())
                    NavigationLink("Помощь и поддержка", destination: UnreleasedNavView())
                    NavigationLink("Условия пользования", destination: UnreleasedNavView())
                }
                .opacity(appViewModel.flashSection == .settingsDomains ? 0.2 : 1)
                
            }
            
            .alert(isPresented: $isPopupPresented) {
                Alert(
                    title: Text("Ранняя сборка"),
                    message: Text("При удалении домена скорее всего прийдется перезагрузить приложение"),
                    primaryButton: .default(Text("Окей")) {
                        isPopupPresented = false
                    },
                    secondaryButton: .default(Text("Понял"))
                )
            }
            .sheet(isPresented: Binding<Bool>(
                get: { self.selection == "Second" },
                set: { if !$0 { self.selection = nil } }
            )) {
                EnterDomianView(myDomain: $newDomain)
                    .presentationDetents([.height(230)])
                    .presentationBackground(Color.black)
                    .presentationCornerRadius(24)
            }
        }

        #if os(iOS)
        .toolbar(removing: .sidebarToggle)
        #endif
    }
    
    func deleteDomain(_ domain: String) {
        var domains = getDomains()
        domains.removeAll { $0 == domain }
        UserDefaults.standard.set(domains, forKey: "myDomains")
    }
}

#Preview {
    SettingsView()
}
