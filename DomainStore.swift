//
//  DomainStore.swift
//  HexSec
//
//  Created by dmitry lbv on 15.04.2025.
//

import Foundation
import SwiftUI

class DomainStore: ObservableObject {
    @AppStorage("domainList") private var domainListData: String = "[]"

    @Published var domainList: [String] = []

    init() {
        load()
    }

    func add(_ item: String) {
        domainList.append(item)
        save()
    }

    func remove(_ item: String) {
        domainList.removeAll { $0 == item }
        save()
    }

    private func load() {
        if let data = domainListData.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            domainList = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(domainList),
           let json = String(data: data, encoding: .utf8) {
            domainListData = json
        }
    }
}
