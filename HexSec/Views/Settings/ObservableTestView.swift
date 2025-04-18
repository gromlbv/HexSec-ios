//
//  ObservableTestView.swift
//  HexSec
//
//  Created by dmitry lbv on 15.04.2025.
//

import SwiftUI

struct ObservableTestView: View {

    @EnvironmentObject var store: DomainStore
    @State private var currentDomain: String = ""
    
    var body: some View {
        List {
            TextField("Domain", text: $currentDomain)
            Button("Add") {
                store.add(currentDomain)
            }
            ForEach(store.domainList, id: \.self) { domain in
                Text(domain)
            }
        }
    }
}

#Preview {
    ObservableTestView()
        .environmentObject(DomainStore())
}
