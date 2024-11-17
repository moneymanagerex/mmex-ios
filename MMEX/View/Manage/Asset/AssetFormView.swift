//
//  AssetFormView.swift
//  MMEX
//
//  2024-09-25: Created by Lisheng Guan
//  2024-10-28: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AssetFormView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: AssetData
    @State var edit: Bool

    var currency: CurrencyInfo? { vm.currencyList.info.readyValue?[data.currencyId] }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Section {
            env.theme.field.view(edit, "Name", editView: {
                TextField("Cannot be empty!", text: $data.name)
                    .textInputAutocapitalization(.words)
            }, showView: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.name)
            } )
            
            env.theme.field.view(edit, false, "Type", editView: {
                Picker("", selection: $data.type) {
                    ForEach(AssetType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }, showView: {
                Text(data.type.rawValue)
            } )
            
            env.theme.field.view(edit, false, "Status", editView: {
                Toggle(isOn: $data.status.isOpen) { }
            }, showView: {
                Text(data.status.rawValue)
            } )
            
            env.theme.field.view(edit, true, "Start Date", editView: {
                DatePicker("", selection: $data.startDate.date, displayedComponents: [.date])
                    .labelsHidden()
            }, showView: {
                env.theme.field.valueOrError("Should not be empty!", text: data.startDate.string)
            } )
            
            if
                let currencyOrder = vm.currencyList.order.readyValue,
                let currencyName  = vm.currencyList.name.readyValue
            {
                env.theme.field.view(edit, false, "Currency", editView: {
                    Picker("", selection: $data.currencyId) {
                        if (data.currencyId.isVoid) {
                            Text("(none)").tag(DataId.void)
                        }
                        ForEach(currencyOrder, id: \.self) { id in
                            Text(currencyName[id] ?? "").tag(id)
                        }
                    }
                }, showView: {
                    env.theme.field.valueOrError("Cannot be empty!", text: currency?.name)
                } )
            }

            env.theme.field.view(edit, true, "Value", editView: {
                TextField("Default is 0", value: $data.value.defaultZero, format: .number)
                    .keyboardType(env.theme.decimalPad)
            }, showView: {
                Text(data.value.formatted(by: formatter))
            } )
        }
        
        Section {
            env.theme.field.view(edit, false, "Change", editView: {
                Picker("", selection: $data.change) {
                    ForEach(AssetChange.allCases) { change in
                        Text(change.rawValue).tag(change)
                    }
                }
            }, showView: {
                Text(data.change.rawValue)
            } )
            
            env.theme.field.view(edit, false, "Change Mode", editView: {
                Picker("", selection: $data.changeMode) {
                    ForEach(AssetChangeMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
            }, showView: {
                Text(data.changeMode.rawValue)
            } )
            
            env.theme.field.view(edit, true, "Change Rate", editView: {
                TextField("Default is 0", value: $data.changeRate.defaultZero, format: .number)
                    .keyboardType(env.theme.decimalPad)
            }, showView: {
                Text("\(data.changeRate)")
            } )
        }

        Section{
            env.theme.field.notes(edit, "Notes", $data.notes)
        }
    }
}

#Preview("\(AssetData.sampleData[0].name) (show)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { AssetFormView(
        vm: vm,
        data: .constant(AssetData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(AssetData.sampleData[0].name) (edit)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { AssetFormView(
        vm: vm,
        data: .constant(AssetData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}
