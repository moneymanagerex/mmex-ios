//
//  InfoView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct InfoTableView: View {
    @State var infoItems: [InfoKey: Infotable] = [:]
    let databaseURL: URL
    private var repository:InfotableRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getInfotableRepository()
    }
    
    var body: some View {
        List {
            if let baseCurrencyID = infoItems[.baseCurrencyID]?.getValue(Int.self) {
                keyValueRow(key: "Base Currency", value: "\(baseCurrencyID)")
            }

            if let uid = infoItems[.uid]?.getValue(String.self) {
                keyValueRow(key: "UID", value: uid)
            }

            if let dateFormat = infoItems[.dateFormat]?.getValue(String.self) {
                keyValueRow(key: "Date Format", value: dateFormat)
            }
        }
        .onAppear {
            loadInfo()
        }
    }

    // Helper function to create key-value rows with color differentiation
    @ViewBuilder
    private func keyValueRow(key: String, value: String) -> some View {
        HStack {
            Text(key)
                .foregroundColor(.gray)   // Set key color to gray
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text(value)
                .foregroundColor(.primary) // Set value color to default (black)
        }
    }
    
    func loadInfo() {
        let keysToLoad: [InfoKey] = [.dataVersion, .baseCurrencyID, .uid, .dateFormat]
        infoItems = repository.loadInfo(for: keysToLoad)
    }
}

#Preview {
    InfoTableView(databaseURL: URL(string: "path/to/database")!)
}
