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

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Введите ваш домен")
                    .font(.headline)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray.opacity(0.5))
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }

            HStack {
                TextField("Введите домен", text: $myDomain)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                    )
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isFocused)
#if !os(macOS)
                    .keyboardType(.URL)
                    .submitLabel(.done)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
#endif
                    .onAppear { isFocused = true }
                    .onSubmit {
                        saveDomain(myDomain)
                        dismiss()
                    }
            }
            .padding(.bottom, 12)

            Button {
                saveDomain(myDomain)
                dismiss()
            } label: {
                Text("Сохранить")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(18)
        .background(Color.gray.opacity(0.12))
    }
}
