//
//  AssetEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/25.
//  Edited 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AssetEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    @Binding var allCurrencyName: [(Int64, String)] // sorted by name
    @Binding var asset: AssetData
    @State var edit: Bool
    var onDelete: () -> Void = { }

    var currency: CurrencyInfo? { env.currencyCache[asset.currencyId] }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Form {
            Section {
                env.theme.field.text(edit, "Name") {
                    TextField("Asset Name", text: $asset.name)
                        .textInputAutocapitalization(.words)
                }
                env.theme.field.picker(edit, "Type") {
                    Picker("", selection: $asset.type) {
                        ForEach(AssetType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                } show: {
                    Text(asset.type.rawValue)
                }
                env.theme.field.toggle(edit, "Status") {
                    Toggle(isOn: $asset.status.isOpen) { }
                } show: {
                    Text(asset.status.rawValue)
                }
                env.theme.field.date(edit, "Start Date") {
                    DatePicker("", selection: $asset.startDate.date, displayedComponents: [.date]
                    )
                } show: {
                    Text(asset.startDate.string)
                }
                env.theme.field.picker(edit, "Currency") {
                    Picker("", selection: $asset.currencyId) {
                        if (asset.currencyId == 0) {
                            Text("Select Currency").tag(0 as Int64) // not set
                        }
                        ForEach(allCurrencyName, id: \.0) { id, name in
                            Text(name).tag(id) // Use currency.name to display and tag by id
                        }
                    }
                } show: {
                    Text(currency?.name ?? "Unknown currency!")
                }
                env.theme.field.text(edit, "Value") {
                    TextField("Value", value: $asset.value, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(asset.value.formatted(by: formatter))
                }
            }

            Section {
                env.theme.field.picker(edit, "Change") {
                    Picker("", selection: $asset.change) {
                        ForEach(AssetChange.allCases) { change in
                            Text(change.rawValue).tag(change)
                        }
                    }
                } show: {
                    Text(asset.change.rawValue)
                }
                env.theme.field.picker(edit, "Change Mode") {
                    Picker("", selection: $asset.changeMode) {
                        ForEach(AssetChangeMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                } show: {
                    Text(asset.changeMode.rawValue)
                }
                env.theme.field.text(edit, "Change Rate") {
                    TextField("Change Rate", value: $asset.changeRate, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            
            Section{
                env.theme.field.editor(edit, "Notes") {
                    TextEditor(text: $asset.notes)
                        .textInputAutocapitalization(.never)
                } show: {
                    Text(asset.notes)
                }
            }

            // TODO: delete account if not in use
            if true {
                Button("Delete Asset") {
                    onDelete()
                }
                .foregroundColor(.red)
            }
        }
        .textSelection(.enabled)
    }
}

#Preview("\(AssetData.sampleData[0].name) (show)") {
    AssetEditView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        asset: .constant(AssetData.sampleData[0]),
        edit: false
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("\(AssetData.sampleData[0].name) (edit)") {
    AssetEditView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        asset: .constant(AssetData.sampleData[0]),
        edit: true
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("\(AssetData.sampleData[1].name) (show)") {
    AssetEditView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        asset: .constant(AssetData.sampleData[1]),
        edit: false
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("\(AssetData.sampleData[1].name) (edit)") {
    AssetEditView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        asset: .constant(AssetData.sampleData[1]),
        edit: true
    )
    .environmentObject(EnvironmentManager.sampleData)
}
