//
//  EnterDomianView.swift
//  HexSec
//
//  Created by dmitry lbv on 04.04.2025.
//

import SwiftUI

struct EnterDomianView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var myDomain: String
    @FocusState private var isFocused: Bool
    
    @EnvironmentObject var store: DomainStore

    var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Новый домен")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Мы поддерживаем даже поддомены и ссылки с аргументами!")
                        .font(.subheadline)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)


                Spacer()
                Image(systemName: "globe")
                    .imageScale(.large)
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 64, height: 64)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(.infinity)
            }

            HStack {
                TextField("hexsec.ru", text: $myDomain)
                    .font(.title)
                    .textFieldStyle(.plain)
                    .frame(height: 64)
                    .background(
                        Color.clear
                            .contentShape(Rectangle())
                    )
                    .overlay(
                        Rectangle() // Линия снизу
                            .frame(height: 2)
                            .offset(y: 0)
                            .foregroundColor(.white.opacity(0.12)), alignment: .bottom
                    )
                    .padding(.bottom, 8)
#if !os(macOS)
                    .keyboardType(.URL)
                    .submitLabel(.done)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
#endif
                    .focused($isFocused)
                    .onAppear { isFocused = true }
                    .onSubmit {
                        store.add(myDomain)
                        dismiss()
                    }
            }
            .padding(.bottom, 12)

            Button {
                store.add(myDomain)
                dismiss()
            } label: {
                Text("Сохранить")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .cornerRadius(.infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(18)
        .background(.black)
    }
}

struct EnterDomianView_Previews: PreviewProvider {
    static var previews: some View {
        let domain = Binding<String>(
            get: { "" },
            set: { _ in }
        )
        
        EnterDomianView(myDomain: domain)
            .environmentObject(DomainStore())
    }
}
