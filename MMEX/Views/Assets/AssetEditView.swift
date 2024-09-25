//
//  AssetEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/25.
//

import SwiftUI

struct AssetEditView: View {
    @Binding var asset: AssetData
//    @Binding var currencies: [CurrencyData]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Asset Name")) {
                    TextField("Enter asset name", text: $asset.name)
                }

                Section(header: Text("Type")) {
                    Picker("Asset Type", selection: $asset.type) {
                        ForEach(AssetType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }

                Section(header: Text("Status")) {
                    Picker("Asset Status", selection: $asset.status) {
                        ForEach(AssetStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }

 //               Section(header: Text("Currency")) {
 //                   Picker("Currency", selection: $asset.currencyId) {
 //                       ForEach(currencyOptions) { currency in
 //                           Text(currency.name).tag(currency.id)
 //                       }
 //                   }
 //               }

                Section(header: Text("Value")) {
                    TextField("Enter asset value", value: $asset.value, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Change")) {
                    Picker("Change Type", selection: $asset.change) {
                        ForEach(AssetChange.allCases, id: \.self) { change in
                            Text(change.rawValue).tag(change)
                        }
                    }

                    if asset.change != .none {
                        Picker("Change Mode", selection: $asset.changeMode) {
                            ForEach(AssetChangeMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }

                        TextField("Change Rate", value: $asset.changeRate, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Notes")) {
                    TextField("Notes", text: $asset.notes)
                }
            }
            .navigationTitle("Edit Asset")
        }
    }
}

#Preview {
    AssetEditView(asset: .constant(AssetData.sampleData[0]))
}
