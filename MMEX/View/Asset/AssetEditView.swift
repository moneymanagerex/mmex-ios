//
//  AssetEditView.swift
//  MMEX
//
//  2024-09-25: Created by Lisheng Guan
//  2024-10-28: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AssetEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: AssetData
    @State var edit: Bool

    var currency: CurrencyInfo? { env.currencyCache[data.currencyId] }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Section {
            env.theme.field.text(edit, "Name") {
                TextField("Cannot be empty!", text: $data.name)
                    .textInputAutocapitalization(.words)
            } show: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.name)
            }
            
            env.theme.field.picker(edit, "Type") {
                Picker("", selection: $data.type) {
                    ForEach(AssetType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            } show: {
                Text(data.type.rawValue)
            }
            
            env.theme.field.toggle(edit, "Status") {
                Toggle(isOn: $data.status.isOpen) { }
            } show: {
                Text(data.status.rawValue)
            }
            
            env.theme.field.date(edit, "Start Date") {
                DatePicker("", selection: $data.startDate.date, displayedComponents: [.date])
            } show: {
                env.theme.field.valueOrError("Should not be empty!", text: data.startDate.string)
            }
            
            if
                let currencyOrder = vm.currencyList.order.readyValue,
                let currencyName  = vm.currencyList.name.readyValue
            {
                env.theme.field.picker(edit, "Currency") {
                    Picker("", selection: $data.currencyId) {
                        if (data.currencyId <= 0) {
                            Text("Select Currency").tag(0 as DataId) // not set
                        }
                        ForEach(currencyOrder, id: \.self) { id in
                            Text(currencyName[id] ?? "").tag(id)
                        }
                    }
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: currency?.name)
                }
            }
            
            env.theme.field.text(edit, "Value") {
                TextField("Default is 0", value: $data.value, format: .number)
                    .keyboardType(.decimalPad)
            } show: {
                Text(data.value.formatted(by: formatter))
            }
        }
        
        Section {
            env.theme.field.picker(edit, "Change") {
                Picker("", selection: $data.change) {
                    ForEach(AssetChange.allCases) { change in
                        Text(change.rawValue).tag(change)
                    }
                }
            } show: {
                Text(data.change.rawValue)
            }
            
            env.theme.field.picker(edit, "Change Mode") {
                Picker("", selection: $data.changeMode) {
                    ForEach(AssetChangeMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
            } show: {
                Text(data.changeMode.rawValue)
            }
            
            env.theme.field.text(edit, "Change Rate") {
                TextField("Default is 0", value: $data.changeRate, format: .number)
                    .keyboardType(.decimalPad)
            }
        }
        
        Section{
            env.theme.field.editor(edit, "Notes") {
                TextEditor(text: $data.notes)
                    .textInputAutocapitalization(.never)
            } show: {
                env.theme.field.valueOrHint("N/A", text: data.notes)
            }
        }
    }
}

#Preview("\(AssetData.sampleData[0].name) (show)") {
    let env = EnvironmentManager.sampleData
    Form { AssetEditView(
        vm: ViewModel(env: env),
        data: .constant(AssetData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(AssetData.sampleData[0].name) (edit)") {
    let env = EnvironmentManager.sampleData
    Form { AssetEditView(
        vm: ViewModel(env: env),
        data: .constant(AssetData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}
