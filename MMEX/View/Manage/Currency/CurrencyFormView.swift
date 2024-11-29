//
//  CurrencyFormView.swift
//  MMEX
//
//  2024-09-17: Created by Lisheng Guan
//  2024-10-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CurrencyFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var focus: Bool
    @Binding var data: CurrencyData
    @State var edit: Bool

    @FocusState var focusState: Int?

    var format: String {
        let amount: Double = 12345.67
        return amount.formatted(by: data.formatter)
    }

    var body: some View {
        Group {
            Section {
                pref.theme.field.view(edit, "Name", editView: {
                    TextField("Shall not be empty!", text: $data.name)
                        .focused($focusState, equals: 1)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.sentences)
                }, showView: {
                    pref.theme.field.valueOrError("Shall not be empty!", text: data.name)
                } )
                
                pref.theme.field.view(edit, "Symbol", editView: {
                    TextField("Shall not be empty!", text: $data.symbol)
                        .focused($focusState, equals: 2)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.characters)
                }, showView: {
                    pref.theme.field.valueOrError("Shall not be empty!", text: data.symbol)
                } )
                
                pref.theme.field.view(edit, false, "Type", editView: {
                    Picker("", selection: $data.type) {
                        ForEach(CurrencyType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }, showView: {
                    Text(data.type.rawValue)
                } )
                
                if edit || !data.unitName.isEmpty || !data.centName.isEmpty {
                    pref.theme.field.view(edit, "Unit Name", valueView: {
                        TextField("N/A", text: $data.unitName)
                            .focused($focusState, equals: 3)
                            .keyboardType(pref.theme.textPad)
                            .textInputAutocapitalization(.sentences)
                    } )
                    
                    pref.theme.field.view(edit, "Cent Name", valueView: {
                        TextField("N/A", text: $data.centName)
                            .focused($focusState, equals: 4)
                            .keyboardType(pref.theme.textPad)
                            .textInputAutocapitalization(.sentences)
                    } )
                }
                
                pref.theme.field.view(edit, true, "Conversion Rate", editView: {
                    TextField("Default is 1", value: $data.baseConvRate.defaultOne, format: .number)
                        .focused($focusState, equals: 5)
                        .keyboardType(pref.theme.decimalPad)
                }, showView: {
                    Text("\(data.baseConvRate)")
                } )
            }
            
            Section("Format") {
                pref.theme.field.view(false, "", valueView: {
                    Text(format)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.gray)
                } )
                
                if edit {
                    pref.theme.field.view(edit, "Prefix Symbol") {
                        TextField("N/A", text: $data.prefixSymbol)
                            .focused($focusState, equals: 6)
                            .keyboardType(pref.theme.textPad)
                            .textInputAutocapitalization(.characters)
                    }
                    pref.theme.field.view(edit, "Suffix Symbol") {
                        TextField("N/A", text: $data.suffixSymbol)
                            .focused($focusState, equals: 7)
                            .keyboardType(pref.theme.textPad)
                            .textInputAutocapitalization(.characters)
                    }
                    pref.theme.field.view(edit, "Decimal Point") {
                        TextField("N/A", text: $data.decimalPoint)
                            .focused($focusState, equals: 8)
                            .keyboardType(pref.theme.textPad)
                    }
                    pref.theme.field.view(edit, "Thousands Separator") {
                        TextField("N/A", text: $data.groupSeparator)
                            .focused($focusState, equals: 9)
                            .keyboardType(pref.theme.textPad)
                    }
                    pref.theme.field.view(edit, true, "Scale", editView: {
                        TextField("Default is 1", value: $data.scale.defaultOne, format: .number)
                            .focused($focusState, equals: 10)
                            .keyboardType(pref.theme.decimalPad)
                    }, showView: {
                        Text("\(data.scale)")
                    } )
                }
            }
        }
        .keyboardState(focus: $focus, focusState: $focusState)
    }
}

#Preview("\(CurrencyData.sampleData[0].symbol) (read)") {
    let data = CurrencyData.sampleData[0]
    MMEXPreview.manageRead(data) { $focus, $data, edit in CurrencyFormView(
        focus: $focus,
        data: $data,
        edit: edit
    ) }
}

#Preview("\(CurrencyData.sampleData[0].symbol) (edit)") {
    let data = CurrencyData.sampleData[0]
    MMEXPreview.manageEdit(data) { $focus, $data, edit in CurrencyFormView(
        focus: $focus,
        data: $data,
        edit: edit
    ) }
}
