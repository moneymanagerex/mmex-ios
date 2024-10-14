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
    @Binding var allCurrencyName: [(DataId, String)] // sorted by name
    @Binding var asset: AssetData
    @State var edit: Bool
    var onDelete: () -> Void = { }

    var currency: CurrencyInfo? { env.currencyCache[asset.currencyId] }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Form {
            Section {
                env.theme.field.text(edit, "Name") {
                    TextField("Cannot be empty!", text: $asset.name)
                        .textInputAutocapitalization(.words)
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: asset.name)
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
                    DatePicker("", selection: $asset.startDate.date, displayedComponents: [.date])
                } show: {
                    env.theme.field.valueOrError("Should not be empty!", text: asset.startDate.string)
                }

                env.theme.field.picker(edit, "Currency") {
                    Picker("", selection: $asset.currencyId) {
                        if (asset.currencyId <= 0) {
                            Text("Select Currency").tag(0 as DataId) // not set
                        }
                        ForEach(allCurrencyName, id: \.0) { id, name in
                            Text(name).tag(id)
                        }
                    }
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: currency?.name)
                }

                env.theme.field.text(edit, "Value") {
                    TextField("Default is 0", value: $asset.value, format: .number)
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
                    TextField("Default is 0", value: $asset.changeRate, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            
            Section{
                env.theme.field.editor(edit, "Notes") {
                    TextEditor(text: $asset.notes)
                        .textInputAutocapitalization(.never)
                } show: {
                    env.theme.field.valueOrHint("N/A", text: asset.notes)
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
