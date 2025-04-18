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
                .background(.black)
            Spacer()
                .foregroundStyle(.black)
                .background(.black)
            
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



struct ExtractedView: View {
    @StateObject private var auth = AuthManager.shared
    @ObservedObject var appViewModel = AppViewModel.shared
    @State private var isPremium: Bool = true
    
    @State private var isPopupPresented = false
    @State private var showShareSheet = false
    
    @State private var isEditing: Bool = false

    
    @State private var volumeLevel: Double = 50.0
    @State private var selectedOption: String = "Системный"
    @State private var newDomain: String = ""
        
    let colorSchemeOptions = ["Светлый", "Тёмный", "Системный"]
    
    @State private var selection: String? = nil
    
    @EnvironmentObject var store: DomainStore
    
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
                NavigationLink(
                    destination: UnreleasedNavView()
                ){
                    VStack(alignment: .leading){
                        HStack{
                            Text("Подписка")
                                .bold()
                            Spacer()
                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                .frame(width: 11, height: 11)
                        }
                        Text("Осталось 14 дней")
                            .font(.callout)
                            .opacity(0.5)
                        
                    }
                }
                .foregroundStyle(.primary)
                
                #if os(iOS)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                #endif
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
                                .frame(width: 12, height: 12)
                        }
                        Text("testuser")
                            .font(.callout)
                            .opacity(0.5)
                    }
                }
                
                .foregroundStyle(.primary)
                
                #if os(iOS)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                #endif
                .background(Material.ultraThick)
                .cornerRadius(10)
                
                .contextMenu {
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Поделиться приложением", systemImage: "arrowshape.turn.up.right")
                    }
                    Button(role: .destructive) {
                        auth.logout()
                    } label: {
                        Label("Выйти из аккаунта", systemImage: "rectangle.portrait.and.arrow.forward")
                    }

                }
                
            }
            .opacity(appViewModel.flashSection == .settingsDomains ? 0.2 : 1)
            
            #if os(iOS)
            .padding(.horizontal, 18)
            #endif
            
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

                    Button(isEditing ? "Готово" : "Изменить") {
                        isEditing.toggle()
                    }
                    .font(.subheadline)
                    .transition(.opacity)
                },
                        footer: Text("Также вы можете добавить поддомен и даже определенную ссылку с параметрами")) {
                    
                    ForEach(store.domainList, id: \.self) { domain in
                        DomainRow(domain: domain, isEditing: $isEditing) {
                            deleteDomain(domain)
                        }
                    }
                    .id(UUID())
                    
                    
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
                
                
                
                Section(header: Text("Главное")) {
                    
                    NavigationLink("Настройки приложения", destination: AppSettingsView())
                    NavigationLink("Помощь и поддержка", destination: UnreleasedNavView())
                    NavigationLink("Условия пользования", destination: LegalView())

                }
                .opacity(appViewModel.flashSection == .settingsDomains ? 0.2 : 1)
                
            }

            .sheet(isPresented: $showShareSheet) {
                #if os(iOS)
                ShareSheet(items: ["HexSec - Мониторинг сайтов", URL(string: "https://hexsec.ru")!])
            #endif

            }
            .sheet(isPresented: Binding<Bool>(
                get: { self.selection == "Second" },
                set: { if !$0 { self.selection = nil } }
            )) {
                EnterDomianView(myDomain: $newDomain)
                    .presentationDetents([.height(340)])
                    .presentationBackground(Color.black)
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.visible)

            }
        }
        .background(.black)

        
#if os(iOS)
        .toolbar(removing: .sidebarToggle)
#endif
    }
    
    func deleteDomain(_ domain: String) {
        store.remove(domain)
    }
}

#if os(iOS)

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DomainStore())
    }
}


struct DomainRow: View {
    let domain: String
    @Binding var isEditing: Bool
    let deleteAction: () -> Void
    
    
    var body: some View {
        ZStack(alignment: .trailing) {
            NavigationLink {
                UnreleasedNavView()
            } label: {
                HStack {
                    if isEditing {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                    
                    //Image(systemName: "globe")
                    //    .foregroundColor(.accentColor)
                    //    .frame(width: 32, height: 32)
                    //    .cornerRadius(8)
                    
                    VStack(alignment: .leading) {
                        Text(domain)
                        Text("Онлайн • 211мс")
                            .font(.subheadline)
                            .opacity(0.5)
                    }
                    Spacer()
                }
            }
            
            if isEditing {
                Button(action: deleteAction) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .imageScale(.small)
                        .background(
                            Circle()
                                .fill(Color.red)
                                .frame(width: 24, height: 24)
                        )
                }
                .padding(.trailing, 24)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                deleteAction()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
        .contextMenu {
            
            Button {

            } label: {
                Label("Сканировать", systemImage: "lock.shield")
            }

            Button {

            } label: {
                Label("Мониторинг", systemImage: "network")
            }
            
            Divider()
            
            Button {

            } label: {
                Label("Открыть в браузере", systemImage: "link")
            }

            Button(role: .destructive) {
                deleteAction()
            } label: {
                Label("Удалить домен", systemImage: "trash")
            }

        }
        
    }
}
