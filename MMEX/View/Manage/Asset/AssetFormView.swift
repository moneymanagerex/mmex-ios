//
//  AssetFormView.swift
//  MMEX
//
//  2024-09-25: Created by Lisheng Guan
//  2024-10-28: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AssetFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var focus: Bool
    @Binding var data: AssetData
    @State var edit: Bool

    @FocusState var focusState: Int?

    var currency: CurrencyInfo? { vm.currencyList.info.readyValue?[data.currencyId] }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Group {
            Section {
                pref.theme.field.view(edit, "Name", editView: {
                    TextField("Shall not be empty!", text: $data.name)
                        .focused($focusState, equals: 1)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.words)
                }, showView: {
                    pref.theme.field.valueOrError("Shall not be empty!", text: data.name)
                } )
                
                pref.theme.field.view(edit, false, "Type", editView: {
                    Picker("", selection: $data.type) {
                        ForEach(AssetType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }, showView: {
                    Text(data.type.rawValue)
                } )
                
                pref.theme.field.view(edit, false, "Status", editView: {
                    Toggle(isOn: $data.status.isOpen) { }
                }, showView: {
                    Text(data.status.rawValue)
                } )
                
                pref.theme.field.view(edit, true, "Start Date", editView: {
                    DatePicker("", selection: $data.startDate.date, displayedComponents: [.date])
                        .labelsHidden()
                }, showView: {
                    pref.theme.field.valueOrError("Should not be empty!", text: data.startDate.string)
                } )
                
                if
                    let currencyOrder = vm.currencyList.order.readyValue,
                    let currencyName  = vm.currencyList.name.readyValue
                {
                    pref.theme.field.view(edit, false, "Currency", editView: {
                        Picker("", selection: $data.currencyId) {
                            if (data.currencyId.isVoid) {
                                Text("(none)").tag(DataId.void)
                            }
                            ForEach(currencyOrder, id: \.self) { id in
                                Text(currencyName[id] ?? "").tag(id)
                            }
                        }
                    }, showView: {
                        pref.theme.field.valueOrError("Shall not be empty!", text: currency?.name)
                    } )
                }
                
                pref.theme.field.view(edit, true, "Value", editView: {
                    TextField("Default is 0", value: $data.value.defaultZero, format: .number)
                        .focused($focusState, equals: 2)
                        .keyboardType(pref.theme.decimalPad)
                }, showView: {
                    Text(data.value.formatted(by: formatter))
                } )
            }
            
            Section {
                pref.theme.field.view(edit, false, "Change", editView: {
                    Picker("", selection: $data.change) {
                        ForEach(AssetChange.allCases) { change in
                            Text(change.rawValue).tag(change)
                        }
                    }
                }, showView: {
                    Text(data.change.rawValue)
                } )
                
                pref.theme.field.view(edit, false, "Change Mode", editView: {
                    Picker("", selection: $data.changeMode) {
                        ForEach(AssetChangeMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                }, showView: {
                    Text(data.changeMode.rawValue)
                } )
                
                pref.theme.field.view(edit, true, "Change Rate", editView: {
                    TextField("Default is 0", value: $data.changeRate.defaultZero, format: .number)
                        .focused($focusState, equals: 3)
                        .keyboardType(pref.theme.decimalPad)
                }, showView: {
                    Text("\(data.changeRate)")
                } )
            }
            
            Section("Notes") {
                pref.theme.field.notes(edit, "", $data.notes)
                    .focused($focusState, equals: 4)
                    .keyboardType(pref.theme.textPad)
            }
        }
        .keyboardState(focus: $focus, focusState: $focusState)
    }
}

#Preview("\(AssetData.sampleData[0].name) (read)") {
    let data = AssetData.sampleData[0]
    MMEXPreview.manageRead(data) { $focus, $data, edit in AssetFormView(
        focus: $focus,
        data: $data,
        edit: edit
    ) }
}

#Preview("\(AssetData.sampleData[0].name) (edit)") {
    let data = AssetData.sampleData[0]
    MMEXPreview.manageEdit(data) { $focus, $data, edit in AssetFormView(
        focus: $focus,
        data: $data,
        edit: edit
    ) }
}
